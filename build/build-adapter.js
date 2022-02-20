const Service = require("@vue/cli-service/lib/Service");
const util = require("./util.js");
const gitCli = require("./git-cli.js");

// 实例化Service
// VUE_CLI_CONTEXT为undefined，所以传入的值为process.cwd()及项目所在目录
const service = new Service(process.env.VUE_CLI_CONTEXT || process.cwd());

const rawArgv = process.argv.slice(2);

// minimist解析工具来对命令行参数进行解析
const args = require("minimist")(rawArgv, {
  boolean: [
    // build
    "modern",
    "report",
    "report-json",
    "watch",
    // serve
    "open",
    "copy",
    "https",
    // inspect
    "verbose",
  ],
});

const command = args._[0];

// console.debug("service", service);
// console.debug("process.argv", process.argv);
// console.debug("command", command);
// console.debug("args", args);
// console.debug("rawArgv", rawArgv);

// 执行service方法传入:'serve'、agrs、['serve','--open',...]
service
  .run(command, args, rawArgv)
  .then(() => {
    if (command === "build") {
      gitCli.run();
      util.manifest.updateBuild({
        timestamp: util.timestampToTime(Date.now()),
      });
    }
  })
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
