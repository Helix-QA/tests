import os
import subprocess
import sys
import shutil
import time
import pythoncom
import win32com.client
import warnings
from contextlib import suppress

# ================== CONFIG ==================
PLATFORM_VERSION = sys.argv[1] if len(sys.argv) > 1 else "8.3"
AGENT_ADDR = "localhost:1540"
WP_HOST = "localhost"

DB_USER_1C = "Админ"
DB_PASS_1C = ""

PG_HOST = "localhost"
PG_PORT = "5432"
PG_USER = "postgres"
PG_PASS = "postgres"

RAC_PATH = rf"C:\Program Files\1cv8\{PLATFORM_VERSION}\bin\rac.exe"
RAC_CLUSTER_ADDR = "localhost:1545"

PG_RETRIES = 6
PG_WAIT_BETWEEN = 5
# ============================================

# Подавляем надоедливые Win32 IUnknown warning'и от 1C COM
warnings.filterwarnings("ignore", category=RuntimeWarning, message=".*IUnknown.*")


def run(cmd, ignore_errors=False, encoding="cp1251"):
    """Улучшенный запуск с русской кодировкой (работает даже с -X utf8)"""
    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        encoding=encoding,
        errors="replace"
    )
    if result.stderr and not ignore_errors:
        # Приводим к читаемому виду
        print(f"STDERR ({' '.join(cmd)}):")
        print(result.stderr.strip())
    return result


def check_1c_services():
    """Простая диагностика — запущен ли сервер 1С"""
    print("=== Проверка сервисов 1С ===")
    try:
        result = run(["sc", "query", "1C:Enterprise*Server*Agent"], ignore_errors=True)
        if result.returncode == 0 and "RUNNING" in result.stdout:
            print("✅ 1C Server Agent запущен")
        else:
            print("❌ 1C Server Agent НЕ запущен (или не найден)")
            print("   rac.exe не сможет работать. В Jenkins чаще всего нужно запускать сервис перед drop.")
    except Exception:
        print("Не удалось проверить сервисы 1С")


# ---------- RAC FORCE CLEAN ----------
def rac_force_drop(infobase_name: str):
    print("=== RAC CLEANUP ===")
    try:
        result = run([RAC_PATH, "cluster", "list", RAC_CLUSTER_ADDR])
        if result.returncode != 0 or not result.stdout.strip():
            print("❌ RAC: не удалось подключиться к кластеру (ошибка 10054 / сервер агент не запущен)")
            print("   → Пропускаем RAC-очистку (это нормально в CI)")
            return

        # Парсим cluster UUID
        cluster_uuid = None
        for line in result.stdout.splitlines():
            line = line.strip()
            if "cluster" in line.lower() and ":" in line:
                cluster_uuid = line.split(":", 1)[1].strip()
                break

        if not cluster_uuid:
            print("RAC: кластер не найден")
            return

        print("Cluster UUID:", cluster_uuid)

        # Ищем инфобазу
        ib_uuid = None
        result = run([RAC_PATH, "infobase", "list", "--cluster", cluster_uuid])
        for line in result.stdout.splitlines():
            line = line.strip()
            if infobase_name.lower() in line.lower() and ":" in line:
                ib_uuid = line.split(":", 1)[1].strip()
                break

        if not ib_uuid:
            print("RAC: база не зарегистрирована в кластере")
            return

        print("RAC: найдена IB", ib_uuid)

        print("RAC: убиваем сессии...")
        run([RAC_PATH, "session", "terminate", "--cluster", cluster_uuid, "--infobase", ib_uuid, "--force"], ignore_errors=True)

        print("RAC: удаляем IB из кластера...")
        run([RAC_PATH, "infobase", "drop", "--cluster", cluster_uuid, "--infobase", ib_uuid], ignore_errors=True)

        print("✅ RAC cleanup завершён")
    except Exception as e:
        print("RAC cleanup пропущен из-за ошибки:", e)


# ---------- Остальные функции (clean, postgres, com) без изменений ----------
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


def terminate_pg_sessions(db_name):
    os.environ["PGPASSWORD"] = PG_PASS
    run([
        "psql", "-h", PG_HOST, "-p", PG_PORT, "-U", PG_USER, "-d", "postgres",
        "-c", f"SELECT pg_terminate_backend(pid) FROM pg_stat_activity "
              f"WHERE datname='{db_name}' AND pid<>pg_backend_pid();"
    ], ignore_errors=True)


def drop_postgres(db_name):
    print("PostgreSQL drop:", db_name)
    os.environ["PGPASSWORD"] = PG_PASS
    for i in range(PG_RETRIES):
        terminate_pg_sessions(db_name)
        result = run([
            "psql", "-h", PG_HOST, "-p", PG_PORT, "-U", PG_USER, "-d", "postgres",
            "-c", f'DROP DATABASE IF EXISTS "{db_name}";'
        ])
        if result.returncode == 0:
            print("✅ PostgreSQL удалена (или уже отсутствовала)")
            return
        time.sleep(PG_WAIT_BETWEEN)
    print("Не удалось удалить PostgreSQL")
    sys.exit(2)


def drop_1c_infobase(name):
    com = agent = None
    pythoncom.CoInitialize()
    try:
        clean_gen_py()
        com = win32com.client.gencache.EnsureDispatch("V85.COMConnector")
        agent = com.ConnectAgent(AGENT_ADDR)
        cluster = agent.GetClusters()[0]
        agent.Authenticate(cluster, "", "")

        found = False
        for wp_info in agent.GetWorkingProcesses(cluster):
            wp = com.ConnectWorkingProcess(f"tcp://{WP_HOST}:{wp_info.MainPort}")
            wp.AddAuthentication(DB_USER_1C, DB_PASS_1C)
            for base in wp.GetInfoBases():
                if base.Name.lower() == name.lower():
                    print("COM: база найдена → удаляем")
                    with suppress(Exception):
                        for c in wp.GetInfoBaseConnections(base):
                            wp.TerminateConnection(c)
                    with suppress(Exception):
                        wp.DropInfoBase(base, 1)
                    found = True
                    break
            if found:
                break
        if not found:
            print("COM: база не найдена (нормально, если уже удалена или сервер неактивен)")
        return found
    finally:
        pythoncom.CoUninitialize()


# ================= ENTRY =================
if __name__ == "__main__":
    print("=== DROP DB START ===")

    if len(sys.argv) < 2:
        print("Использование: python drop_db.py <имя_инфобазы>")
        sys.exit(1)

    infobase = sys.argv[1].strip()
    db = infobase.lower()

    check_1c_services()          # ← новая диагностика

    drop_1c_infobase(infobase)

    print("Ожидание...")
    time.sleep(5)

    rac_force_drop(infobase)

    delete_folder("build/results")

    drop_postgres(db)
    clean_1c_cache()

    print("=== DONE ===")