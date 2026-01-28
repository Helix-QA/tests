import os
import subprocess
import sys
import shutil
import time
import re
from contextlib import suppress

# ================== CONFIG ==================
PG_HOST = "localhost"
PG_PORT = "5432"
PG_USER = "postgres"
PG_PASS = "postgres"

RAC_PATH = r"C:\Program Files\1cv8\8.5.1.1150\bin\rac.exe"
RAS_ADDR = "localhost:1545"

RAC_RETRIES = 3
RAC_RETRY_WAIT = 5

PG_RETRIES = 5
PG_RETRY_WAIT = 5

ENCODING = "utf-8"
# ============================================


# ---------- LOW LEVEL ----------
def run(cmd):
    return subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        encoding=ENCODING,
        errors="replace"
    )


def extract_uuid(text):
    m = re.search(r"[0-9a-fA-F-]{36}", text)
    return m.group(0) if m else None


def run_rac_global(args):
    return run([RAC_PATH] + args + [RAS_ADDR])


def run_rac_cluster(args):
    return run([RAC_PATH, RAS_ADDR] + args)


# ---------- RAC QUERIES ----------
def get_cluster_uuid():
    res = run_rac_global(["cluster", "list"])
    return extract_uuid(res.stdout) if res.returncode == 0 else None


def rac_infobase_exists(db_name):
    cluster = get_cluster_uuid()
    if not cluster:
        return False

    res = run_rac_cluster(["infobase", f"--cluster={cluster}", "list"])
    return db_name.lower() in res.stdout.lower()


def get_infobase_uuid(cluster_uuid, db_name):
    res = run_rac_cluster(["infobase", f"--cluster={cluster_uuid}", "list"])
    if res.returncode != 0:
        return None

    last_uuid = None
    for line in res.stdout.splitlines():
        uuid = extract_uuid(line)
        if uuid:
            last_uuid = uuid
            continue

        if "db-name" in line.lower() and db_name.lower() in line.lower():
            return last_uuid

    return None


# ---------- RAC DROP ----------
def rac_drop_infobase(db_name):
    print("=== RAC CLEANUP ===")

    cluster = get_cluster_uuid()
    if not cluster:
        print("RAC: кластер не найден")
        return False

    print(f"RAC: кластер найден ({cluster})")

    ib_uuid = get_infobase_uuid(cluster, db_name)
    if not ib_uuid:
        print("RAC: инфобаза не найдена")
        return True

    print(f"RAC: инфобаза найдена ({ib_uuid})")

    # terminate sessions
    run_rac_cluster([
        "session",
        f"--cluster={cluster}",
        f"--infobase={ib_uuid}",
        "terminate",
        "--force"
    ])

    # drop infobase
    res = run_rac_cluster([
        "infobase",
        f"--cluster={cluster}",
        f"--infobase={ib_uuid}",
        "drop",
        "--drop-database"
    ])

    if res.returncode != 0:
        print("RAC: ошибка удаления:", res.stderr)
        return False

    return True


def rac_force_drop(db_name):
    for attempt in range(1, RAC_RETRIES + 1):
        print(f"RAC attempt {attempt}/{RAC_RETRIES}")
        rac_drop_infobase(db_name)
        time.sleep(RAC_RETRY_WAIT)

        if not rac_infobase_exists(db_name):
            print("RAC: инфобаза удалена")
            return True

    print("RAC: инфобаза всё ещё зарегистрирована")
    return False


# ---------- POSTGRES ----------
def terminate_pg_sessions(db):
    os.environ["PGPASSWORD"] = PG_PASS
    run([
        "psql", "-h", PG_HOST, "-p", PG_PORT,
        "-U", PG_USER, "-d", "postgres",
        "-c",
        f"SELECT pg_terminate_backend(pid) FROM pg_stat_activity "
        f"WHERE datname='{db}' AND pid<>pg_backend_pid();"
    ])


def drop_postgres(db):
    print("PostgreSQL drop:", db)
    os.environ["PGPASSWORD"] = PG_PASS

    for i in range(PG_RETRIES):
        terminate_pg_sessions(db)
        res = run([
            "psql", "-h", PG_HOST, "-p", PG_PORT,
            "-U", PG_USER, "-d", "postgres",
            "-c", f'DROP DATABASE IF EXISTS "{db}";'
        ])
        if res.returncode == 0:
            print("PostgreSQL удалена")
            return True
        time.sleep(PG_RETRY_WAIT)

    print("PostgreSQL не смог удалить БД")
    return False


# ---------- CLEAN ----------
def delete_folder(path):
    with suppress(Exception):
        shutil.rmtree(path)


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


# ================= ENTRY =================
if __name__ == "__main__":
    print("=== DROP DB START ===")

    if len(sys.argv) < 2:
        print("Usage: drop_db.py <infobase>")
        sys.exit(1)

    infobase = sys.argv[1].strip()
    db = infobase.lower()

    # 1. RAC (несколько попыток)
    if not rac_force_drop(db):
        print("FATAL: не удалось удалить инфобазу из RAC")
        sys.exit(2)

    # 2. PostgreSQL
    drop_postgres(db)

    # 3. cleanup
    delete_folder("build/results")
    clean_1c_cache()

    print("=== DONE ===")
    sys.exit(0)
