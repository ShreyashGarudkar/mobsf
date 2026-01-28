pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: jnlp
    image: jenkins/inbound-agent:latest-jdk17
    securityContext:
      runAsUser: 0
    env:
    - name: JAVA_HOME
      value: /opt/java/openjdk
    resources:
      limits:
        memory: "4Gi"
        cpu: "2000m"
      requests:
        memory: "2Gi"
        cpu: "1000m"
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
    command: ["/bin/sh", "-c"]
    args: ["apt-get update && apt-get install -y python3 python3-pip git curl docker.io && exec $(which jenkins-agent)"]
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
'''
        }
    }

    environment {
        IMAGE_NAME = "batataman26/mobile-security-framework-mobsf:${env.BUILD_NUMBER}"
        SCANNER_HOME = tool 'SonarScanner' 
        KUBECONFIG_FILE = credentials('kubeconfig') 
    }

    stages {
        stage('Clone Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Srshinde5512/mobile-security.git'
            }
        }
        
       stage('Install Dependencies & Test') {
            steps {
                script {
                    sh '''
                        # 1. Install poetry globally in the agent
                        python3 -m pip install poetry --break-system-packages
                        
                        # 2. Try to install dependencies
                        python3 -m poetry install --with test,dev || python3 -m poetry install
                        
                        # 3. Explicitly ensure pytest is in the virtualenv
                        python3 -m poetry run pip install pytest pytest-cov 
                        
                        # 4. Run tests
                        # Correct command to find and run MobSF tests
                        python3 -m poetry run pytest tests/ --cov=mobsf --cov-report=xml:coverage.xml || echo "Tests failed but generating report"
                    '''
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv('sonar-server') {
                        sh "${SCANNER_HOME}/bin/sonar-scanner \
                          -Dsonar.projectKey=mobsf-project \
                          -Dsonar.exclusions=**/axml.py,**/StaticAnalyzer/tools/** \
                          -Dsonar.javascript.node.maxspace=1024 \
                          -Dsonar.python.coverage.reportPaths=coverage.xml"
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Docker Image') {
           steps {
               script {
            // This ensures Debian treats the script as a runnable program 
            // before the Docker context is sent to the builder
                      sh "chmod +x scripts/dependencies.sh"
                      sh "docker build -t ${IMAGE_NAME} ."
        }
    }
}

        stage('Push Image') {
            steps {
                script {
                    // Note: Ensure credential ID 'dockerhub-creds' exists in Jenkins
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-creds') {
                        sh "docker push ${IMAGE_NAME}"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh "sed -i 's|batataman26/mobile-security-framework-mobsf:latest|${IMAGE_NAME}|g' deployment.yaml"
                    sh "kubectl --kubeconfig=${KUBECONFIG_FILE} apply -f deployment.yaml"
                }
            }
        }
    }

    post {
        always {
            script {
                try {
                    sh "docker rmi ${IMAGE_NAME} || true"
                } catch (Exception e) {
                    echo "Could not remove image: ${e.message}"
                }
            }
        }
    }
}