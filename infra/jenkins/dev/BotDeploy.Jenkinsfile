pipeline {
    agent {
        docker {
            // TODO build & push your Jenkins agent image, place the URL here
            image '700935310038.dkr.ecr.us-east-2.amazonaws.com/jenkins-project-cicd:latest'
            args  '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    parameters {
        string(name: 'BOT_IMAGE_NAME', defaultValue: '', description: 'image sent from build')
    }

    environment {
        APP_ENV = "dev"
    }

    stages {
        stage('Bot Deploy') {
            steps {
                withCredentials([
                    file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')
                ]) {
                    sh '''
                    # check if namespace exists, create if not
                    kubectl get namespace dev || kubectl create namespace dev
                    # apply the configurations to k8s cluster
                    sed -i "s|image:.*|image: $BOT_IMAGE_NAME|" infra/k8s/bot.yaml
                    sed -i 's|value:.*|value: "dev"|' infra/k8s/bot.yaml
                    kubectl apply --kubeconfig ${KUBECONFIG} -f infra/k8s/bot.yaml --namespace dev
                    '''
                }
            }
        }
    }
}