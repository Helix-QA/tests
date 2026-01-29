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
                    def versionFile = "D:\\Vanessa-Automation\\version\\${params.product}.txt"

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
								echo "Создание базы данных"
								bat """
								chcp 65001
								call vrunner create --db-server localhost --name ${env.dbTests} --dbms PostgreSQL --db-admin postgres --db-admin-pwd postgres --uccode tester --v8version "${env.VERSION_PLATFORM}" --rac "${env.rac}" --nocacheuse
								"""
								echo "Отключение сессий"
								bat """
								chcp 65001
								call vrunner session kill ^
									--db ${env.dbTests} ^
									--db-user Админ ^
									--uccode tester ^
									--v8version "${env.VERSION_PLATFORM}" ^
									--nocacheuse
								"""
                            } catch (e) {
                                echo "drop_db упал, перезапуск агента 1С"
                                bat 'python -X utf8 scripts/AgentRestart.py'

                                throw e
                            }
                        }
                    }

                wait1C()
                    echo "Загрузка .dt"
                    bat """
                    chcp 65001
                    call vrunner restore ^
                        "D:/Vanessa-Automation/DT/${params.product}.dt" ^
                        --ibconnection /Slocalhost/${env.dbTests} ^
                        --uccode tester ^
                        --v8version "${env.VERSION_PLATFORM}" ^
                        --nocacheuse
                    """

                    echo "Обновление конфигурации"
                    bat """
                    chcp 65001
                    call vrunner updatedb ^
                        --ibconnection /Slocalhost/${env.dbTests} ^
                        --db-user Админ ^
                        --uccode tester ^
                        --v8version "${env.VERSION_PLATFORM}" ^
                        --nocacheuse
                    """

                    echo "Загрузка из хранилища"
                    bat """
                    chcp 65001
                    call vrunner loadrepo ^
                        --storage-name ${env.repository} ^
                        --storage-user ${env.VATest} ^
                        --ibconnection /Slocalhost/${env.dbTests} ^
                        --db-user Админ ^
                        --uccode tester ^
                        --v8version "${env.VERSION_PLATFORM}" ^
                        --nocacheuse
                    """

                    echo "Обновление конфигурации"
                    bat """
                    chcp 65001
                    call vrunner updatedb ^
                        --ibconnection /Slocalhost/${env.dbTests} ^
                        --db-user Админ ^
                        --uccode tester ^
                        --v8version "${env.VERSION_PLATFORM}" ^
                        --nocacheuse
                    """

                    echo "Разблокирование входа"
                    bat """
                    chcp 65001
                    call vrunner session unlock ^
                        --db ${env.dbTests} ^
                        --db-user Админ ^
                        --uccode tester ^
                        --v8version "${env.VERSION_PLATFORM}" ^
                        --nocacheuse
                    """

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
                                    --execute "epf/ЗакрытьПредприятие.epf" ^
                                    --uccode tester ^
                                    --v8version "${env.VERSION_PLATFORM}" ^
                                    --nocacheuse
                                """

                                echo "Убираем окно перемещения"
                                bat """
                                chcp 65001
                                call vrunner run ^
                                    --ibconnection /Slocalhost/${env.dbTests} ^
                                    --db-user Админ ^
                                    --execute "epf/УбратьОкноПеремещенияИБ.epf" ^
                                    --uccode tester ^
                                    --v8version "${env.VERSION_PLATFORM}" ^
                                    --nocacheuse
                                """

                                echo "Отключение сессий"
                                bat """
                                chcp 65001
                                call vrunner session kill ^
                                    --db ${env.dbTests} ^
                                    --db-user Админ ^
                                    --uccode tester ^
                                    --v8version "${env.VERSION_PLATFORM}" ^
                                    --nocacheuse
                                """

                                wait1C()
                                echo "Выгружаем .dt"
                                bat """
                                chcp 65001
                                call vrunner dump ^
                                    "D:\\Vanessa-Automation\\DT\\${params.product}.dt" ^
                                    --ibconnection /Slocalhost/${env.dbTests} ^
                                    --db-user Админ ^
                                    --uccode tester ^
                                    --v8version "${env.VERSION_PLATFORM}" ^
                                    --nocacheuse
                                """

                                echo "Разблокирование входа"
                                bat """
                                chcp 65001
                                call vrunner session unlock ^
                                    --db ${env.dbTests} ^
                                    --db-user Админ ^
                                    --uccode tester ^
                                    --v8version "${env.VERSION_PLATFORM}" ^
                                    --nocacheuse
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
                            --uccode tester ^
                            --v8version "${env.VERSION_PLATFORM}" ^
                            --nocacheuse
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
