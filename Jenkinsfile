pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "vedasamhitha17/ems-backend:latest"
        REGISTRY_CREDENTIALS = '169eae38-e6bf-4896-8bc8-5c823fea4e0e'
        KUBECONFIG_CREDENTIALS = 'kubeconfig'
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
                withSonarQubeEnv('SonarQube') {
                    bat '''
                        mvn clean verify sonar:sonar ^
                        -Dsonar.projectKey=ems-backend ^
                        -Dsonar.projectName="EMS Backend" ^
                        -Dsonar.host.url=http://localhost:9000
                    '''
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
                bat "docker build -t %DOCKER_IMAGE% ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "${REGISTRY_CREDENTIALS}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    bat '''
                        echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                        docker push %DOCKER_IMAGE%
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: "${KUBECONFIG_CREDENTIALS}", variable: 'KUBECONFIG_FILE')]) {
                    bat '''
                        set KUBECONFIG=%KUBECONFIG_FILE%
                        kubectl apply -f ems-deployment.yml
                        kubectl apply -f ems-service.yml
                        kubectl apply -f mysql-deployment.yml
                        kubectl apply -f mysql-service.yml
                    '''
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
