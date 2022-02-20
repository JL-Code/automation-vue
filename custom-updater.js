/**
 * @author jiangy
 * @see https://github.com/conventional-changelog/standard-version
 */

const fs = require("fs");
const path = require("path");

module.exports = {
  toJson(contents) {
    let versionJson = { app: { version: undefined }, git: {} };
    try {
      versionJson = JSON.parse(contents);
    } catch (e) {
      console.error("custom updater toJson", e);
    }
    return versionJson;
  },
  readVersion(contents) {
    console.debug("readVersion", contents);
    const {
      app: { version },
    } = this.toJson(contents);
    return version;
  },
  writeVersion(contents, version) {
    console.debug("writeVersion", contents);
    console.debug("writeVersion", version);

    contents = this.toJson(contents);

    contents.app
      ? (contents.app.version = version)
      : (contents.app = { version });

    // TODO: filepath 可以从 standard 中获取吗？
    // 写入文件
    const filepath = path.resolve(process.cwd(), "src", "manifest.json");
    if (fs.existsSync(filepath)) {
      fs.writeFileSync(filepath, contents);
    } else {
      console.error("未找到版本文件", filepath);
    }
  },
};
