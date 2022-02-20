const manifest = require("./util.manifest");

/**
 * 将 10或13位时间戳转为 YYYY-MM-dd HH:mm:ss 格式
 * 时间戳为10位需*1000，时间戳为13位的话不需乘1000
 * @param {Number} timestamp 时间戳
 * @returns YYYY-MM-dd HH:mm:ss
 */
function timestampToTime(timestamp) {
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

module.exports = {
  manifest,
  timestampToTime,
};
