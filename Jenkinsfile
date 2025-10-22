pipeline {
    agent {
        label "OneS"
    }
	environment {
        InitDatabase = "tests/scripts/InitDatabase.bat"
		
    }
    stages {
		stage('Подготовка .cf') {
				steps {
					script {
						updateConfigFile()
						
						if (params.product == 'fitness') {	
						env.testPathPlaceholder = "\\tests\\features\\fitness${params.debug}" // debug - тестовые запуски
						env.repository = "${repositoryReleaseFitness}"
						env.extmess = "http://192.168.2.16/hran1c/repository.1ccr/fitness4_messenger_release"
						env.extNameMess = "Мессенджер"
						env.dbTests = "QA_fitness"
						} 
						
						else if (params.product == 'salon') {
						env.testPathPlaceholder = "\\tests\\features\\salon${params.debug}" // test - тестовые запуски
						env.repository = "${repositoryReleaseSalon}"
						env.extmess = "http://192.168.2.16/hran1c/repository.1ccr/salon_messenger_release"
						extNameMess = "Мессенджер_СалонКрасоты"
						env.dbTests = "QA_salon"
						} 

						else {	
						env.testPathPlaceholder = "\\tests\\features\\stoma${params.debug}"
						env.repository = "${repositoryReleaseStom}"
						env.extmess = "http://192.168.2.16/hran1c/repository.1ccr/stomatology2_messenger_release"
						env.extNameMess = "Мессенджер_Стоматология"
						env.dbTests = "QA_stoma"
					}
				}
			}
		}
		stage('Определение и установка версий') {
			steps {
				script {
					def versionsFile = 'versions.json'
					def currentProduct = params.PRODUCT
					def currentVersion = params.VERSION.trim()

					// === ВАЛИДАЦИЯ ВЕРСИИ ПО ПРОДУКТУ ===
					if (!currentVersion) {
						error "ОШИБКА: Поле VERSION пустое! Укажите версию продукта."
					}

					def valid = false
					def expected = ""

					switch (currentProduct) {
						case 'fitness':
							valid = currentVersion ==~ /^4\.0\.\d+\.\d+$/
							expected = "4.0.X.Y (например: 4.0.57.1)"
							break
						case 'salon':
							valid = currentVersion ==~ /^(3|4)\.0\.\d+\.\d+$/
							expected = "3.0.X.Y или 4.0.X.Y (например: 3.0.44.1, 4.0.55.1)"
							break
						case 'stoma':
							valid = currentVersion ==~ /^2\.1\.\d+\.\d+$/
							expected = "2.1.X.Y (например: 2.1.27.1)"
							break
						default:
							error "ОШИБКА: Неизвестный продукт: ${currentProduct}"
					}

					if (!valid) {
						error """
						ОШИБКА: Неверный формат версии для продукта!
						→ Продукт: ${currentProduct}
						→ Указана: ${currentVersion}
						→ Ожидается: ${expected}
						
						Примеры:
						fitness → 4.0.56.1, 4.0.57.1
						salon   → 3.0.44.1, 4.0.55.1
						stoma   → 2.1.27.1, 2.1.28.1
						"""
					}

					echo "Валидация прошла: ${currentProduct} → ${currentVersion}"
					// =====================================

					// Инициализация структуры (с дефолтными значениями, если нет артефакта)
					def versions = [
						fitness: '4.0.57.1',
						salon:   '3.0.44.1',
						stoma:   '2.1.27.1'
					]

					// 1. Читаем предыдущие версии из артефакта
					try {
						copyArtifacts(
							projectName: env.JOB_NAME,
							selector: lastSuccessful(),
							filter: versionsFile
						)
						if (fileExists(versionsFile)) {
							def jsonText = readFile(versionsFile)
							versions = readJSON text: jsonText
							echo "Прочитаны предыдущие версии: ${versions}"
						}
					} catch (e) {
						echo "Нет предыдущего артефакта — это первый запуск. Используем дефолтные версии."
					}

					// 2. Сравниваем только нужный продукт
					def prevVersion = versions[currentProduct] ?: '0.0.0.0'
					echo "Продукт: $currentProduct | Было: $prevVersion | Стало: $currentVersion"

					if (currentVersion != prevVersion) {
						echo "Версия изменилась! Выполняем обновление БД..."

						runDbOperation("update1C", "\"${env.dbTests}\" \"${env.epfvrunner}\"")  // Обновление в режиме предприятия
						runDbOperation("run", "\"${env.dbTests}\"")                            // Убрать окон перемещения
						runDbOperation("dump", "\"${params.PRODUCT}\" \"${env.dbTests}\"")     // Выгружаем .dt нового релиза

						echo "Версия обновлена до ${currentVersion}"
					} else {
						echo "Версия $currentProduct не изменилась — пропускаем обновление БД."
					}

					// 3. Обновляем только нужное поле
					versions[currentProduct] = currentVersion

					// 4. Сохраняем обновлённый JSON
					writeFile file: versionsFile, text: groovy.json.JsonOutput.prettyPrint(toJson(versions))

					// 5. Архивируем для следующего билда
					archiveArtifacts artifacts: versionsFile, allowEmptyArchive: false
				}
			}
		}
        stage('Сценарное тестирвоание') {
            steps {
                script {
					try{
						runDbOperation("vanessa", "\"${env.WORKSPACE}\" \"${env.testPathPlaceholder}\" \"${env.pathvanessa}\" \"${env.dbTests}\"") // Сценарное тестирование																																
 					} catch (Exception Exc) {
						echo "Error occurred: ${Exc.message}"
						currentBuild.result = 'UNSTABLE'
          			}
                }
            }
		}
	
		// stage("Дымовые тесты") {
		// 	when {
		// 		expression { return !params.scenarios } // Выполняется, только если тумблер выключен
		// 	}
		// 	steps {
		// 		script {
		// 			def replace = "tests/scripts/replaceSmoke.py"
		// 			def smokeTests = "${env.WORKSPACE}\\tests\\features\\smoke\\exceptions_${params.product}"
		// 			def folderSmoke = "\\tests\\features\\smoke\\exceptions_${params.product}"
		// 			runDbOperation("smoke", " \"${env.WORKSPACE}\" \"${env.pathvanessa}\" \"${env.dbTests}\"")
		// 			bat "python -X utf8 \"${replace}\" \"${smokeTests}\" \"${params.product}\""
		// 			try{
		// 				runDbOperation("vanessa", "\"${env.WORKSPACE}\" \"${folderSmoke}\" \"${env.pathvanessa}\" \"${env.dbTests}\"") // Дымовые тесты
		// 			} catch (Exception Exc) {
		// 				echo "Error occurred: ${Exc.message}"
		// 				currentBuild.result = 'UNSTABLE'
		// 			}

		// 		}
		// 	}
		// }
	
    }
	post {
		always {
			script {
				allure([includeProperties: false, jdk: '', results: [['path': 'tests/build/results']]])
				// Отправка уведомлений только при SUCCESS или UNSTABLE
				if (currentBuild.currentResult == "SUCCESS" || currentBuild.currentResult == "UNSTABLE") {
					if ("${params.product}" == "fitness") {
						env.logo = "tests/notifications/logo.png"
					}
					else if ("${params.product}" == "salon") {
						env.logo = "tests/notifications/logo1.png"
					}
					else if ("${params.product}" == "stoma") {
						env.logo = "tests/notifications/logo2.png"
					}

					def allureReportUrl = "${env.JENKINS_URL}job/${env.JOB_NAME.replaceAll('/', '/job/')}/${env.BUILD_NUMBER}/allure"
					def configJson = readFile(file: 'tests/notifications/config.json')
					def updatedConfigJson = configJson
						.replace('"${allureReportUrl}"', "\"${allureReportUrl}\"")
						.replace('"${JOB_NAME}"', "\"${env.JOB_NAME}\"")
						.replace('"${logo}"', "\"${env.logo}\"")
					writeFile(file: 'tests/notifications/config.json', text: updatedConfigJson)

					try {
						bat """java "-DconfigFile=tests/notifications/config.json" "-Dhttp.connection.timeout=60000" "-Dhttp.socket.timeout=120000" -jar tests/notifications/allure-notifications-4.8.0.jar"""
					}
					catch (Exception e) {
						echo "Ошибка при отправке уведомления: ${e.message}. Продолжаем выполнение pipeline."
					}
				}
			}
		}
	 }
}

def runDbOperation(operation, params) {
		try {
			bat """
				chcp 65001
				@call ${env.InitDatabase} ${operation} ${params}
			"""
		} catch (Exception e) {
			echo "Ошибка при выполнении операции ${operation}: ${e.message}"
			throw e
		}
	}

def updateConfigFile() {
    def configJson = readFile(file: 'tests/tools/VAParams.json')
    def escapedWorkspace = env.WORKSPACE.replace("\\", "\\\\").replace("\\", "\\\\")
    def updatedConfigJson = configJson.replaceAll(/\$\{product\}/, params.product)
                              .replaceAll(/\$\{workspace\}/, escapedWorkspace)
    writeFile(file: 'tests/tools/VAParams.json', text: updatedConfigJson)
}
