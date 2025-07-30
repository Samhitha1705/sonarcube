pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "vedasamhitha17/ems-backend:latest"
        REGISTRY_CREDENTIALS = 'fc16ea1a-882c-49c6-be5a-abb82a0083a4' // Docker credentials
        KUBECONFIG_CREDENTIALS = 'kubeconfig'
    }

    tools {
        maven 'Maven' // Must match the name in Jenkins Maven configuration
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/Samhitha1705/ems-backend-kubernetes.git', branch: 'main'
            }
        }

        stage('Build with Maven') {
            steps {
                bat 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    bat "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "${REGISTRY_CREDENTIALS}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    bat """
                        echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                        docker push ${DOCKER_IMAGE}
                        docker logout
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: "${KUBECONFIG_CREDENTIALS}", variable: 'KUBECONFIG_FILE')]) {
                    bat """
                        set KUBECONFIG=%KUBECONFIG_FILE%
                        kubectl apply -f ems-deployment.yml
                        kubectl apply -f ems-service.yml
                        kubectl apply -f mysql-deployment.yml
                        kubectl apply -f mysql-service.yml
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ EMS Backend successfully deployed!'
        }
        failure {
            echo '❌ EMS Deployment failed. Check logs.'
        }
    }
}
