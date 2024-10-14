def TACTIC
def TACTICV1
def TACTICV2

pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub_ID'
        DOCKER_IMAGE = 'kadhemamri/ecommerce'
    }

    stages {

        stage('Checkout') {
            steps {
                echo '=== Checkout ==='
                checkout scm
                echo 'End Checkout'
            }
        }

        stage('Code Quality') {
            steps {
                    echo '=== Testing Code Quality ==='
                    sh "/opt/sonar-scanner/bin/sonar-scanner \
                        -Dsonar.projectKey=TAC-TIC \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://172.31.9.140:9000 \
                        -Dsonar.login= squ_f857c7717bc033cbe49446c11d9f156e90374033"
                    echo '=== Code Quality test Completed ==='
            }
        }

        stage('Docker Login') {
            steps {
                echo "==== Docker Login ==="
                withCredentials([usernamePassword(credentialsId: dockerhub_ID, usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD'
                }
                echo "==== Docker Logged in successfully ==="
            }
        }

        stage('Docker Image Build and Push') {

            steps {
                echo "==== Building Docker Image ==="
                sh "docker build --no-cache -t $DOCKER_IMAGE:${BUILD_NUMBER} ."
                echo "==== Pushing Docker Image ==="
                sh "docker push $DOCKER_IMAGE:${BUILD_NUMBER}"
                echo "==== Docker Image Built and Pushed ==="
            }
        }

        stage("Get last 3 success builds") {

            steps {
                script {
                    def builds = []
                    def job = Jenkins.instance.getItem('App')
                    job.builds.each {
                        if (it.result == hudson.model.Result.SUCCESS) {
                            builds.add(it.displayName[1..-1])
                        }
                    }

                    TACTIC = env.BUILD_NUMBER
                    TACTICV1 = builds[0]
                    TACTICV2 = builds[1]
                }

                echo "TACTIC : ${TACTIC}"
                echo "TACTICV1 : ${TACTICV1}"
                echo "TACTICV2 : ${TACTICV2}"
            }
        }


        stage ("lunch pipeline change manifests k8s for DEV") {

            steps {

                    build job: 'k8s-dev', parameters: [
                    string(name: 'TACTIC', value: "${TACTIC}"),
                    string(name: 'TACTICV1', value: "${TACTICV1}"),
                    string(name: 'TACTICV2', value: "${TACTICV2}")
                ]
            }
        }

    }
}

