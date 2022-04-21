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
        booleanParam(name: 'SKIP_RELEASE', defaultValue: true, description: '跳过发版动作')
        booleanParam(name: 'SKIP_TEST', defaultValue: true, description: '跳过测试阶段（默认为 true）')
        choice(name: 'ENV', choices: ENVs,description: ENV_DESC)
    }
    stages {
        stage("Config") {
            steps {
                echo sh(returnStdout: true, script: 'env')
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
                    sh """sed -i '\$a IMAGE_TAG=${GLOBAL_TAG}' ./.build/env/.env.${params.ENV}"""
                    // 替换指定环境的配置文件为  .env.production
                    if (params.ENV != 'production') {
                        sh """ cp .env.${params.ENV} .env.production """
                    }
                    withPythonEnv('/usr/bin/python') {
                        // sh 步骤的执行上下文是独立的。在 worksapce 路径执行  sh "cd build" 后再执行 sh "pwd" 得到的目录并不是 build  而是 worksapce
                        sh """cd ./.build && python env_replace.py replace ./template/docker-compose-template.yml ./target/docker-compose.yml ./env/.env.${params.ENV}"""
                        sh """cd ./.build && python env_replace.py replace ./template/nginx-template.conf ./target/nginx.conf ./env/.env.${params.ENV}"""
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
                    sh """npm run release -- --release-as ${GLOBAL_TAG} ${params.SKIP_RELEASE ? '--skip.tag' : ''}"""
                    sh 'npm run cbuild -- --file=src/apps/ebs/manifest.json'
                }
            }
            post {
                success {
                    sh "tar -czf dist.tar.gz dist/"
                    archiveArtifacts artifacts: """dist.tar.gz,.build/target/,env/.env.${params.ENV}""", fingerprint: true
                }
            }
        }
    }
}
