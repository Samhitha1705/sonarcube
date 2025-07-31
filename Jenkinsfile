pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "vedasamhitha17/ems-backend:latest"
        REGISTRY_CREDENTIALS = '169eae38-e6bf-4896-8bc8-5c823fea4e0e'
        KUBECONFIG_CREDENTIALS = 'kubeconfig'
        SONAR_PROJECT_KEY = 'ems-backend'
        SONAR_PROJECT_NAME = 'EMS Backend'
        SONAR_HOST_URL = 'http://localhost:9000'
    }

    tools {
        maven 'Maven'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/Samhitha1705/sonarcube.git', branch: 'main'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
                    withSonarQubeEnv('SonarQube') {
                        bat """
                            mvn clean verify sonar:sonar ^
                            -Dsonar.projectKey=${SONAR_PROJECT_KEY} ^
                            -Dsonar.projectName=\"${SONAR_PROJECT_NAME}\" ^
                            -Dsonar.host.url=${SONAR_HOST_URL} ^
                            -Dsonar.token=${SONAR_TOKEN}
                        """
                    }
                }
            }
        }

        stage('Build with Maven') {
            steps {
                bat 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat "docker build -t ${DOCKER_IMAGE} ."
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
