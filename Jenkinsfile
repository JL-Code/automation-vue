#!groovy
import java.text.SimpleDateFormat

def APP_CODE = 'ebs_pc'
def GLOBAL_TAG = ''
def ENVs = ['sit','test']
def GLOBAL_SSH_CREDENTIALS = ['sit': 'ssh99','test': 'ssh100']
def GLOBAL_SSH_HOSTS = ['sit': '192.168.1.99','test': '192.168.1.100']

def ENV_DESC = "环境代码\t环境名称/受众\t服务器\n" +
        "sit\t集成环境，开发\t192.168.1.99\n" +
        "test\t「HJ产品」测试环境，测试\t192.168.1.97\n"

pipeline {
    agent any

    parameters {
        string(name: 'IMAGE_TAG', defaultValue: '', description: '镜像标签,默认版本号为时间戳「20210209133014508」可自定义版本号。（版本号会在 maven 打包、docker 构建镜像时用到）')
        string(name: 'REGISTRY_NAMESPACE_IMAGE', defaultValue: 'nexus.highzap.com:8082/jerp/front-end/expense-budget-vue-pc', description: 'Docker 注册表/命名空间/镜像名')
        booleanParam(name: 'CLEAN_WORKSPACE', defaultValue: false, description: '清空工作空间')
        booleanParam(name: 'SKIP_RELEASE', defaultValue: false, description: '跳过发版阶段')
        booleanParam(name: 'SKIP_TEST', defaultValue: true, description: '跳过测试阶段（默认为 true）')
        booleanParam(name: 'SKIP_DEPLOY', defaultValue: false, description: '跳过部署阶段')
        choice(name: 'ENV', choices: ENVs,description: ENV_DESC)
    }
    stages {

        stage("Clean") {
            when {
                expression { return params.getOrDefault('CLEAN_WORKSPACE', false) }
            }
            steps {
                deleteDir()
                git credentialsId: 'sys',
                        url: 'http://git.highzap.com/HJExpense/expense-budget-management-vue-pc.git',
                        branch: env.BRANCH_NAME
            }
        }

        stage("Config") {
            steps {
                echo "ENV ${params.ENV}"
                echo "BRANCH_NAME ${env.BRANCH_NAME}"
                echo "WORKSPACE ${env.WORKSPACE}"

                script {
                    GLOBAL_TAG = params.IMAGE_TAG
                    if (GLOBAL_TAG == '' || GLOBAL_TAG.length() == 0) {
                        Date date = new Date();
                        String dateStr = new SimpleDateFormat("yyyyMMddHHmmssS").format(date);
                        GLOBAL_TAG = dateStr;
                    }

                    if (params.ENV.length() == 0) {
                        throw new Exception("请选择运行环境")
                    }

                    // 在 .env.[MODE] 文件后追加内容
                    sh """sed -i '\$a IMAGE_TAG=${GLOBAL_TAG}' ./build/.env.${params.ENV}"""
                    // 替换指定环境的配置文件为  .env.production
                    if (params.ENV != 'production') {
                        sh """
                            cp .env.${params.ENV} .env.production
                            """
                    }

                    withPythonEnv('/usr/bin/python') {
                        // sh 步骤的执行上下文是独立的。在 worksapce 路径执行  sh "cd build" 后再执行 sh "pwd" 得到的目录并不是 build  而是 worksapce
                        sh """cd ./build && python env_replace.py replace docker-compose-template.yml docker-compose.yml .env.${params.ENV}"""
                        sh """cd ./build && python env_replace.py replace ./nginx-template.conf ../nginx.conf .env.${params.ENV}"""
                    }

                }
            }
        }

        stage('Restore') {
            steps {
                nodejs(nodeJSInstallationName: 'NodeJS-12.18.4', configId: null) {
                    sh 'npm config set registry=https://registry.npm.taobao.org'
                    sh 'npm config set disturl=https://npm.taobao.org/dist'
                    sh 'node -v && npm -v'
                    sh 'npm config get registry && npm config get disturl'
                    sh 'npm install'
                }
            }
        }

        stage('Test') {
            // 根据 SKIP_TEST 条件判断是否进行单元测试
            when {
                expression { return !params.getOrDefault('SKIP_TEST', true) }
            }
            steps {
                nodejs(nodeJSInstallationName: 'NodeJS-12.18.4', configId: null) {
                    sh 'npm run test:unit'
                }
            }
        }

        stage('Build') {
            steps {
                nodejs(nodeJSInstallationName: 'NodeJS-12.18.4', configId: null) {
                    sh """npm run release ebs ${GLOBAL_TAG}"""
                    sh 'npm run build'
                }
            }
            post {
                success {
                    sh "tar -czf dist.tar.gz dist/"
                    archiveArtifacts artifacts: """dist.tar.gz,build/docker-compose.yml,.env.${params.ENV}""", fingerprint: true
                }
            }
        }

        stage('Delivery') {
            steps {
                script {
                    def registryNamespaceImage = params.REGISTRY_NAMESPACE_IMAGE
                    def imageName = "${registryNamespaceImage}:${GLOBAL_TAG}"
                    def customImage = docker.build(imageName)

                    customImage.push()
                }
            }
        }

        stage('Deploy') {
            when {
                expression { return !params.getOrDefault('SKIP_DEPLOY', false) }
            }

            steps {
                withCredentials(bindings: [usernamePassword(
                        credentialsId: GLOBAL_SSH_CREDENTIALS.get(params.ENV),
                        usernameVariable: 'SSH_CREDS_USR',
                        passwordVariable: 'SSH_CREDS_PSW')]) {
                    script {
                        def remote = [:]
                        remote.name = params.ENV
                        remote.host = GLOBAL_SSH_HOSTS.get(params.ENV)
                        remote.user = env.SSH_CREDS_USR
                        remote.password = env.SSH_CREDS_PSW
                        remote.allowAnyHosts = true

                        sshCommand remote: remote, command: "mkdir -p ./vueapps/"+APP_CODE
                        sshPut remote: remote, from: "./build/docker-compose.yml", into: "./vueapps/"+APP_CODE
                        sshCommand remote: remote, command: "docker stack deploy -c ./vueapps/"+APP_CODE+"/docker-compose.yml "+APP_CODE
                    }
                }
            }
        }

    }
}
