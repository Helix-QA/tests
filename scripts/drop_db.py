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

PG_RAC_RETRIES = 6
PG_WAIT_BETWEEN = 5
ENCODING = "utf-8"
# ============================================


# ---------- RAC HELPERS ----------
def run(cmd):
    return subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        encoding=ENCODING,
        errors="replace"
    )


def run_rac_global(args):
    return run([RAC_PATH] + args + [RAS_ADDR])


def run_rac_cluster(args):
    return run([RAC_PATH, RAS_ADDR] + args)


def extract_uuid(text):
    m = re.search(r"[0-9a-fA-F-]{36}", text)
    return m.group(0) if m else None


# ---------- RAC CLEANUP ----------
def rac_force_drop(infobase_name: str) -> bool:
    print("=== RAC CLEANUP ===")

    # 1. cluster list
    res = run_rac_global(["cluster", "list"])
    if res.returncode != 0:
        print("RAC cluster list error:", res.stderr)
        return False

    cluster_uuid = extract_uuid(res.stdout)
    if not cluster_uuid:
        print("RAC: кластер не найден")
        return False

    print(f"RAC: кластер найден ({cluster_uuid})")

    # 2. infobase list
    res = run_rac_cluster(["infobase", f"--cluster={cluster_uuid}", "list"])
    if res.returncode != 0:
        print("RAC infobase list error:", res.stderr)
        return False

    ib_uuid = None
    last_uuid = None

    for line in res.stdout.splitlines():
        uuid = extract_uuid(line)
        if uuid:
            last_uuid = uuid
            continue

        if "name" in line.lower() and infobase_name.lower() in line.lower():
            ib_uuid = last_uuid
            break

    if not ib_uuid:
        print("RAC: инфобаза не найдена — считаем успехом")
        return True

    print(f"RAC: инфобаза найдена ({ib_uuid})")

    # 3. terminate sessions
    print("RAC: завершение сессий")
    run_rac_cluster([
        "session",
        f"--cluster={cluster_uuid}",
        f"--infobase={ib_uuid}",
        "terminate",
        "--force"
    ])

    # 4. drop infobase
    print("RAC: удаление регистрации ИБ и БД")
    res = run_rac_cluster([
        "infobase",
        f"--cluster={cluster_uuid}",
        f"--infobase={ib_uuid}",
        "drop",
        "--drop-database"
    ])

    if res.returncode != 0:
        print("RAC drop error:", res.stderr)
        return False

    print("RAC cleanup OK")
    return True


# ---------- FILE CLEAN ----------
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


# ---------- POSTGRES FALLBACK ----------
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
    print("PostgreSQL fallback drop:", db)
    os.environ["PGPASSWORD"] = PG_PASS

    for _ in range(PG_RAC_RETRIES):
        terminate_pg_sessions(db)
        res = run([
            "psql", "-h", PG_HOST, "-p", PG_PORT,
            "-U", PG_USER, "-d", "postgres",
            "-c", f'DROP DATABASE IF EXISTS "{db}";'
        ])
        if res.returncode == 0:
            print("PostgreSQL удалена")
            return True
        time.sleep(PG_WAIT_BETWEEN)

    print("PostgreSQL fallback FAILED")
    return False


# ================= ENTRY =================
if __name__ == "__main__":
    print("=== DROP DB START ===")

    if len(sys.argv) < 2:
        print("Ошибка: укажите имя инфобазы")
        sys.exit(1)

    infobase = sys.argv[1].strip()
    db = infobase.lower()

    rac_ok = rac_force_drop(infobase)

    delete_folder("build/results")

    if not rac_ok:
        print("RAC не справился — пробуем fallback PostgreSQL")
        pg_ok = drop_postgres(db)

        # повторная попытка удалить регистрацию
        if not rac_force_drop(infobase):
            print("FATAL: инфобаза осталась зарегистрированной в RAC")
            sys.exit(3)

        if not pg_ok:
            sys.exit(2)

    clean_1c_cache()

    print("=== DONE ===")
    sys.exit(0)
