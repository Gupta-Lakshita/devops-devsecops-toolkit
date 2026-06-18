pipeline {
    agent any

    environment {
        deploymentName = "devsecops"
        containerName = "devsecops-container"
        serviceName = "devsecops-svc"
        imageName = "siddharth67/numeric-app:${GIT_COMMIT}"
        applicationUrl = "http://devsecops-demo.eastus.cloudapp.azure.com/"
        applicationURI = "/increment/99"
    }

    stages {

        stage('Build Artifact - Maven') {
            steps {
                sh "mvn clean package -DskipTests=true"
                archive 'target/*.jar'
            }
        }

        stage('Unit Tests - JUnit and Jacoco') {
            steps {
                sh "mvn test"
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                    jacoco execPattern: 'target/jacoco.exec'
                }
            }
        }

        stage('Mutation Tests - PIT') {
            steps {
                sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
            post {
                always {
                    pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
                }
            }
        }

        stage('SonarQube - SAST') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh """
                        mvn sonar:sonar \
                        -Dsonar.projectKey=numeric-application \
                        -Dsonar.host.url=http://devsecops-demo.eastus.cloudapp.azure.com:9000 \
                        -Dsonar.login=0925129cf435c63164d3e63c9f9d88ea9f9d7f05
                    """
                }

                timeout(time: 2, unit: 'MINUTES') {
                    script {
                        waitForQualityGate abortPipeline: true
                    }
                }
            }
        }

        // stage('Vulnerability Scan - Docker ') {
        //     steps {
        //         sh "mvn dependency-check:check"
        //     }
        //     post {
        //         always {
        //             dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
        //         }
        //     }
        // }

        stage('Vulnerability Scan - Docker') {
            steps {
                parallel(
                    "Dependency Scan": {
                        sh "mvn dependency-check:check"
                    },
                    "Trivy Scan": {
                        sh "bash trivy-docker-image-scan.sh"
                    }
                )
            }
        }

        stage('Docker Build and Push') {
            steps {
                withDockerRegistry([credentialsId: 'docker-hub', url: '']) {
                    sh 'printenv'
                    sh 'docker build -t lakshitag/numeric-app:"${GIT_COMMIT}" .'
                    sh 'docker push lakshitag/numeric-app:"${GIT_COMMIT}"'
                }
            }
        }

        stage('Vulnerability Scan - Kubernetes') {
            steps {
                parallel(
                    "OPA Scan": {
                        sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
                    },
                    "Kubesec Scan": {
                        sh "bash kubesec-scan.sh" // kubsec script
                    },
                    "Trivy Scan": {
                        sh "bash trivy-k8s-scan.sh" // trivy script
                    }
                )
            }
        }

        // stage('Kubernetes Deployment - DEV') {
        //     steps {
        //         withKubeConfig([credentialsId: 'kubeconfig']) {
        //             sh "sed -i 's#replace#lakshitag/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
        //             sh "kubectl apply -f k8s_deployment_service.yaml"
        //         }
        //     }
        // }

        stage('K8S Deployment - DEV') {
            steps {
                parallel(
                    "Deployment": {
                        withKubeConfig([credentialsId: 'kubeconfig']) {
                            sh "bash k8s-deployment.sh" // deployment script
                        }
                    },
                    "Rollout Status": {
                        withKubeConfig([credentialsId: 'kubeconfig']) {
                            sh "bash k8s-deployment-rollout-status.sh"
                        }
                    }
                )
            }
        }

        stage('Integration Tests - DEV') {
            steps {
                script {
                    try {
                        withKubeConfig([credentialsId: 'kubeconfig']) {
                            sh "bash integration-test.sh"
                        }
                    } catch (e) {
                        withKubeConfig([credentialsId: 'kubeconfig']) {
                            sh "kubectl -n default rollout undo deploy ${deploymentName}"
                        }
                        throw e
                    }
                }
            }
        }

        stage('OWASP ZAP - DAST') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                    sh 'bash zap.sh'
                }
            }
        }
    }

    post {
        always {
            junit 'target/surefire-reports/*.xml'
            jacoco execPattern: 'target/jacoco.exec'
            pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
            dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'

            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'owasp-zap-report',
                reportFiles: 'zap_report.html'
            ])

            // Use sendNotifications.groovy from shared library and provide current build result as parameter
            sendNotifications currentBuild.result // connecting Slack
        }

        success {

        }

        failure {

        }
    }
}