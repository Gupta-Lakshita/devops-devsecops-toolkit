//multistage
pipeline{
    agent any

    stages{
        stage('dev'){
            steps{
                echo "hello world"
            }
        }
        stage('build'){
            steps{
                //get some code from a git repo
                git ''
            }
        }
    }
}

//ci pipeline
pipeline{
    agent any
    tools{
        go 'go-1.17'
    }
    environment{
        GO111MODULE='on'
    }
    stages{
        stage('test'){
            steps{
                git ''
                sh 'go test ./...'
            }
        }

//building a docker image
        stage('building a image'){
            steps{
                script{
                    app=docker.build("")
                }
            }
        }
//cd or run
        stage('run'){
            steps{
                sh 'cd /'
            }
        }
    }
}