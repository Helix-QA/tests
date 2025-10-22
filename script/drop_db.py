import os
import subprocess
import sys
import shutil
import pythoncom
import win32com.client
from colorama import init, Fore, Style


init(autoreset=True)


def delete_folder(folder_path):
    """Удаляет указанную папку и её содержимое."""
    if os.path.exists(folder_path):
        try:
            shutil.rmtree(folder_path, ignore_errors=True)
            print(f"{Fore.GREEN}Папка {folder_path} успешно удалена{Style.RESET_ALL}")
        except Exception as e:
            print(f"{Fore.YELLOW}Не удалось удалить папку {folder_path}: {str(e)}{Style.RESET_ALL}")
    else:
        print(f"{Fore.YELLOW}Папка {folder_path} не существует{Style.RESET_ALL}")


def clean_1c_cache():
    """Очищает кэш 1С для текущего пользователя."""
    user = os.getenv('USERNAME')
    cache_paths = [
        f"C:\\Users\\{user}\\AppData\\Local\\1C\\1cv8",
        f"C:\\Users\\{user}\\AppData\\Roaming\\1C\\1cv8",
        f"C:\\Users\\{user}\\AppData\\Roaming\\1C\\1cv82",
        f"C:\\Users\\{user}\\AppData\\Local\\1C\\1cv82"
    ]

    for path in cache_paths:
        if not os.path.exists(path):
            continue

        try:
            for item in os.listdir(path):
                item_path = os.path.join(path, item)
                # Пропускаем важные файлы/папки
                if item in ('ExtCompT', '1cv8strt.pfl'):
                    continue
                try:
                    if os.path.isdir(item_path):
                        shutil.rmtree(item_path, ignore_errors=True)
                    else:
                        os.remove(item_path)
                except Exception as e:
                    print(f"{Fore.YELLOW}Не удалось удалить {item_path}: {str(e)}{Style.RESET_ALL}")
        except Exception as e:
            print(f"{Fore.YELLOW}Не удалось прочитать кэш в {path}: {str(e)}{Style.RESET_ALL}")


