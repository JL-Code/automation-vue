const fs = require("fs")
const path = require("path")

let app, version;

// 获取 Node.js 的命令行参数
process.argv.forEach((val, index) => {
  console.debug(`"node argv": ${index}: ${val}`)
  if (index === 2) {
    app = val;
  } else if (index === 3) {
    version = val;
  }
})

console.debug("__dirname", __dirname)
console.debug("cwd", process.cwd())

if (!app || !version) {
  console.error("无效的 app 或 version 参数");
  return
}

const filepath = path.resolve(`src/apps/${app}/manifest.json`);

// 读取 process.env
console.debug("process.env", process.env)

const manifestJsonStr = fs.readFileSync(filepath, 'utf8');

// parse JSON string to JSON object
const manifest = JSON.parse(manifestJsonStr);
console.debug("before manifest update", JSON.parse(fs.readFileSync(filepath, 'utf8')))

console.debug("manifest", manifest)
console.debug("app", app)
console.debug("version", version)

// 修改版本号
manifest.version = version

// 写入文件
fs.writeFileSync(filepath, JSON.stringify(manifest))

console.debug("after manifest update", JSON.parse(fs.readFileSync(filepath, 'utf8')))