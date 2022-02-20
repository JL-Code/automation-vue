/**
 * 通过 git-last-commit 库，获取仓库的 git 信息
 * @see https://www.npmjs.com/package/git-last-commit
 * @author jiangy
 */
const { manifest, timestampToTime } = require("./util");
var git = require("git-last-commit");

function run() {
  git.getLastCommit(function (err, commit) {
    // read commit object properties
    if (err) {
      console.error("获取最新提交信息失败", err);
      return;
    }
    manifest.updateGit({
      branch: commit.branch,
      commit: {
        id: commit.shortHash,
        time: timestampToTime(commit.committedOn),
      },
    });
  });
}

module.exports = { run };
