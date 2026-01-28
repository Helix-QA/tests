pipeline {
    agent {
        label "OneS"
    }
    stages {
		 stage('Инициализация параметров') {
            steps {
                script {
					currentBuild.displayName = "#${BUILD_NUMBER} | ${params.VERSION_NEW} | ${params.debug}"
					updateConfigFile()
					env.testPathPlaceholder = "\\features\\${params.product}${params.debug}"
                    if (params.product == 'fitness') {       
                        env.repository = repositoryReleaseFitness
                        env.extmess = "http://192.168.2.16/hran1c/repository.1ccr/fitness4_messenger_release"
                        env.extNameMess = "Мессенджер"
                        env.logo = "doc/logo.png"

                    } else if (params.product == 'salon') {
                        env.repository = repositoryReleaseSalon
                        env.extmess = "http://192.168.2.16/hran1c/repository.1ccr/salon_messenger_release"
                        env.extNameMess = "Мессенджер_СалонКрасоты"
                        env.logo = "doc/logo1.png"

                    } else {
                        env.repository = repositoryReleaseStom
                        env.extmess = "http://192.168.2.16/hran1c/repository.1ccr/stomatology2_messenger_release"
                        env.extNameMess = "Мессенджер_Стоматология"
                        env.logo = "doc/logo2.png"
                    }
                }
            }
        }
		stage("Создание БД") {
            steps {
                script {
					def drop_db = "scripts/drop_db.py"
					def rac = '"C:\\Program Files\\1cv8\\8.5.1.1150\\bin\\rac.exe"'
					def dbName = env.dbTests

					timeout(time: 5, unit: 'MINUTES') {
					retry(3) {
						echo "🔄 Принудительный перезапуск агента 1С"
						bat 'python -X utf8 scripts/AgentRestart.py'
						wait1C()

						echo "🗑️ Удаление базы ${dbName}"
						bat """
						chcp 65001
						set PYTHONIOENCODING=utf-8
						set PYTHONUTF8=1
						cmd /c python -X utf8 "${drop_db}" "${dbName}"
						"""

						echo "🔍 Проверка: база НЕ должна быть зарегистрирована в RAC"
						bat """
						${rac} infobase list localhost:1545 ^
						| findstr /R /C:"name *= *${dbName}$" >nul && exit /b 1 || exit /b 0
						"""
					}

						echo "🛑 Финальная проверка перед созданием"
						bat """
						${rac} infobase list localhost:1545 ^
						| findstr /R /C:"name *= *${dbName}$" >nul && (
							echo ❌ БАЗА ВСЁ ЕЩЁ В RAC. АВАРИЙНЫЙ СТОП.
							exit /b 1
						) || exit /b 0
						"""

						echo "✅ Создание новой базы ${dbName}"
						bat """
						chcp 65001
						call vrunner create --db-server localhost ^
							--name ${dbName} ^
							--dbms PostgreSQL ^
							--db-admin postgres ^
							--db-admin-pwd postgres ^
							--uccode tester
						"""
						wait1C()

						echo "🔪 Отключение сессий"
						bat """
						chcp 65001
						call vrunner session kill ^
							--db ${dbName} ^
							--db-user Админ ^
							--uccode tester
						"""
						wait1C()

						echo "📦 Загрузка .dt"
						bat """
						chcp 65001
						call vrunner restore ^
							"D:/Vanessa-Automation/DT/${params.product}.dt" ^
							--ibconnection /Slocalhost/${dbName} ^
							--uccode tester
						"""
						wait1C()

						// ====== ОБНОВЛЕНИЕ КОНФИГУРАЦИИ ======
						echo "🔄 Обновление конфигурации"
						bat """
						chcp 65001
						call vrunner updatedb ^
							--ibconnection /Slocalhost/${dbName} ^
							--db-user Админ ^
							--uccode tester
						"""
						wait1C()
						echo "Разблокирование входа"
						bat """
						chcp 65001
						call vrunner session unlock ^
							--db ${env.dbTests} ^
							--db-user Админ ^
							--uccode tester
						"""
					}
                    echo "Проверка версии"
                    if (fileExists(versionFile)) {
                        env.version = readFile(versionFile).trim()
                    } else {
                        env.version = "1.0.0"
                    }

                    if (params.VERSION_NEW > env.version) {
                        retry(2) {
                            try {
								echo "Обновление в режиме Предприятие"
								bat """
								chcp 65001
								call vrunner run ^
									--command ЗавершитьРаботуСистемы; ^
									--ibconnection /Slocalhost/${env.dbTests} ^
									--db-user Админ ^
									--execute "C:\\Program Files\\OneScript\\lib\\vanessa-runner\\epf\\ЗакрытьПредприятие.epf" ^
									--uccode tester
								"""
								echo "Убираем окно перемещения"
								bat """
								chcp 65001
								call vrunner run ^
									--ibconnection /Slocalhost/${env.dbTests} ^
									--db-user Админ ^
									--execute "C:\\Program Files\\OneScript\\lib\\vanessa-runner\\epf\\УбратьОкноПеремещенияИБ.epf" ^
									--uccode tester
								"""
								echo "Отключение сессий"
								bat """
								chcp 65001
								call vrunner session kill ^
									--db ${env.dbTests} ^
									--db-user Админ ^
									--uccode tester
								"""
								wait1C()
								echo "Выгружаем .dt"
								bat """
								chcp 65001
								call vrunner dump ^
									"D:\\Vanessa-Automation\\DT\\${params.product}.dt" ^
									--ibconnection /Slocalhost/${env.dbTests} ^
									--db-user Админ ^
									--uccode tester
								"""
								echo "Разблокирование входа"
								bat """
								chcp 65001
								call vrunner session unlock ^
									--db ${env.dbTests} ^
									--db-user Админ ^
									--uccode tester
								"""

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
		stage('Сценарное тестирование') {
            steps {
                script {
                        try {
							bat """
							chcp 65001
							call vrunner vanessa ^
								--path "${env.WORKSPACE}${env.testPathPlaceholder}" ^
								--vanessasettings "${env.WORKSPACE}\\scripts\\VAParams.json" ^
								--workspace ${env.WORKSPACE} ^
								--pathvanessa ${env.pathvanessa} ^
								--additional "/DisplayAllFunctions /L ru" ^
								--ibconnection /Slocalhost/${env.dbTests} ^
								--db-user Админ ^
								--uccode tester
							"""
 						} catch (Exception Exc) {
							echo "Error occurred: ${Exc.message}"
							currentBuild.result = 'UNSTABLE'
          				}
                }
            }
        }
		stage("Дымовые тесты") {
            when { expression { !params.scenarios } }
			steps {
				script {
					def replace = "scripts/replaceSmoke.py"
					def smokeTests = "${env.WORKSPACE}features\\smoke\\exceptions_${params.product}"
					def folderSmoke = "features\\smoke\\exceptions_${params.product}"
					runDbOperation("smoke", " \"${env.WORKSPACE}\" \"${env.pathvanessa}\" \"${env.dbTests}\"")
					bat "python -X utf8 \"${replace}\" \"${smokeTests}\" \"${params.product}\""
					try{
						bat """
							chcp 65001
							call vrunner vanessa ^
								--path "${env.WORKSPACE}${folderSmoke}" ^
								--vanessasettings "${env.WORKSPACE}\\scripts\\VAParams.json" ^
								--workspace ${env.WORKSPACE} ^
								--pathvanessa ${env.pathvanessa} ^
								--additional "/DisplayAllFunctions /L ru" ^
								--ibconnection /Slocalhost/${env.dbTests} ^
								--db-user Админ ^
								--uccode tester
							"""
					} catch (Exception Exc) {
						echo "Error occurred: ${Exc.message}"
						currentBuild.result = 'UNSTABLE'
					}
				}
			}
        }
	}
	post {
        always {
            script {
                allure(includeProperties: false,   results:  [[path: 'build/results']])
                junit(allowEmptyResults: true, testResults: 'build/out/jUnint/*.xml')
				if (currentBuild.currentResult == "SUCCESS" || currentBuild.currentResult == "UNSTABLE") {
					def allureReportUrl = "${env.JENKINS_URL}job/${env.JOB_NAME.replaceAll('/', '/job/')}/${env.BUILD_NUMBER}/allure"
					def configJson = readFile(file: 'scripts/config.json')
					def updatedConfigJson = configJson
						.replace('"${allureReportUrl}"', "\"${allureReportUrl}\"")
						.replace('"${JOB_NAME}"', "\"${env.JOB_NAME}\"")
						.replace('"${token}"', "\"${env.botToken}\"")
						.replace('"${chat}"', "\"${env.testchatID}\"")
						.replace('"${logo}"', "\"${env.logo}\"")
					writeFile(file: 'scripts/config.json', text: updatedConfigJson)
					try {
						bat """java "-DconfigFile=scripts/config.json" "-Dhttp.connection.timeout=60000" "-Dhttp.socket.timeout=120000" -jar scripts/allure-notifications-4.8.0.jar"""
					}
					catch (Exception e) {
						echo "Ошибка при отправке уведомления: ${e.message}. Продолжаем выполнение pipeline."
					}
				}
			}
		}
	}
}

def wait1C() {
    bat 'python -X utf8 scripts/wait_1c_ready.py'
}

def updateConfigFile() {
 	def configJson = readFile(file: '\\scripts\\VAParams.json')
 	def escapedWorkspace = env.WORKSPACE.replace("\\", "\\\\").replace("\\", "\\\\")
  	def updatedConfigJson = configJson.replaceAll(/\$\{product\}/, params.product)
                              		.replaceAll(/\$\{workspace\}/, escapedWorkspace)
                             		.replaceAll(/\$\{dbTests\}/, env.dbTests)
	writeFile(file: '\\scripts\\VAParams.json', text: updatedConfigJson)
}
