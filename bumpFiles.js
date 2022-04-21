// 应用编码
const code = "ebs";

module.exports = [
  {
    filename: `./src/apps/${code}/manifest.json`,
    updater: "./.build/manifest-updater.js",
  },
];
