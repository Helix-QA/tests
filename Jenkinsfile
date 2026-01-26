@Library('helix-shared-lib') _

pipeline {
  agent { label 'OneS' }

  stages {

    stage('Init') {
      steps {
        script {
          currentBuild.displayName = "#${BUILD_NUMBER} | ${params.VERSION_NEW}"

          def products = productsConfig()
          def cfg = products[params.product]

          env.repository = cfg.repository
          env.extmess   = cfg.extmess
          env.extName   = cfg.extName
          env.logo      = cfg.logo

          vanessa.updateConfig(
            product : params.product,
            dbTests : env.dbTests
          )
        }
      }
    }

    stage('Prepare DB') {
      steps {
        database.prepare(
          dbName     : env.dbTests,
          repository : env.repository,
          product    : params.product
        )
      }
    }

    stage('Scenario tests') {
      steps {
        vanessa.runScenarios(env.testPathPlaceholder)
      }
    }

    stage('Smoke tests') {
      when { expression { !params.scenarios } }
      steps {
        vanessa.runSmoke()
      }
    }
  }

  post {
    always {
      reports.publish()
      notifications.send()
    }
  }
}
