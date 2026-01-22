pipeline {
    agent {
        label "OneS"
    }

    stages {
		 stage('Инициализация параметров') {
            steps {
                script {
					currentBuild.displayName = "#${BUILD_NUMBER} – ${params.product} – ${params.VERSION_NEW} ${params.debug}"
                    if (params.product == 'fitness') {
                        env.testPathPlaceholder = "\\features\\${params.product}${params.debug}"
                        env.repository = repositoryReleaseFitness
                        env.extmess = "http://192.168.2.16/hran1c/repository.1ccr/fitness4_messenger_release"
                        env.extNameMess = "Мессенджер"
                        env.logo = "tests/notifications/logo.png"

                    } else if (params.product == 'salon') {
                        env.testPathPlaceholder = "\\features\\${params.product}${params.debug}"
                        env.repository = repositoryReleaseSalon
                        env.extmess = "http://192.168.2.16/hran1c/repository.1ccr/salon_messenger_release"
                        env.extNameMess = "Мессенджер_СалонКрасоты"
                        env.logo = "tests/notifications/logo1.png"

                    } else {
                        env.testPathPlaceholder = "\\features\\${params.product}${params.debug}"
                        env.repository = repositoryReleaseStom
                        env.extmess = "http://192.168.2.16/hran1c/repository.1ccr/stomatology2_messenger_release"
                        env.extNameMess = "Мессенджер_Стоматология"
                        env.logo = "tests/notifications/logo2.png"
                    }
                }
            }
        }
		// stage("Создание БД") {
        //     steps {
        //         script {
        //             def drop_db = "scripts/drop_db.py"
        //             def versionFile = "D:\\Vanessa-Automation\\version\\${params.product}.txt" // перенести в git
		// 		    timeout(time: 2, unit: 'MINUTES') {
        //                 retry(3) {
        //                     try {
		// 						echo "Удаление существующей базы"
		// 						bat """
		// 						chcp 65001
		// 						set PYTHONIOENCODING=utf-8
		// 						set PYTHONUTF8=1
		// 						cmd /c python -X utf8 "${drop_db}" "${env.dbTests}"
		// 						"""
        //                     } catch (e) {
        //                         echo "drop_db упал, перезапуск агента 1С"
        //                         bat 'python -X utf8 scripts/AgentRestart.py'
        //                         wait1C()
        //                         throw e
        //                     }
        //                 }
        //             }

        //             wait1C()
		// 			echo "Создание базы данных"
		// 			bat """
		// 			chcp 65001
		// 			call vrunner create --db-server localhost ^
		// 				--name ${env.dbTests} ^
		// 				--dbms PostgreSQL ^
		// 				--db-admin postgres ^
		// 				--db-admin-pwd postgres ^
		// 				--uccode tester
		// 			"""
        //             echo "Отключение сессий"
		// 			bat """
		// 			chcp 65001
		// 			call vrunner session kill ^
		// 				--db ${env.dbTests} ^
		// 				--db-user Админ ^
		// 				--uccode tester
		// 			"""
        //             echo "Загрузка .dt"
		// 			bat """
		// 			chcp 65001
		// 			call vrunner restore ^
		// 				"D:/Vanessa-Automation/DT/${params.product}.dt" ^
		// 				--ibconnection /Slocalhost/${env.dbTests} ^
		// 				--uccode tester
		// 			"""
		// 			echo "Обновление конфигурации"
		// 			bat """
		// 			chcp 65001
		// 			call vrunner updatedb ^
		// 				--ibconnection /Slocalhost/${env.dbTests} ^
		// 				--db-user Админ ^
		// 				--uccode tester
		// 			"""
        //             echo "Загрузка из хранилища"
		// 			bat """
		// 			chcp 65001
		// 			call vrunner loadrepo ^
		// 				--storage-name ${env.repository} ^
		// 				--storage-user ${env.VATest} ^
		// 				--ibconnection /Slocalhost/${env.dbTests} ^
		// 				--db-user Админ ^
		// 				--uccode tester
		// 			"""
		// 			echo "Обновление конфигурации"
		// 			bat """
		// 			chcp 65001
		// 			call vrunner updatedb ^
		// 				--ibconnection /Slocalhost/${env.dbTests} ^
		// 				--db-user Админ ^
		// 				--uccode tester
		// 			"""
        //             echo "Разблокирование входа"
		// 			bat """
		// 			chcp 65001
		// 			call vrunner session unlock ^
		// 				--db ${env.dbTests} ^
		// 				--db-user Админ ^
		// 				--uccode tester
		// 			"""

        //             echo "Проверка версии"
        //             if (fileExists(versionFile)) {
        //                 env.version = readFile(versionFile).trim()
        //             } else {
        //                 env.version = "1.0.0"
        //             }

        //             if (params.VERSION_NEW > env.version) {
        //                 retry(2) {
        //                     try {
		// 						echo "Обновление в режиме Предприятие"
		// 						bat """
		// 						chcp 65001
		// 						call vrunner run ^
		// 							--command ЗавершитьРаботуСистемы; ^
		// 							--ibconnection /Slocalhost/${env.dbTests} ^
		// 							--db-user Админ ^
		// 							--execute "C:\\Program Files\\OneScript\\lib\\vanessa-runner\\epf\\ЗакрытьПредприятие.epf" ^
		// 							--uccode tester
		// 						"""
		// 						echo "Убираем окно перемещения"
		// 						bat """
		// 						chcp 65001
		// 						call vrunner run ^
		// 							--ibconnection /Slocalhost/${env.dbTests} ^
		// 							--db-user Админ ^
		// 							--execute "C:\\Program Files\\OneScript\\lib\\vanessa-runner\\epf\\УбратьОкноПеремещенияИБ.epf" ^
		// 							--uccode tester
		// 						"""
		// 						echo "Выгружаем .dt"
		// 						bat """
		// 						chcp 65001
		// 						call vrunner dump ^
		// 							"D:\\Vanessa-Automation\\DT\\${params.product}.dt" ^
		// 							--ibconnection /Slocalhost/${env.dbTests} ^
		// 							--db-user Админ ^
		// 							--uccode tester
		// 						"""

        //                         writeFile file: versionFile, text: params.VERSION_NEW
        //                     } catch (e) {
        //                         echo "vanessa-runner временно не доступен, повтор через 30 сек"
        //                         sleep 30
        //                         wait1C()
        //                         throw e
        //                     }
        //                 }
        //             }
        //         }
        //     }
        // }
		stage('Сценарное тестирование') {
            steps {
                script {
                        try {
							
							bat """
							chcp 65001
							call vrunner vanessa ^
								--path "${env.WORKSPACE}${env.testPathPlaceholder}" ^
								--vanessasettings "tools/VAParams.json" ^

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
                allure([
                    includeProperties: false,
                    results: [[path: 'tests/build/results']]])
            }
        }
    }
}


def wait1C() {
    bat 'python -X utf8 tools/wait_1c_ready.py'
}