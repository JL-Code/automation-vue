#!groovy
pipeline {
    agent any
    parameters {
    }
    stages {
        stage('Config') {
          steps {
            echo "ENV ${params.ENV}"
            echo "BRANCH_NAME ${env.BRANCH_NAME}"
            echo "WORKSPACE ${env.WORKSPACE}"
          }
        }
        stage('Restore') {
          steps {
            // TODO: 依赖于外部插件
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
              sh 'npm run build'
            }
          }
          post {
            success {
              sh 'tar -czf dist.tar.gz dist/'
              archiveArtifacts artifacts: """dist.tar.gz,.env.${params.ENV}""", fingerprint: true
            }
          }
        }
    }
}
