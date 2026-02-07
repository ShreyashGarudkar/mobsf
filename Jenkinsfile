    post {
        always {
            sh "docker rmi ${IMAGE_TAG} || true"
            sh "docker image prune -f"
        }
        success {
            emailext (
                subject: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: """<p>Successfully deployed version ${env.BUILD_NUMBER}.</p>
                         <p>Check the console output here: <a href='${env.BUILD_URL}'>${env.JOB_NAME} #${env.BUILD_NUMBER}</a></p>""",
                to: "${RECIPIENT_EMAIL}",
                mimeType: 'text/html'
            )
        }
        failure {
            emailext (
                subject: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: """<p>Pipeline failed! Please check the security scan logs or deployment status.</p>
                         <p>Console Log: <a href='${env.BUILD_URL}console'>View Logs</a></p>""",
                to: "${RECIPIENT_EMAIL}",
                mimeType: 'text/html'
            )
        }
    }