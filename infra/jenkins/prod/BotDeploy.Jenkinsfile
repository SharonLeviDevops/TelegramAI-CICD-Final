pipeline {
    agent {
        docker {
            // TODO build & push your Jenkins agent image, place the URL here
            image '700935310038.dkr.ecr.us-west-2.amazonaws.com/jenkins-project-cicd:latest'
            args  '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        APP_ENV = "prod"
    }

    parameters {
        string(name: 'BOT_IMAGE_NAME', description: 'The name of the bot image to deploy')
    }

    stages {
        stage('Bot Deploy') {
            steps {
                withCredentials([
                    file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')
                ]) {
                    sh '''
                    # apply the configurations to k8s cluster..
                    echo ${BOT_IMAGE_NAME}
                    sed -i "s|image:.*|image: $BOT_IMAGE_NAME|" infra/k8s/bot.yaml
                    sed -i 's|value:.*|value: "prod"|' infra/k8s/bot.yaml
                    kubectl apply --kubeconfig ${KUBECONFIG} -f infra/k8s/bot.yaml --namespace prod
                    '''
                }
            }
        }
    }
}