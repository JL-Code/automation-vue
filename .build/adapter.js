const Service = require('@vue/cli-service/lib/Service')
const util = require('./util.js')
const git = require('git-last-commit')

// 实例化Service
// VUE_CLI_CONTEXT为undefined，所以传入的值为process.cwd()及项目所在目录
const service = new Service(process.env.VUE_CLI_CONTEXT || process.cwd())

const rawArgv = process.argv.slice(2)

// minimist解析工具来对命令行参数进行解析
const args = require('minimist')(rawArgv, {
  boolean: [
    // build
    'modern',
    'report',
    'report-json',
    'watch',
    // serve
    'open',
    'copy',
    'https',
    // inspect
    'verbose'
  ]
})

const command = args._[0]

// 执行service方法传入:'serve'、agrs、['serve','--open',...]
service
  .run(command, args, rawArgv)
  .then(() => {
    if (command === 'build') {
      if (!args.file) {
        console.warn('缺少 --file 参数，已跳过应用信息更新')
        return
      }
      git.getLastCommit(function(err, commit) {
        // read commit object properties
        if (err) {
          console.error('获取最新提交信息失败', err)
          process.exit(1)
        }
        util.manifest.update(
          {
            git: {
              branch: commit.branch,
              commit: {
                id: commit.shortHash,
                time: util.timestampToTime(commit.committedOn)
              }
            },
            build: {
              timestamp: util.timestampToTime(Date.now())
            }
          },
          args.file
        )
      })
    }
  })
  .catch(err => {
    console.error(err)
    process.exit(1)
  })
