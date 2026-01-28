import os
import subprocess
import sys
import shutil
import time

# ================== CONFIG ==================

# RAC/RAS host/cluster
RAC_PATH = r"C:\Program Files\1cv8\8.5.1.1150\bin\rac.exe"
RAC_CLUSTER_ADDR = "localhost:1545"

# PostgreSQL
PG_HOST = "localhost"
PG_PORT = "5432"
PG_USER = "postgres"
PG_PASS = "postgres"

# Ретраи для postgres DROP
PG_RETRIES = 6
PG_WAIT_BETWEEN = 5

# ============================================

# ---------- SERVICE UTILS ----------

def run(cmd, ignore_errors=False):
    """Запуск команды и возврат результата"""
    result = subprocess.run(cmd, capture_output=True, text=True)
    if ignore_errors and result.stderr:
        result.stderr = ""
    return result

# ---------- RAC CLEANUP ----------

def rac_force_drop(infobase_name: str):
    """Удаляет инфобазу через RAC (без COM)."""
    print("=== RAC CLEANUP ===")
    try:
        cluster_uuid = None

        # список кластеров
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

        # найти infobase UUID
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

        # убиваем сессии и удаляем базу из кластера
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
        print("RAC cleanup пропущен из‑за ошибки:", e)

# ---------- CLEAN ----------

def delete_folder(folder_path):
    """Удаляет папку с игнорированием ошибок."""
    shutil.rmtree(folder_path, ignore_errors=True)

def clean_1c_cache():
    """Очищает кэш 1С у текущего пользователя."""
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
                delete_folder(os.path.join(path, item))

# ---------- PostgreSQL ----------

def terminate_pg_sessions(db_name):
    """Завершает подключения к базе."""
    os.environ["PGPASSWORD"] = PG_PASS
    run([
        "psql", "-h", PG_HOST, "-p", PG_PORT,
        "-U", PG_USER, "-d", "postgres",
        "-c",
        f"SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='{db_name}' AND pid<>pg_backend_pid();"
    ])

def drop_postgres(db_name):
    """Удаляет PostgreSQL базу с ретраями."""
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

# ================= ENTRY =================

if __name__ == "__main__":
    print("=== DROP DB START ===")

    # имена
    infobase = sys.argv[1].strip()
    db = infobase.lower()

    print("Удаление через RAC...")
    rac_force_drop(infobase)

    print("Удаление результатов сборки...")
    delete_folder("build/results")

    print("Удаление PostgreSQL...")
    drop_postgres(db)

    print("Очистка кэша 1С...")
    clean_1c_cache()

    print("=== DONE ===")
