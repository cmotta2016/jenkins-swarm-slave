pipeline {
    agent { label 'docker' }
    environment {
        // Specify your environment variables.
        APP_VERSION = '1.1'
    }
    stages {
        stage('Build') {
            steps {
                // Print all the environment variables.
                sh 'printenv'
                sh 'echo $GIT_BRANCH'
                sh 'echo $GIT_COMMIT'
                echo 'Building the docker images with the current git commit'
                sh 'docker build -t cmotta2016/jenkins-slave:$GIT_COMMIT .'
            }
        }
        stage('Test') {
            steps {
                echo 'PHP Unit tests'
                sh 'echo "Test Ok"'
                sh 'sleep 5'
            }
        }
        stage('Push') {
            steps {
                withDockerRegistry([ credentialsId: "docker-hub-credentials", url: "" ]) {
                echo 'Deploying docker images'
                sh 'docker tag cmotta2016/jenkins-slave:$GIT_COMMIT cmotta2016/jenkins-slave:$APP_VERSION'
                sh 'docker tag cmotta2016/jenkins-slave:$GIT_COMMIT cmotta2016/jenkins-slave:latest'
                sh 'docker push cmotta2016/jenkins-slave:$APP_VERSION'
                sh 'docker push cmotta2016/jenkins-slave:latest'
                }
            }
        }
    }
    post {
        always {
            // Always cleanup after the build.
            sh 'docker rmi -f cmotta2016/jenkins-slave:$GIT_COMMIT cmotta2016/jenkins-slave:$APP_VERSION cmotta2016/jenkins-slave:latest'
        }
    }
}
