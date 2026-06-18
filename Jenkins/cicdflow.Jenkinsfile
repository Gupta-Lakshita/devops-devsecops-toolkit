// Pipeline Flow:

// GitHub Commit
//       ↓
// Maven Build (mvn clean package)
//       ↓
// JUnit Tests (mvn test)
//       ↓
// JaCoCo Coverage Report
//       ↓
// Docker Build
//       ↓
// Docker Push to Docker Hub
//       ↓
// Update Kubernetes YAML with new image tag
//       ↓
// kubectl apply
//       ↓
// Deploy to DEV Kubernetes Cluster


pipeline {
    agent any

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

        stage('Docker Build and Push') {
            steps {
                withDockerRegistry([credentialsId: 'docker-hub', url: '']) {
                    sh 'printenv'
                    sh 'docker build -t lakshitag/numeric-app:"${GIT_COMMIT}" .'
                    sh 'docker push lakshitag/numeric-app:"${GIT_COMMIT}"'
                }
            }
        }

        stage('Kubernetes Deployment - DEV') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                    sh "sed -i 's#replace#lakshitag/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                    sh "kubectl apply -f k8s_deployment_service.yaml"
                }
            }
        }

    }
}

// The pipeline builds the Maven artifact,
// runs tests, generates code coverage,
// builds and pushes a Docker image tagged with the Git commit,
// updates the Kubernetes manifest with the new image tag,
// and deploys it to the DEV Kubernetes cluster using kubectl.