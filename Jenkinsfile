pipeline {
agent { label 'OneS' }

stages {
	stage('Init') {
		steps {
			script {
				currentBuild.displayName = "#${BUILD_NUMBER} | ${params.VERSION_NEW}"
				def products = load 'vars/products.groovy'
				def cfg = products[params.product]
				env.repository = cfg.repository
				env.extmess = cfg.extmess
				env.extName = cfg.extName
				env.logo = cfg.logo
				updateVAConfig()
			}
		}	
	}


	stage('Prepare DB') {
			steps {
				prepareDatabase()
			}
		}

	stage('Scenario tests') {
		steps {
			runVanessa(env.testPathPlaceholder)
		}
	}

	stage('Smoke tests') {
		when { expression { !params.scenarios } }
			steps {
				runSmoke()
				}
			}
	}
	post {
		always {
			publishReports()
			sendNotification()
		}
	}
}
def vrunner(String cmd) {
	bat """
	chcp 65001
	call vrunner ${cmd} ^
	--ibconnection /Slocalhost/${env.dbTests} ^
	--db-user Админ ^
	--uccode tester
	"""
}

def prepareDatabase() {
	retry(3) {
	bat 'python scripts/drop_db.py'
	vrunner "create --db-server localhost --name ${env.dbTests} --dbms PostgreSQL"
	vrunner "restore D:/Vanessa-Automation/DT/${params.product}.dt"
	vrunner "loadrepo --storage-name ${env.repository}"
	vrunner "updatedb"
	vrunner "session unlock --db ${env.dbTests}"
	}
}
def runVanessa(path) {
	vrunner "vanessa --path ${path} --vanessasettings scripts/VAParams.json"
}

def publishReports() {
  allure(includeProperties: false, results: [[path: 'build/results']])
  junit(allowEmptyResults: true, testResults: 'build/out/jUnint/*.xml')
}

def sendNotification() {
  if (currentBuild.currentResult in ['SUCCESS', 'UNSTABLE']) {
    def allureUrl = "${env.JENKINS_URL}job/${env.JOB_NAME.replaceAll('/', '/job/')}/${env.BUILD_NUMBER}/allure"

    def configJson = readFile('scripts/config.json')
      .replace('"${allureReportUrl}"', "\"${allureUrl}\"")
      .replace('"${JOB_NAME}"', "\"${env.JOB_NAME}\"")
      .replace('"${token}"', "\"${env.botToken}\"")
      .replace('"${chat}"', "\"${env.testchatID}\"")
      .replace('"${logo}"', "\"${env.logo}\"")

    writeFile file: 'scripts/config.json', text: configJson

    bat '''java "-DconfigFile=scripts/config.json" -jar scripts/allure-notifications-4.8.0.jar'''
  }
}
