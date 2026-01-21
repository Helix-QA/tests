pipeline {
    agent {
        label "OneS"
    }
	environment {
        
		
    }
    stages {
		 stage('Инициализация параметров') {
            steps {
                script {
					currentBuild.displayName = "#${BUILD_NUMBER} – ${params.product} – ${params.VERSION_NEW} ${params.debug}"
                    if (params.product == 'fitness') {
                        env.testPathPlaceholder = "features/${params.product}${params.debug}"
                        env.repository = repositoryReleaseFitness
                        env.extmess = "http://192.168.2.16/hran1c/repository.1ccr/fitness4_messenger_release"
                        env.extNameMess = "Мессенджер"
                        env.logo = "tests/notifications/logo.png"

                    } else if (params.product == 'salon') {
                        env.testPathPlaceholder = "features/${params.product}${params.debug}"
                        env.repository = repositoryReleaseSalon
                        env.extmess = "http://192.168.2.16/hran1c/repository.1ccr/salon_messenger_release"
                        env.extNameMess = "Мессенджер_СалонКрасоты"
                        env.logo = "tests/notifications/logo1.png"

                    } else {
                        env.testPathPlaceholder = "features/${params.product}${params.debug}"
                        env.repository = repositoryReleaseStom
                        env.extmess = "http://192.168.2.16/hran1c/repository.1ccr/stomatology2_messenger_release"
                        env.extNameMess = "Мессенджер_Стоматология"
                        env.logo = "tests/notifications/logo2.png"
                    }
                }
            }
        }
		stage("Создание БД") {
            steps {
                script {
                    def drop_db = "tests/scripts/drop_db.py"
                    def versionFile = "script/${params.product}.txt" // перенести в git
				    timeout(time: 2, unit: 'MINUTES') {
                        retry(3) {
                            try {
								echo "Удаление существующей базы"
								bat """
								chcp 65001
								set PYTHONIOENCODING=utf-8
								set PYTHONUTF8=1
								cmd /c python -X utf8 "${drop_db}" "${env.dbTests}"
								"""
                            } catch (e) {
                                echo "drop_db упал, перезапуск агента 1С"
                                bat 'python -X utf8 tests/scripts/AgentRestart.py'
                                wait1C()
                                throw e
                            }
                        }
                    }

                    wait1C()
                    echo "Создание базы данных"
                    runDbOperation("create", "\"${env.dbTests}\"")
                    wait1C()
                    echo "Отключение сессий"
                    runDbOperation("session_kill", "\"${env.dbTests}\"")
                    echo "Загрузка .dt"
                    runDbOperation("restore", "\"${params.product}\" \"${env.dbTests}\"")
                    echo "Обновление конфигурации"
                    runDbOperation("updatedb", "\"${env.dbTests}\"")
                    echo "Загрузка из хранилища"
                    runDbOperation("loadrepo","\"${env.repository}\" \"${env.VATest}\" \"${env.dbTests}\"")
					echo "Обновление конфигурации"
                    runDbOperation("updatedb", "\"${env.dbTests}\"")
                    wait1C()
                    echo "Разблокирование входа"
                    runDbOperation("session_unlock", "\"${env.dbTests}\"")

                    echo "Проверка версии"
                    if (fileExists(versionFile)) {
                        env.version = readFile(versionFile).trim()
                    } else {
                        env.version = "1.0.0"
                    }

                    if (params.VERSION_NEW > env.version) {
                        retry(2) {
                            try {
                                runDbOperation("update1C", "\"${env.dbTests}\" \"${env.epfvrunner}\"")
                                runDbOperation("run", "\"${env.dbTests}\"")
                                runDbOperation("dump", "\"${params.product}\" \"${env.dbTests}\"")
                                writeFile file: versionFile, text: params.VERSION_NEW
                            } catch (e) {
                                echo "vanessa-runner временно не доступен, повтор через 30 сек"
                                sleep 30
                                wait1C()
                                throw e
                            }
                        }
                    }
                }
            }
        }
	}
}