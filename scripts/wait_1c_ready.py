import subprocess
import sys
import time

# ---------- CONFIG ----------
RAC_PATH = r"C:\Program Files\1cv8\8.5.1.1150\bin\rac.exe"
RAC_ADDR = "localhost:1545"

MAX_WAIT_SECONDS = 60    # Можно увеличить, если сервер стартует медленно
SLEEP_INTERVAL = 3
ENCODING = 'cp1251'      # Кодировка вывода rac.exe (для русского 1C)
# ----------------------------

def run_rac(cmd):
    """Запуск rac.exe с декодированием в cp1251"""
    full_cmd = [RAC_PATH] + cmd + [RAC_ADDR]
    result = subprocess.run(full_cmd, capture_output=True)
    
    # Декодируем вручную с заменой ошибок
    stdout = result.stdout.decode(ENCODING, errors='replace') if result.stdout else ""
    stderr = result.stderr.decode(ENCODING, errors='replace') if result.stderr else ""
    
    return type('Result', (), {
        'returncode': result.returncode,
        'stdout': stdout,
        'stderr': stderr
    })()

def is_1c_ready():
    # 1. Проверяем подключение к RAS и наличие кластера
    result = run_rac(["cluster", "list"])
    if result.returncode != 0:
        print("RAC: ошибка подключения к RAS или команда cluster list:", result.stderr.strip() or "нет вывода")
        return False

    if not result.stdout.strip():
        print("RAC: пустой вывод от cluster list")
        return False

    cluster_uuid = None
    for line in result.stdout.splitlines():
        if line.lower().startswith("cluster"):
            cluster_uuid = line.split(":", 1)[1].strip()
            break

    if not cluster_uuid:
        print("RAC: кластер не найден в выводе")
        print("Вывод:", result.stdout)
        return False

    print(f"RAC: кластер найден ({cluster_uuid})")

    # 2. Проверяем наличие рабочих процессов
    result = run_rac(["process", "list", "--cluster", cluster_uuid])
    if result.returncode != 0:
        print("RAC: ошибка получения списка процессов:", result.stderr.strip() or "нет вывода")
        return False

    if "process" not in result.stdout.lower():
        print("RAC: рабочие процессы ещё не запущены")
        print("Вывод process list:", result.stdout.strip() or "пусто")
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