def drop_1c_database():
    # === Настройки ===
    infobase = sys.argv[1] if len(sys.argv) > 1 else None
    if not infobase:
        print(f"{Fore.RED}Ошибка: не указано имя базы. Использование: drop_db.py <ИмяБазы>{Style.RESET_ALL}")
        return False

    db_username = "Админ"
    db_password = ""

    pg_server = "localhost"
    pg_port = "5432"
    pg_user = "postgres"
    pg_password = "postgres"

    # COM-объекты
    v83_com = None
    agent = None
    wp = None

    try:
        pythoncom.CoInitialize()
        print(f"{Fore.CYAN}1. Подключение к агенту сервера 1С...{Style.RESET_ALL}")
        v83_com = win32com.client.gencache.EnsureDispatch("V83.ComConnector")
        agent = v83_com.ConnectAgent("localhost:1540")

        print(f"{Fore.CYAN}2. Получение списка кластеров...{Style.RESET_ALL}")
        clusters = agent.GetClusters()
        if not clusters:
            print(f"{Fore.YELLOW}Кластеры не найдены. Пропускаем удаление из 1С.{Style.RESET_ALL}")
        else:
            cluster = clusters[0]
            print(f"{Fore.CYAN}3. Аутентификация в кластере...{Style.RESET_ALL}")
            agent.Authenticate(cluster, "", "")

            print(f"{Fore.CYAN}4. Получение рабочих процессов...{Style.RESET_ALL}")
            processes = agent.GetWorkingProcesses(cluster)
            if not processes:
                print(f"{Fore.YELLOW}Рабочие процессы не найдены. Пропускаем удаление из 1С.{Style.RESET_ALL}")
            else:
                main_port = processes[0].MainPort
                print(f"{Fore.CYAN}5. Подключение к рабочему процессу (порт {main_port})...{Style.RESET_ALL}")
                wp = v83_com.ConnectWorkingProcess(f"tcp://localhost:{main_port}")
                wp.AddAuthentication(db_username, db_password)

                print(f"{Fore.CYAN}6. Поиск информационной базы '{infobase}'...{Style.RESET_ALL}")
                bases = wp.GetInfoBases()
                base_obj = next((b for b in bases if b.Name.lower() == infobase.lower()), None)

                if not base_obj:
                    print(f"{Fore.YELLOW}База '{infobase}' не найдена в кластере. Пропускаем удаление из 1С.{Style.RESET_ALL}")
                else:
                    # === Отключаем все соединения ===
                    print(f"{Fore.CYAN}7. Проверка активных соединений...{Style.RESET_ALL}")
                    try:
                        connections = wp.GetIDBConnections(base_obj)
                        if connections:
                            print(f"{Fore.YELLOW}Найдено {len(connections)} активных соединений. Разрываем...{Style.RESET_ALL}")
                            for conn in connections:
                                try:
                                    wp.TerminateConnection(conn)
                                except Exception as e:
                                    print(f"{Fore.RED}Не удалось разорвать соединение {getattr(conn, 'ConnectionID', '?')}: {e}{Style.RESET_ALL}")
                        else:
                            print(f"{Fore.GREEN}Активных соединений нет.{Style.RESET_ALL}")
                    except Exception as e:
                        print(f"{Fore.YELLOW}Не удалось получить список соединений: {e}{Style.RESET_ALL}")

                    # === Удаляем базу принудительно ===
                    print(f"{Fore.CYAN}8. Удаление базы '{infobase}' из кластера (принудительно)...{Style.RESET_ALL}")
                    try:
                        wp.DropInfoBase(base_obj, 1)  # 1 = принудительно
                        print(f"{Fore.GREEN}База успешно удалена из кластера 1С{Style.RESET_ALL}")
                    except Exception as e:
                        print(f"{Fore.RED}Ошибка при удалении из кластера: {e}{Style.RESET_ALL}")

        # === Удаление из PostgreSQL ===
        print(f"{Fore.CYAN}9. Удаление базы из PostgreSQL...{Style.RESET_ALL}")
        db_name = infobase.lower()
        try:
            os.environ['PGPASSWORD'] = pg_password

            # 1. Закрываем все соединения
            subprocess.run([
                'psql', '-h', pg_server, '-p', pg_port, '-U', pg_user,
                '-d', 'postgres',
                '-c', f"SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '{db_name}' AND pid <> pg_backend_pid();"
            ], check=False, capture_output=True)

            # 2. Удаляем саму БД
            result = subprocess.run([
                'psql', '-h', pg_server, '-p', pg_port, '-U', pg_user,
                '-d', 'postgres',
                '-c', f"DROP DATABASE IF EXISTS \"{db_name}\";"
            ], check=False, capture_output=True, text=True)

            if result.returncode == 0 and "DROP DATABASE" in result.stdout:
                print(f"{Fore.GREEN}База '{db_name}' успешно удалена из PostgreSQL{Style.RESET_ALL}")
            else:
                stderr = result.stderr.strip()
                if "does not exist" in stderr:
                    print(f"{Fore.YELLOW}База '{db_name}' не существует в PostgreSQL{Style.RESET_ALL}")
                else:
                    print(f"{Fore.YELLOW}PostgreSQL: {stderr or 'Неизвестная ошибка'}{Style.RESET_ALL}")
        except Exception as e:
            print(f"{Fore.YELLOW}Ошибка при работе с PostgreSQL: {e}{Style.RESET_ALL}")
        finally:
            os.environ.pop('PGPASSWORD', None)

        # === Удаление папки ===
        print(f"{Fore.CYAN}10. Удаление папки с результатами...{Style.RESET_ALL}")
        delete_folder("tests/build/results")

        # === Очистка кэша 1С ===
        print(f"{Fore.CYAN}11. Очистка кэша 1С...{Style.RESET_ALL}")
        clean_1c_cache()
        print(f"{Fore.GREEN}Кэш 1С успешно очищен{Style.RESET_ALL}")

        print(f"{Fore.GREEN}Скрипт успешно завершён{Style.RESET_ALL}")
        return True

    except Exception as e:
        print(f"{Fore.RED}Критическая ошибка: {str(e)}{Style.RESET_ALL}")
        return False

    finally:
        # === Гарантированное освобождение COM-объектов ===
        for obj in (wp, agent, v83_com):
            if obj is not None:
                try:
                    obj = None
                except:
                    pass
        try:
            pythoncom.CoUninitialize()
        except:
            pass


# === ЗАПУСК ===
if __name__ == "__main__":
    print(f"{Fore.BLUE}=== Начало удаления базы 1С и PostgreSQL ==={Style.RESET_ALL}")
    success = drop_1c_database()
    if success:
        print(f"{Fore.BLUE}=== Удаление завершено успешно ==={Style.RESET_ALL}")
        sys.exit(0)
    else:
        print(f"{Fore.RED}=== Удаление завершено с ошибками ==={Style.RESET_ALL}")
        sys.exit(1)