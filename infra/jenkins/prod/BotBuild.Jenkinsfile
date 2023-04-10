pipeline {
    agent {
        docker {
            // TODO build & push your Jenkins agent image, place the URL here
            image '700935310038.dkr.ecr.us-west-1.amazonaws.com/jenkins-project-cicd:latest'
            args  '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    environment {
        IMAGE_NAME = 'jenkins-project-prod'
        REPO_URL = '700935310038.dkr.ecr.us-west-1.amazonaws.com'
        IMAGE_TAG = '${BUILD_NUMBER}'
                }
    stages {
        stage('Build') {
            steps {
                // TODO dev bot build stage
                sh '''
                    aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin ${REPO_URL}
                    docker build -t ${IMAGE_NAME} -f ./bot/Dockerfile .
                    docker tag ${IMAGE_NAME} ${REPO_URL}/${IMAGE_NAME}:${BUILD_NUMBER}
                    docker push ${REPO_URL}/${IMAGE_NAME}:${BUILD_NUMBER}
                '''
               //  Pass the image name as a string parameter to the deploy stage
                build job: 'botDeploy', parameters: [string(name: 'BOT_IMAGE_NAME', value: "${REPO_URL}/${IMAGE_NAME}:${BUILD_NUMBER}")], wait: false
            }
        }
    }
}