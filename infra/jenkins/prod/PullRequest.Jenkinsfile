pipeline {
    agent {
        docker {
            // TODO build & push your Jenkins agent image, place the URL here
            image '700935310038.dkr.ecr.us-east-2.amazonaws.com/jenkins-project-cicd:latest'
            args  '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    stages {
        stage('Linting test') {
            agent {
                docker {
                    image 'python:3.9.16-slim-buster'
                    reuseNode true
                }
            }
            steps {
              sh '''
                  pip3 install pylint
                  touch pylint.log
                  python3 -m pylint -f parseable --reports=no **/*.py > pylint.log

                '''
            }

            // Make sure the "Warnings Next Generation" plugin is installed!!
            post {
              always {
                sh 'cat pylint.log'
                recordIssues (
                  enabledForFailure: true,
                  aggregatingResults: true,
                  tools: [pyLint(name: 'Pylint', pattern: '**/pylint.log')]
                )
              }
            }
        }
    }
}
