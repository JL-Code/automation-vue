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
    console.log("readVersion", contents);
    const {
      app: { version },
    } = this.toJson(contents);
    return version;
  },
  writeVersion(contents, version) {
    console.log("writeVersion", contents);
    console.log("writeVersion", version);

    contents.app
      ? (contents.app.version = version)
      : (contents.app = { version });

    // 写入文件
    const filepath =
      filepath || path.resolve(process.cwd(), "src", "manifest.json");
    fs.writeFileSync(filepath, contents);
  },
};
