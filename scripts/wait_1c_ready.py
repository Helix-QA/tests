import subprocess
import sys
import time

# ---------- CONFIG ----------
RAC_PATH = r"C:\Program Files\1cv8\8.5.1.1150\bin\rac.exe"  # Путь из вашего предыдущего скрипта
RAC_ADDR = "localhost:1545"                                      # Адрес RAS

MAX_WAIT_SECONDS = 60    # Увеличил до 60 сек — сервер может стартовать дольше
SLEEP_INTERVAL = 3
# ----------------------------

def run_rac(cmd):
    """Запуск rac.exe с захватом вывода и кода возврата"""
    result = subprocess.run([RAC_PATH] + cmd + [RAC_ADDR], capture_output=True, text=True)
    return result

def is_1c_ready():
    # 1. Проверяем наличие кластера
    result = run_rac(["cluster", "list"])
    if result.returncode != 0:
        print("RAC: ошибка подключения к RAS:", result.stderr.strip())
        return False

    cluster_uuid = None
    for line in result.stdout.splitlines():
        if line.lower().startswith("cluster"):
            cluster_uuid = line.split(":")[1].strip()
            break

    if not cluster_uuid:
        print("RAC: кластер не найден в списке")
        return False

    print(f"RAC: кластер найден ({cluster_uuid})")

    # 2. Проверяем наличие рабочих процессов (опционально, но надёжнее)
    result = run_rac(["process", "list", "--cluster", cluster_uuid])
    if result.returncode != 0:
        print("RAC: ошибка получения списка процессов:", result.stderr.strip())
        return False

    if "process" not in result.stdout.lower():
        print("RAC: рабочие процессы ещё не запущены")
        return False

    print("RAC: рабочие процессы запущены")
    return True


if __name__ == "__main__":
    print("=== ОЖИДАНИЕ ГОТОВНОСТИ 1С ===")
    start_time = time.time()

    while time.time() - start_time < MAX_WAIT_SECONDS:
        if is_1c_ready():
            print("✅ 1С готова")
            sys.exit(0)

        print(f"⏳ 1С ещё не готова, ждём {SLEEP_INTERVAL} сек...")
        time.sleep(SLEEP_INTERVAL)

    print(f"❌ 1С не готова после {MAX_WAIT_SECONDS} секунд")
    sys.exit(1)