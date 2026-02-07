pipeline {
    agent any
    
    environment {
        DOCKER_HUB_USER = 'bakingbrain'
        APP_NAME        = 'mobsf'
        // Use a unique tag combining build number and timestamp for traceability
        IMAGE_TAG       = "${DOCKER_HUB_USER}/${APP_NAME}:${BUILD_NUMBER}"
        // Credentials IDs from Jenkins Global Store
        DOCKER_CREDS    = 'dockerhubcred'
        SONAR_SCANNER   = tool 'SonarQube'
    }

    stages {
        stage('Preparation') {
            steps {
                // Clean workspace and pull fresh code
                cleanWs()
                git branch: "main", url: "https://github.com/ShreyashGarudkar/mobsf.git"
            }
        }

        stage('Security & Quality Scans') {
            parallel {
                stage('SonarQube Analysis') {
                    steps {
                        withSonarQubeEnv('SonarQube') {
                            sh "${SONAR_SCANNER}/bin/sonar-scanner \
                                -Dsonar.projectName=${APP_NAME} \
                                -Dsonar.projectKey=${APP_NAME}"
                        }
                    }
                }
                stage('OWASP Dependency Check') {
                    steps {
                        dependencyCheck additionalArguments: '--scan ./', odcInstallation: 'owasp-check'
                        dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
                    }
                }
            }
        }
        stage('Build Image') {
            steps {
                script {
                    echo "Building the Docker image..."
                    // Build once with both tags (versioned and latest)
                    sh "docker build -t ${IMAGE_TAG} -t ${DOCKER_HUB_USER}/${APP_NAME}:latest ."
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                script {
                    echo "Scanning image for vulnerabilities..."
                    // --exit-code 1 will fail the pipeline if HIGH or CRITICAL issues are found
                    sh "trivy image --severity HIGH,CRITICAL --timeout 15m$ {IMAGE_TAG}"
                }
            }
        } 

        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDS}", 
                                     passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "echo \$PASS | docker login -u \$USER --password-stdin"
                        echo "Pushing versioned image: ${IMAGE_TAG}"
                        sh "docker push ${IMAGE_TAG}"
                        echo "Pushing latest tag..."
                        sh "docker push ${DOCKER_HUB_USER}/${APP_NAME}:latest"
                    }
                }
            }
        }


        stage('Kubernetes Deployment') {
            steps {
                // 'kubectl apply' handles both first-time creation and updates
                sh "kubectl apply -f deployment.yaml"
                // Update the specific container with the new versioned image
                sh "kubectl set image deployment/mobsf mobsf=${IMAGE_TAG}" // here mobsf is container name
                // Verify the rollout status
                sh "kubectl rollout status deployment/mobsf"
            }
        }
    }

    post {
        always {
            // Cleanup to save disk space on the Jenkins server
            sh "docker rmi ${IMAGE_TAG} || true"
            sh "docker image prune -f"
        }
        success {
            echo "Successfully deployed version ${BUILD_NUMBER}"
        }
        failure {
            echo "Pipeline failed! Check the logs for security scan failures."
        }
    }
}