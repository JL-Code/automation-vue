/**
 * 通过 git-last-commit 库，获取仓库的 git 信息
 * @see https://www.npmjs.com/package/git-last-commit
 * @author jiangy
 */

const manifestUtil = require("./util.manifest");
var git = require("git-last-commit");

git.getLastCommit(function (err, commit) {
  // read commit object properties
  if (err) {
    console.error("获取最新提交信息失败", err);
    return;
  }
  console.debug("commit", commit);
  manifestUtil.updateManifest("", {
    git: {
      branch: commit.branch,
      commit: {
        id: commit.shortHash,
        time: _timestampToTime(commit.committedOn),
      },
    },
  });
});

function _timestampToTime(timestamp) {
  //时间戳为10位需*1000，时间戳为13位的话不需乘1000
  let date = new Date(timestamp.length === 10 ? timestamp * 1000 : timestamp);
  let Y = date.getFullYear() + "-";
  let M =
    (date.getMonth() + 1 < 10
      ? "0" + (date.getMonth() + 1)
      : date.getMonth() + 1) + "-";
  let D = date.getDate() + " ";
  let h = date.getHours() + ":";
  let m = date.getMinutes() + ":";
  let s = date.getSeconds();

  return Y + M + D + h + m + s;
}
