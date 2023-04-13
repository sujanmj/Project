pipeline {

    agent any
/*
	tools {
        maven "maven3"
    }
*/
    environment {
        registry = 'sujanmj/cicd'
        registryCredential = 'DockerHub-key'
    }

    stages{
        stage('Checkout'){
            steps{
                cleanWs()
                git branch: 'cd-project', url: 'https://github.com/sujanmj/cicd-project.git'
                sh "git clone https://github.com/sujanmj/cicd-project.git -b cd-project"
            }
        }

        stage('BUILD'){
            steps {
                sh 'mvn clean install -DskipTests'
            }
            post {
                success {
                    echo 'Now Archiving...'
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            }
        }

        stage('UNIT TEST'){
            steps {
                sh 'mvn test'
            }
        }

        stage('INTEGRATION TEST'){
            steps {
                sh 'mvn verify -DskipUnitTests'
            }
        }

        stage ('CODE ANALYSIS WITH CHECKSTYLE'){
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
            post {
                success {
                    echo 'Generated Analysis Result'
                }
            }
        }

        stage('Building image') {
            steps{
              script {
                dockerImage = docker.build "$registry:V$BUILD_NUMBER"
              }
            }
        }
        
        stage('Deploy Image') {
          steps{
              withCredentials([string(credentialsId: 'Docker', variable: 'pass')]) {
              sh 'docker login -u sujanmj -p $pass' }
                
            script{
                dockerImage.push("V$BUILD_NUMBER")
                dockerImage.push('latest') }
              }
            }
        stage('Remove Unused docker image') {
          steps{
              sh 'docker image prune --all --force'
          }
        }

        stage('CODE ANALYSIS with SONARQUBE') {

            environment {
                scannerHome = tool 'sonarscanner 4.8'
            }

            steps {
                withSonarQubeEnv('sonarscanner') {
                    sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=Projectcd \
                   -Dsonar.projectName=cd-project \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.sources=src/ \
                   -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                   -Dsonar.junit.reportsPath=target/surefire-reports/ \
                   -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
                }

             /*   timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                } */
            }
        }
        stage('Kubernetes Deploy') {
            steps {
                sh "kubectl apply -f ./helm/templates"
            }
       }

   }

}