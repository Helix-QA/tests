import os
import subprocess
import sys
import shutil
import time
import pythoncom
import win32com.client
from contextlib import suppress


# ================== CONFIG ==================
AGENT_ADDR = "localhost:1540"
WP_HOST = "localhost"

DB_USER_1C = "Админ"
DB_PASS_1C = ""

PG_HOST = "localhost"
PG_PORT = "5432"
PG_USER = "postgres"
PG_PASS = "postgres"

RAC_PATH = r"C:\Program Files\1cv8\8.3.27.1688\bin\rac.exe"
RAC_CLUSTER_ADDR = "localhost:1545"

PG_RETRIES = 6
PG_WAIT_BETWEEN = 5
# ============================================


# ---------- SERVICE UTILS ----------

def run(cmd, ignore_errors=False):
    result = subprocess.run(cmd, capture_output=True, text=True)
    if ignore_errors and result.stderr:
        result.stderr = ""  # очищаем вывод ошибок
    return result



# ---------- RAC FORCE CLEAN ----------

def rac_force_drop(infobase_name: str):
    print("=== RAC CLEANUP ===")
    try:
        cluster_uuid = None
        result = run([RAC_PATH, "cluster", "list", RAC_CLUSTER_ADDR])
        if result.returncode != 0:
            print("RAC: невозможно получить список кластеров:", result.stderr)
            return

        for line in result.stdout.splitlines():
            if "cluster" in line.lower():
                cluster_uuid = line.split(":")[1].strip()
                break

        if not cluster_uuid:
            print("RAC: кластер не найден")
            return

        print("Cluster UUID:", cluster_uuid)

        ib_uuid = None
        result = run([RAC_PATH, "infobase", "list", "--cluster", cluster_uuid])
        if result.returncode != 0:
            print("RAC: невозможно получить список ИБ:", result.stderr)
            return

        for line in result.stdout.splitlines():
            if infobase_name.lower() in line.lower():
                ib_uuid = line.split(":")[1].strip()
                break

        if not ib_uuid:
            print("RAC: база не зарегистрирована")
            return

        print("RAC: найдена IB", ib_uuid)

        print("RAC: убиваем сессии")
        run([
            RAC_PATH, "session", "terminate",
            "--cluster", cluster_uuid,
            "--infobase", ib_uuid,
            "--force"
        ])

        print("RAC: удаляем IB из кластера")
        run([
            RAC_PATH, "infobase", "drop",
            "--cluster", cluster_uuid,
            "--infobase", ib_uuid
        ])

        print("RAC cleanup завершён")
    except Exception as e:
        print("RAC cleanup пропущен из-за ошибки:", e)



# ---------- CLEAN ----------

def clean_gen_py():
    shutil.rmtree(os.path.expanduser(r"~\AppData\Local\Temp\gen_py"), ignore_errors=True)


def delete_folder(folder_path):
    shutil.rmtree(folder_path, ignore_errors=True)


def clean_1c_cache():
    user = os.getenv("USERNAME")
    base = fr"C:\Users\{user}\AppData"
    paths = [
        base + r"\Local\1C\1cv8",
        base + r"\Roaming\1C\1cv8",
        base + r"\Local\1C\1cv82",
        base + r"\Roaming\1C\1cv82",
    ]
    for path in paths:
        if os.path.exists(path):
            for item in os.listdir(path):
                if item not in ("ExtCompT", "1cv8strt.pfl"):
                    delete_folder(os.path.join(path, item))


# ---------- PostgreSQL ----------

def terminate_pg_sessions(db_name):
    os.environ["PGPASSWORD"] = PG_PASS
    run([
        "psql", "-h", PG_HOST, "-p", PG_PORT,
        "-U", PG_USER, "-d", "postgres",
        "-c",
        f"SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='{db_name}' AND pid<>pg_backend_pid();"
    ])


def drop_postgres(db_name):
    print("PostgreSQL drop:", db_name)
    os.environ["PGPASSWORD"] = PG_PASS
    for i in range(PG_RETRIES):
        terminate_pg_sessions(db_name)
        result = run([
            "psql", "-h", PG_HOST, "-p", PG_PORT,
            "-U", PG_USER, "-d", "postgres",
            "-c", f'DROP DATABASE IF EXISTS "{db_name}";'
        ])
        if result.returncode == 0:
            print("PostgreSQL удалена")
            return
        time.sleep(PG_WAIT_BETWEEN)
    print(result.stderr)
    sys.exit(2)


# ---------- 1C COM ----------

def drop_1c_infobase(name):
    com = agent = None
    pythoncom.CoInitialize()
    try:
        clean_gen_py()
        com = win32com.client.gencache.EnsureDispatch("V83.COMConnector")
        agent = com.ConnectAgent(AGENT_ADDR)
        cluster = agent.GetClusters()[0]
        agent.Authenticate(cluster, "", "")

        for wp_info in agent.GetWorkingProcesses(cluster):
            wp = com.ConnectWorkingProcess(f"tcp://{WP_HOST}:{wp_info.MainPort}")
            wp.AddAuthentication(DB_USER_1C, DB_PASS_1C)
            for base in wp.GetInfoBases():
                if base.Name.lower() == name.lower():
                    print("COM: база найдена")
                    with suppress(Exception):
                        for c in wp.GetInfoBaseConnections(base):
                            wp.TerminateConnection(c)
                    with suppress(Exception):
                        wp.DropInfoBase(base, 1)
                    return True
        return False
    finally:
        pythoncom.CoUninitialize()


# ================= ENTRY =================

if __name__ == "__main__":
    print("=== DROP DB START ===")

    infobase = sys.argv[1].strip()
    db = infobase.lower()

    drop_1c_infobase(infobase)

    print("Ожидание...")
    time.sleep(5)

    rac_force_drop(infobase)

    delete_folder("tests/build/results")

    drop_postgres(db)
    clean_1c_cache()

    print("=== DONE ===")
