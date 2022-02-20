/**
 * @author jiangy
 * @see https://github.com/conventional-changelog/standard-version
 */
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

    return JSON.stringify(contents, null, "\t");
  },
};
