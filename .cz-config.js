// module.exports = {
//   // type 类型
//   types: [
//     { value: "feat", name: "✨ 新增产品功能" },
//     { value: "fix", name: "🐛 修复 bug" },
//     { value: "docs", name: "📝 文档的变更" },
//     {
//       value: "style",
//       name: "💄 不改变代码功能的变动(如删除空格、格式化、去掉末尾分号等)",
//     },
//     {
//       value: "refactor",
//       name: "♻ 重构代码。不包括 bug 修复、功能新增",
//     },
//     {
//       value: "perf",
//       name: "⚡ 性能优化",
//     },
//     { value: "test", name: "✅ 添加、修改测试用例" },
//     {
//       value: "build",
//       name: "👷‍ 构建流程、外部依赖变更，比如升级 npm 包、修改 webpack 配置",
//     },
//     { value: "ci", name: "🔧 修改了 CI 配置、脚本" },
//     {
//       value: "chore",
//       name: "对构建过程或辅助工具和库的更改,不影响源文件、测试用例的其他操作",
//     },
//     { value: "revert", name: "⏪ 回滚 commit" },
//   ],

//   // scope 类型，针对 React 项目
//   // scopes: [
//   //   ["components", "组件相关"],
//   //   ["hooks", "hook 相关"],
//   //   ["hoc", "HOC"],
//   //   ["utils", "utils 相关"],
//   //   ["antd", "对 antd 主题的调整"],
//   //   ["element-ui", "对 element-ui 主题的调整"],
//   //   ["styles", "样式相关"],
//   //   ["deps", "项目依赖"],
//   //   ["auth", "对 auth 修改"],
//   //   ["other", "其他修改"],
//   //   // 如果选择 custom ,后面会让你再输入一个自定义的 scope , 也可以不设置此项， 把后面的 allowCustomScopes 设置为 true
//   //   ["custom", "以上都不是？我要自定义"],
//   // ].map(([value, description]) => {
//   //   return {
//   //     value,
//   //     name: `${value.padEnd(30)} (${description})`,
//   //   };
//   // }),

//   // allowTicketNumber: false,
//   // isTicketNumberRequired: false,
//   // ticketNumberPrefix: 'TICKET-',
//   // ticketNumberRegExp: '\\d{1,5}',

//   // 可以设置 scope 的类型跟 type 的类型匹配项，例如: 'fix'
//   /*
//     scopeOverrides: {
//       fix: [
//         { name: 'merge' },
//         { name: 'style' },
//         { name: 'e2eTest' },
//         { name: 'unitTest' }
//       ]
//     },
//    */
//   // 覆写提示的信息
//   messages: {
//     type: "请确保你的提交遵循了原子提交规范！\n选择你要提交的类型:",
//     scope: "\n选择一个 scope (可选):",
//     // 选择 scope: custom 时会出下面的提示
//     // customScope: "请输入自定义的 scope:",
//     subject: "填写一个简短精炼的描述语句:\n",
//     body: '添加一个更加详细的描述，可以附上新增功能的描述或 bug 链接、截图链接 (可选)。使用 "|" 换行:\n',
//     breaking: "列举非兼容性重大的变更 (可选):\n",
//     footer: "",
//     confirmCommit: "确认提交?",
//   },

//   // 是否允许自定义填写 scope ，设置为 true ，会自动添加两个 scope 类型 [{ name: 'empty', value: false },{ name: 'custom', value: 'custom' }]
//   allowCustomScopes: true,
//   allowBreakingChanges: ["feat", "fix"],
//   // skip any questions you want
//   // skipQuestions: [],

//   // subject 限制长度
//   subjectLimit: 100,
//   // breaklineChar: '|', // 支持 body 和 footer
//   // footerPrefix : 'ISSUES CLOSED:'
//   // askForBreakingChangeFirst : true,
// };

module.exports = {
  types: [
    { value: "feat", name: "feat: 一个新的特性" },
    { value: "fix", name: "fix: 修复一个Bug" },
    { value: "docs", name: "docs: 变更的只有文档" },
    { value: "style", name: "style: 代码风格,格式修复" },
    { value: "refactor", name: "refactor: 代码重构，注意和feat、fix区分开" },
    { value: "perf", name: "perf: 码优化,改善性能" },
    { value: "test", name: "test: 测试" },
    { alue: "chore", name: "chore: 变更构建流程或辅助工具" },
    { value: "revert", name: "revert: 代码回退" },
    { value: "init", name: "init: 项目初始化" },
    { value: "build", name: "build: 变更项目构建或外部依赖" },
    { value: "WIP", name: "WIP: 进行中的工作" },
  ],
  scopes: [],
  allowTicketNumber: false,
  isTicketNumberRequired: false,
  ticketNumberPrefix: "TICKET-",
  ticketNumberRegExp: "\\d{1,5}",
  // it needs to match the value for field type. Eg.: 'fix'
  /*
  scopeOverrides: {
    fix: [
      {name: 'merge'},
      {name: 'style'},
      {name: 'e2eTest'},
      {name: 'unitTest'}
    ]
  },
  */
  // override the messages, defaults are as follows
  messages: {
    type: "选择一种你的提交类型:",
    scope: "选择一个scope (可选):",
    // used if allowCustomScopes is true
    customScope: "Denote the SCOPE of this change:",
    subject: "简短说明(最多40个字):",
    body: '长说明，使用"|"换行(可选)：\n',
    breaking: "非兼容性说明 (可选):\n",
    footer: "关联关闭的issue，例如：#12, #34(可选):\n",
    confirmCommit: "确定提交?",
  },
  allowCustomScopes: true,
  allowBreakingChanges: ["feat", "fix"],
  // skip any questions you want
  skipQuestions: ["scope", "body", "breaking"],
  // limit subject length
  subjectLimit: 100,
  // breaklineChar: '|', // It is supported for fields body and footer.
  // footerPrefix : 'ISSUES CLOSED:'
  // askForBreakingChangeFirst : true, // default is false
};
