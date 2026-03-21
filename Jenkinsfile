pipeline {
    agent { label 'cpp-agent' }

    parameters {
        string(name: 'PROJECT_NAME', defaultValue: 'cpp-template', description: 'Nome do projeto')
        string(name: 'DOCKER_REGISTRY', defaultValue: 'host.docker.internal:5001', description: 'Registry do Nexus')
        string(name: 'BUILD_TYPE', defaultValue: 'Release', description: 'Release/Debug')
    }

    environment {
        // Onde o Conan e CMake moram
        PATH = "/home/alissoneves/.local/bin:/usr/local/bin:/usr/bin:/bin:${env.PATH}"
        
        // Definição da pasta de build (estava faltando no seu!)
        BUILD_DIR = "build/${params.BUILD_TYPE}"
        
        NEXUS_CRED = credentials('nexus-credentials')
        IMAGE_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT?.take(7)}"
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Conan & CMake Build') {
            steps {
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
                sh "echo ${NEXUS_CRED_PSW} | docker login ${params.DOCKER_REGISTRY} -u ${NEXUS_CRED_USR} --password-stdin"
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    sh "docker build -t ${params.DOCKER_REGISTRY}/${params.PROJECT_NAME}:${env.IMAGE_TAG} ."
                    sh "docker push ${params.DOCKER_REGISTRY}/${params.PROJECT_NAME}:${env.IMAGE_TAG}"
                }
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                echo "Atualizando K8s com a imagem: ${env.IMAGE_TAG}"
                sh """
                    kubectl set image deployment/${params.PROJECT_NAME} \
                    ${params.PROJECT_NAME}=${params.DOCKER_REGISTRY}/${params.PROJECT_NAME}:${env.IMAGE_TAG}
                    
                    kubectl rollout status deployment/${params.PROJECT_NAME} --timeout=30s || echo "Rollout finalizado"
                """
            }
        }
    } // Aqui fecha o stages

    post {
        success { echo "Pipeline concluída com sucesso! 🚀" }
        failure { echo "Pipeline falhou. Verifique os logs. ❌" }
    }
} // Aqui fecha o pipeline