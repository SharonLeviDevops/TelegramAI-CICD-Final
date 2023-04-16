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
//     parameters {
//         string(name: 'WORKER_IMAGE_NAME', defaultValue: '', description: 'image sent from build')
//     }

    // TODO dev worker deploy stages here
    stages {
    stage('Bot Deploy') {
        steps {
            withCredentials([
                file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')
            ]) {
                sh '''
                # apply the configurations to k8s cluster
                    sed -i "s|image:.*|image: $WORKER_IMAGE_NAME|" infra/k8s/worker.yaml
                    sed -i 's|value:.*|value: "prod"|' infra/k8s/worker.yaml
                    echo $WORKER_IMAGE_NAME
                    cat infra/k8s/worker.yaml
                    kubectl apply --kubeconfig ${KUBECONFIG} -f infra/k8s/worker.yaml --namespace prod
                    echo $WORKER_IMAGE_NAME
                  '''
                }
            }
        }
    }
}