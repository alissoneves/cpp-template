pipeline {
    agent { label 'cpp-agent' }

    parameters {
        string(name: 'PROJECT_NAME', defaultValue: 'cpp-template', description: 'Nome do projeto')
        // Alterado para o endereço que o Docker Desktop resolve
        string(name: 'DOCKER_REGISTRY', defaultValue: 'host.docker.internal:5001', description: 'Registry do Nexus')
        string(name: 'BUILD_TYPE', defaultValue: 'Release', description: 'Release/Debug')
    }

    environment {
    // Adicionamos o caminho do seu usuário explicitamente no PATH do Jenkins
    PATH = "/home/alissoneves/.local/bin:/usr/local/bin:/usr/bin:/bin:${env.PATH}"
    
    // Credenciais que você já configurou
    NEXUS_CRED = credentials('nexus-credentials')
    
    // Suas outras variáveis de projeto
    IMAGE_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT?.take(7)}"
}

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

       stage('Conan & CMake Build') {
            steps {
        // Usar env.BUILD_DIR garante que o Jenkins pegue a variável do environment
        sh "conan install . --output-folder=${env.BUILD_DIR} --build=missing"
        sh "cmake -S . -B ${env.BUILD_DIR} -DPROJECT_NAME=${params.PROJECT_NAME}"
        sh "cmake --build ${env.BUILD_DIR}"
    }
}

        stage('Run Tests') {
            steps {
                sh "cd ${env.BUILD_DIR} && ctest --output-on-failure"
            }
        }

        stage('Docker Login') {
            steps {
                echo 'Logando no registry Docker...'
                // Usando a variável definida no environment
                sh "echo ${NEXUS_CRED_PSW} | docker login ${params.DOCKER_REGISTRY} -u ${NEXUS_CRED_USR} --password-stdin"
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    // Usando a IMAGE_TAG consistente
                    sh "docker build -t ${params.DOCKER_REGISTRY}/${params.PROJECT_NAME}:${IMAGE_TAG} ."
                    sh "docker push ${params.DOCKER_REGISTRY}/${params.PROJECT_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                echo "Atualizando K8s com a imagem: ${IMAGE_TAG}"
                sh """
                kubectl set image deployment/${params.PROJECT_NAME} \
                ${params.PROJECT_NAME}=${params.DOCKER_REGISTRY}/${params.PROJECT_NAME}:${IMAGE_TAG}
                
                kubectl rollout status deployment/${params.PROJECT_NAME}
                """
            }
        }
    }

    post {
        success { echo "Pipeline concluída com sucesso! 🚀" }
        failure { echo "Pipeline falhou. Verifique os logs. ❌" }
    }
}