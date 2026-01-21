import time
import pythoncom
import win32com.client
import sys
from contextlib import suppress

# ---------- CONFIG ----------
AGENT_ADDR = "localhost:1540"
WP_HOST = "localhost"
DB_USER_1C = "Админ"
DB_PASS_1C = ""
MAX_WAIT_SECONDS = 20   # Максимальное время ожидания 1С
SLEEP_INTERVAL = 3      # Интервал проверки
# ----------------------------

def is_1c_ready():
    pythoncom.CoInitialize()
    try:
        com = win32com.client.gencache.EnsureDispatch("V83.COMConnector")
        agent = com.ConnectAgent(AGENT_ADDR)
        clusters = agent.GetClusters()
        if not clusters:
            return False

        cluster = clusters[0]
        agent.Authenticate(cluster, "", "")

        wps = agent.GetWorkingProcesses(cluster)
        if not wps:
            return False

        for wp_info in wps:
            try:
                wp = com.ConnectWorkingProcess(f"tcp://{WP_HOST}:{wp_info.MainPort}")
                wp.AddAuthentication(DB_USER_1C, DB_PASS_1C)
                return True
            except:
                continue
        return False
    except:
        return False
    finally:
        with suppress(Exception):
            del wp
            del agent
            del com
        pythoncom.CoUninitialize()


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
