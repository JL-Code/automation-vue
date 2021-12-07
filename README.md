# automation-vue

## TODO

1. commit message 规范化【GUI 工具提交如何管控？】
2. 自动生成 CHANGELOG
3. 集成 Jenkins Pipeline CICD

## commitlint 规范提交

### 依赖安装

```shell
npm install @commitlint/config-conventional --save-dev
npm install @commitlint/cli --save-dev
npm install @commitlint/parse --save-dev
```

vue-cli 创建的项目通过在 package.json 中 `gitHooks` 开启 commitlint。

```json
"gitHooks": {
  "commit-msg": "commitlint -E GIT_PARAMS"
}
```

提交规范：

```sh
type(scope?): subject # scope is optional; multiple scopes are supported (current delimiter options: "/", "\" and ",")
```

现实的例子：

```sh
chore: run tests on travis ci
```

```sh
fix(server): send cors headers
```

```sh
feat(blog): add comment section
```

设置 commit 规则

配置 `commitlint.config.js` 文件 [用于配置 commitlint](https://commitlint.js.org/#/?id=getting-started)

```js
module.exports = {
  extends: ["@commitlint/config-conventional"],
  parserPreset: {
    parserOpts: {
      // issue 前缀，自动识别 #1234 为 issue，可在 commit message 中写入关闭的问题 id
      issuePrefixes: ["#"],
    },
  },
  rules: {
    "header-max-length": [0, "always", 100],
    "type-enum": [
      2,
      "always",
      [
        "feat", // feature 新功能，新需求
        "fix", // 修复 bug
        "docs", // 仅仅修改了文档，比如README, CHANGELOG, CONTRIBUTE等等
        "style", // 仅仅修改了空格、格式缩进、逗号等等，不改变代码逻辑
        "refactor", // 代码重构，没有加新功能或者修复bug
        "test", // 测试用例，包括单元测试、集成测试等
        "revert", // 回滚到上一个版本
        "perf", // 性能优化
        "chore", // 改变构建流程、或者增加依赖库、工具等，包括打包和发布版本
        "conflict", // 解决合并过程中的冲突
      ],
    ],
  },
}
```

## 效果图

### GUI 提交验证

![SourceTree提交失败场景](./assets/SourceTree提交失败场景.png)

![VSCode提交失败场景](./assets/VSCode提交失败场景.png)
