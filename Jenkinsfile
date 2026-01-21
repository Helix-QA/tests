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
                        env.testPathPlaceholder = "/${params.product}${params.debug}"
                        env.repository = repositoryReleaseFitness
                        env.extmess = "http://192.168.2.16/hran1c/repository.1ccr/fitness4_messenger_release"
                        env.extNameMess = "Мессенджер"
                        env.logo = "tests/notifications/logo.png"

                    } else if (params.product == 'salon') {
                        env.testPathPlaceholder = "\\tests\\features\\salon${params.debug}"
                        env.repository = repositoryReleaseSalon
                        env.extmess = "http://192.168.2.16/hran1c/repository.1ccr/salon_messenger_release"
                        env.extNameMess = "Мессенджер_СалонКрасоты"
                        env.logo = "tests/notifications/logo1.png"

                    } else {
                        env.testPathPlaceholder = "\\tests\\features\\stoma${params.debug}"
                        env.repository = repositoryReleaseStom
                        env.extmess = "http://192.168.2.16/hran1c/repository.1ccr/stomatology2_messenger_release"
                        env.extNameMess = "Мессенджер_Стоматология"
                        env.logo = "tests/notifications/logo2.png"
                    }
                }
            }
        }
	}
}