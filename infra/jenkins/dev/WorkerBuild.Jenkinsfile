pipeline {
    agent {
        docker {
            // TODO build & push your Jenkins agent image, place the URL here
            image '700935310038.dkr.ecr.us-east-2.amazonaws.com/jenkins-project-cicd:latest'
            args  '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    environment {
        IMAGE_NAME = 'jenkins-project-worker-dev'
        REPO_URL = '700935310038.dkr.ecr.us-east-2.amazonaws.com'
        IMAGE_TAG = '${BUILD_NUMBER}'
        DOCKER_ENV = 'dev'
    }
    stages {
        stage('Build') {
            steps {
                sh '''
                    aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin ${REPO_URL}
                    sed -i \"s/^COPY config-\\(.*\\)\\.json/COPY config-\${DOCKER_ENV}.json/\" ./worker/Dockerfile
                    docker build -t ${IMAGE_NAME} -f ./worker/Dockerfile .
                    docker tag ${IMAGE_NAME} ${REPO_URL}/${IMAGE_NAME}:${BUILD_NUMBER}
                    docker push ${REPO_URL}/${IMAGE_NAME}:${BUILD_NUMBER}
                '''

            }
        }
        stage('Trigger Deploy') {
            steps {
                build job: 'workerDeploy', wait: false, parameters: [
                    string(name: 'WORKER_IMAGE_NAME', value: "${REPO_URL}/${IMAGE_NAME}:${BUILD_NUMBER}")
                ]
            }
        }
    }
}