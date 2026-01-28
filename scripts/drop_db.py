import os
import subprocess
import sys
import shutil
import time
from contextlib import suppress

# ================== CONFIG ==================
PG_HOST = "localhost"
PG_PORT = "5432"
PG_USER = "postgres"
PG_PASS = "postgres"

RAC_PATH = r"C:\Program Files\1cv8\8.5.1.1150\bin\rac.exe"
RAS_ADDR = "localhost:1545"  # Адрес RAS

PG_RAC_RETRIES = 6
PG_WAIT_BETWEEN = 5
ENCODING = "cp1251"
# ============================================

# ---------- RAC UTILS ----------
def run_rac_global(cmd):
    """Для глобальных команд (cluster list) — адрес в конце"""
    full_cmd = [RAC_PATH] + cmd + [RAS_ADDR]
    result = subprocess.run(full_cmd, capture_output=True)
    stdout = result.stdout.decode(ENCODING, errors="replace") if result.stdout else ""
    stderr = result.stderr.decode(ENCODING, errors="replace") if result.stderr else ""
    return type("Result", (), {
        "returncode": result.returncode,
        "stdout": stdout,
        "stderr": stderr
    })()

def run_rac_cluster(cmd, ignore_errors=False):
    """Для команд под кластером — адрес в начале"""
    full_cmd = [RAC_PATH, RAS_ADDR] + cmd
    result = subprocess.run(full_cmd, capture_output=True)
    stdout = result.stdout.decode(ENCODING, errors="replace") if result.stdout else ""
    stderr = result.stderr.decode(ENCODING, errors="replace") if result.stderr else ""
    if ignore_errors:
        stderr = ""
    return type("Result", (), {
        "returncode": result.returncode,
        "stdout": stdout,
        "stderr": stderr
    })()

# ---------- RAC FORCE CLEAN ----------
def rac_force_drop(infobase_name: str) -> bool:
    print("=== RAC CLEANUP ===")
    try:
        # 1. Получаем UUID кластера (адрес в конце)
        result = run_rac_global(["cluster", "list"])
        if result.returncode != 0:
            print("RAC: ошибка cluster list:", result.stderr or "нет вывода")
            return False

        cluster_uuid = None
        for line in result.stdout.splitlines():
            line = line.strip()
            if line.lower().startswith("cluster"):
                cluster_uuid = line.split(":", 1)[1].strip()
                break

        if not cluster_uuid:
            print("RAC: кластер не найден")
            return False

        print(f"RAC: кластер найден ({cluster_uuid})")

        # 2. Получаем список инфобаз (адрес в начале)
        result = run_rac_cluster(["infobase", "--cluster=" + cluster_uuid, "list"])
        if result.returncode != 0:
            print("RAC: ошибка infobase list:", result.stderr or "нет вывода")
            return False

        ib_uuid = None
        current_ib_uuid = None
        current_ib_name = None

        for line in result.stdout.splitlines():
            line = line.strip()
            if line.lower().startswith("infobase"):
                current_ib_uuid = line.split(":", 1)[1].strip()
            elif line.lower().startswith("name"):
                current_ib_name = line.split(":", 1)[1].strip()
                if current_ib_name.lower() == infobase_name.lower():
                    ib_uuid = current_ib_uuid
                    break

        if not ib_uuid:
            print("RAC: инфобаза не найдена или уже удалена — считаем успехом")
            return True

        print(f"RAC: найдена инфобаза '{current_ib_name}' ({ib_uuid})")

        # 3. Убиваем сессии
        print("RAC: убиваем сессии")
        run_rac_cluster([
            "session", "--cluster=" + cluster_uuid,
            "--infobase=" + ib_uuid,
            "terminate", "--force"
        ], ignore_errors=True)

        # 4. Удаляем инфобазу и БД
        print("RAC: удаляем регистрацию ИБ и базу данных")
        result = run_rac_cluster([
            "infobase", "--cluster=" + cluster_uuid,
            "--infobase=" + ib_uuid,
            "drop", "--drop-database"
        ])
        if result.returncode != 0:
            print("RAC: ошибка при drop infobase:", result.stderr or "нет вывода")
            return False

        print("RAC cleanup завершён успешно")
        return True

    except Exception as e:
        print("RAC cleanup исключение:", str(e))
        return False

# ---------- CLEAN ----------
def delete_folder(folder_path):
    with suppress(Exception):
        shutil.rmtree(folder_path)

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

# ---------- PostgreSQL fallback ----------
def terminate_pg_sessions(db_name):
    os.environ["PGPASSWORD"] = PG_PASS
    subprocess.run([
        "psql", "-h", PG_HOST, "-p", PG_PORT,
        "-U", PG_USER, "-d", "postgres",
        "-c",
        f"SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='{db_name}' AND pid<>pg_backend_pid();"
    ], capture_output=True)

def drop_postgres(db_name):
    print("PostgreSQL drop (fallback):", db_name)
    os.environ["PGPASSWORD"] = PG_PASS
    for i in range(PG_RAC_RETRIES):
        terminate_pg_sessions(db_name)
        result = subprocess.run([
            "psql", "-h", PG_HOST, "-p", PG_PORT,
            "-U", PG_USER, "-d", "postgres",
            "-c", f'DROP DATABASE IF EXISTS "{db_name}";'
        ], capture_output=True, text=True)
        if result.returncode == 0:
            print("PostgreSQL удалена (fallback)")
            return
        time.sleep(PG_WAIT_BETWEEN)
    print("PostgreSQL fallback не удался:", result.stderr)
    sys.exit(2)

# ================= ENTRY =================
if __name__ == "__main__":
    print("=== DROP DB START ===")

    if len(sys.argv) < 2:
        print("Ошибка: укажите имя инфобазы")
        sys.exit(1)

    infobase = sys.argv[1].strip()
    db = infobase.lower()

    success = rac_force_drop(infobase)

    delete_folder("build/results")

    if not success:
        print("RAC не полностью справился — fallback PostgreSQL")
        drop_postgres(db)

    clean_1c_cache()

    print("=== DONE ===")