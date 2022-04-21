# 构建工具
## cbuild 命令

语法：`npm run cbuild -- [参数]`

参数：
1. `--file` 指定版本文件路径

```shell
npm run cbuild -- --file=src/apps/ebs/manifest.json
```

**manifest.json**
```json
{
  "app": {
    "name": "expense-budget-service",
    "version": "hotfix-ebs-supplement-contract-2",
    "description": "费用预算管理",
    "build": {
      "timestamp": "2022-02-16 14:07:15"
    }
  },
  "git": {
    "branch": "hotfix-0001",
    "commit": {
      "id": "333ff6d",
      "time": "2022-02-16 14:06:31"
    }
  }
}
```