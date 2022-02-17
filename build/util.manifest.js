/**
 * 负责根据传递的 payload 信息，更新 manifest.json。
 * @author jiangy
 */

const fs = require("fs");
const path = require("path");

function updateManifest(filepath, payload) {
  console.debug("__dirname", __dirname);
  console.debug("filepath", filepath);
  console.debug("payload", payload);
  console.debug("cwd", process.cwd());

  filepath = filepath || path.resolve(process.cwd(), "src", "manifest.json");

  console.debug("filepath", filepath);
  console.debug("process.env", process.env);

  const manifestJsonStr = fs.readFileSync(filepath, "utf8");

  // parse JSON string to JSON object
  const manifest = JSON.parse(manifestJsonStr);
  console.debug(
    "before manifest update",
    JSON.parse(fs.readFileSync(filepath, "utf8"))
  );

  console.debug("manifest", manifest);

  manifest.git = payload.git;

  // 写入文件
  fs.writeFileSync(filepath, JSON.stringify(manifest, null, "\t"));

  console.debug(
    "after manifest update",
    JSON.parse(fs.readFileSync(filepath, "utf8"))
  );
}

module.exports = {
  updateManifest: updateManifest,
};
