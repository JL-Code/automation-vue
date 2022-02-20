/**
 * 负责根据传递的 payload 信息，更新 manifest.json。
 * @author jiangy
 */
const VERSION_CONTEXT = "src";
const VERSION_JSON = "manifest.json";
const fs = require("fs");
const path = require("path");

/**
 * 更新 manifest 文件
 * @param {Object} payload manifest 对象
 * @param {String} filepath 文件路径，默认为 path.resolve(process.cwd(), "src", "manifest.json")
 */
function updateBuild(payload, filepath) {
  const manifest = read(filepath);
  const build = Object.assign({}, manifest.app.build, payload);
  manifest.app.build = build;
  write(manifest, filepath);
}

function updateGit(payload, filepath) {
  const manifest = read(filepath);
  const git = Object.assign({}, manifest.git, payload);
  manifest.git = git;
  write(manifest, filepath);
}

function read(filepath) {
  filepath =
    filepath || path.resolve(process.cwd(), VERSION_CONTEXT, VERSION_JSON);
  const manifestJsonStr = fs.readFileSync(filepath, "utf8");
  return JSON.parse(manifestJsonStr) || { app: { build: {} }, git: {} };
}

function write(manifest, filepath) {
  filepath =
    filepath || path.resolve(process.cwd(), VERSION_CONTEXT, VERSION_JSON);
  // 写入文件
  fs.writeFileSync(filepath, JSON.stringify(manifest, null, "\t"));
  console.debug(
    "after manifest update",
    JSON.parse(fs.readFileSync(filepath, "utf8"))
  );
}

module.exports = {
  updateBuild,
  updateGit,
};
