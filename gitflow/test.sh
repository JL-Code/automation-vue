#!/bin/bash
echo "当前执行脚本路径：$0"

. "./shflags"

# 谁在什么时候调用了？
init() {
  require_git_repo
  # require_gitflow_initialized
  gitflow_load_settings
  VERSION_PREFIX=$(eval "echo $(git config --get gitflow.prefix.versiontag)") # 获取版本前缀
  PREFIX=$(git config --get gitflow.prefix.hotfix) # 获取 hotfix 版本前缀
}

cmd_finish() {

  # define a 'fetch' command-line boolean flag
  # shflgs 语法： DEFINE_xxx 标志 标志默认值 标志描述 短标志
  # eg: DEFINE_string 'name' 'world' 'name to say hello to' 'n'
  # 解析：我们定义了一个 string 的标志 name 默认值为 'world' 使用 'name to say hello to' 描述这个标志，并且提供了一个简短的标志别名 n 。
  # shFlags 将知道如何解析 ——name 、 -n 标志。
  DEFINE_boolean fetch false "fetch from $ORIGIN before performing finish" F
  DEFINE_boolean sign false "sign the release tag cryptographically" s
  DEFINE_string signingkey "" "use the given GPG-key for the digital signature (implies -s)" u
  DEFINE_string message "" "use the given tag message" m
  DEFINE_string messagefile "" "use the contents of the given file as tag message" f
  DEFINE_boolean push false "push to $ORIGIN after performing finish" p
  DEFINE_boolean keep false "keep branch after performing finish" k
  DEFINE_boolean notag false "don't tag this release" n

  parse_args "$@"
  require_version_arg

  # handle flags that imply other flags
  # 处理暗示其他标志的标志
  if [ "$FLAGS_signingkey" != "" ]; then
    FLAGS_sign=$FLAGS_TRUE
  fi
  echo "ORIGIN:$ORIGIN"
  echo "BRANCH:$BRANCH"
  echo "MASTER_BRANCH:$MASTER_BRANCH"
  echo "DEVELOP_BRANCH:$DEVELOP_BRANCH"
  # 健全性检查
  require_branch "$BRANCH"
  require_clean_working_tree
  if flag fetch; then
    git_do fetch -q "$ORIGIN" "$MASTER_BRANCH" ||
      die "无法获取 $MASTER_BRANCH 从 $ORIGIN."
    git_do fetch -q "$ORIGIN" "$DEVELOP_BRANCH" ||
      die "无法获取 $DEVELOP_BRANCH 从 $ORIGIN."
  fi
  if has "$ORIGIN/$MASTER_BRANCH" $(git_remote_branches); then
    require_branches_equal "$MASTER_BRANCH" "$ORIGIN/$MASTER_BRANCH"
  fi
  if has "$ORIGIN/$DEVELOP_BRANCH" $(git_remote_branches); then
    require_branches_equal "$DEVELOP_BRANCH" "$ORIGIN/$DEVELOP_BRANCH"
  fi
}

# convenience functions for checking shFlags flags
# 用于检查 shFlags 标志的便利功能
flag() {
  local FLAG
  eval FLAG='$FLAGS_'$1
  [ $FLAG -eq $FLAGS_TRUE ]
}
noflag() {
  local FLAG
  eval FLAG='$FLAGS_'$1
  [ $FLAG -ne $FLAGS_TRUE ]
}

parse_args() {
  # parse options
  # 解析选项
  FLAGS "$@" || exit $?
  eval set -- "${FLAGS_ARGV}"
  echo "FLAGS_ARGV: $FLAGS_ARGV"
  # read arguments into global variables
  # 将参数读入全局变量
  VERSION=$1
  BRANCH=$PREFIX$VERSION
}

require_version_arg() {
  if [ "$VERSION" = "" ]; then
    warn "Missing argument <version>"
    usage
    exit 1
  fi
}

require_branch() {
  if ! has $1 $(git_all_branches); then
    die "Branch '$1' does not exist and is required."
  fi
}

#
# Assertions for use in git-flow subcommands 
# 在 gitflow 子命令中使用的断言
#

require_git_repo() {
	if ! git rev-parse --git-dir >/dev/null 2>&1; then
		die "fatal: Not a git repository"
	fi
}
# 检查是否已经初始化 gitflow
require_gitflow_initialized() {
	if ! gitflow_is_initialized; then
		die "fatal: Not a gitflow-enabled repo yet. Please run \"git flow init\" first."
	fi
}

require_clean_working_tree() {
  git_is_clean_working_tree
  local result=$?
  if [ $result -eq 1 ]; then
    die "fatal: 工作树包含未暂存的更改。中止。"
  fi
  if [ $result -eq 2 ]; then
    die "fatal: 索引包含未提交的更改。中止。"
  fi
}

#
# Git common function
# 获取 Git 本地跟踪分支
git_local_branches() { git branch --no-color | sed 's/^[* ] //'; }
# 获取 Git 远程跟踪分支
git_remote_branches() { git branch -r --no-color | sed 's/^[* ] //'; }
git_all_branches() { (
  git branch --no-color
  git branch -r --no-color
) | sed 's/^[* ] //'; }
git_all_tags() { git tag; }

git_current_branch() {
  git branch --no-color | grep '^\* ' | grep -v 'no branch' | sed 's/^* //g'
}

git_all_branches() { (
  git branch --no-color
  git branch -r --no-color
) | sed 's/^[* ] //'; }

git_is_clean_working_tree() {
  if ! git diff --no-ext-diff --ignore-submodules --quiet --exit-code; then
    return 1
  elif ! git diff-index --cached --quiet --ignore-submodules HEAD --; then
    return 2
  else
    return 0
  fi
}

# git_compare_branches()

# Tests whether branches and their "origin" counterparts have diverged and need
# merging first. It returns error codes to provide more detail, like so:

# 0    Branch heads point to the same commit
# 1    First given branch needs fast-forwarding
# 2    Second given branch needs fast-forwarding
# 3    Branch needs a real merge
# 4    There is no merge base, i.e. the branches have no common ancestors

git_compare_branches() {
  local commit1=$(git rev-parse "$1")
  local commit2=$(git rev-parse "$2")
  if [ "$commit1" != "$commit2" ]; then
    local base=$(git merge-base "$commit1" "$commit2")
    if [ $? -ne 0 ]; then
      return 4
    elif [ "$commit1" = "$base" ]; then
      return 1
    elif [ "$commit2" = "$base" ]; then
      return 2
    else
      return 3
    fi
  else
    return 0
  fi
}

require_branches_equal() {
  require_local_branch "$1"
  require_remote_branch "$2"
  git_compare_branches "$1" "$2"
  local status=$?
  if [ $status -gt 0 ]; then
    warn "Branches '$1' and '$2' have diverged."
    if [ $status -eq 1 ]; then
      die "And branch '$1' may be fast-forwarded."
    elif [ $status -eq 2 ]; then
      # Warn here, since there is no harm in being ahead
      warn "And local branch '$1' is ahead of '$2'."
    else
      die "Branches need merging first."
    fi
  fi
}

require_local_branch() {
  if ! git_local_branch_exists $1; then
    die "fatal: Local branch '$1' does not exist and is required."
  fi
}

git_local_branch_exists() {
  has $1 $(git_local_branches)
}

require_remote_branch() {
  if ! has $1 $(git_remote_branches); then
    die "Remote branch '$1' does not exist and is required."
  fi
}

git_do() {
  # equivalent to git, used to indicate actions that make modifications
  # 等效于 git，用于指示进行修改的操作
  if flag show_commands; then
    echo "git $@" >&2
  fi
  git "$@"
}

usage() {
  echo "usage: git flow hotfix [list] [-v]"
  echo "       git flow hotfix start [-F] <version> [<base>]"
  echo "       git flow hotfix finish [-Fsumpk] <version>"
  echo "       git flow hotfix publish <version>"
  echo "       git flow hotfix track <version>"
}

# Common functionality
# shell output
warn() { echo "$@" >&2; }
# 失败警告函数
die() {
  warn "$@"
  exit 1
}

escape() {
  echo "$1" | sed 's/\([\.\$\*]\)/\\\1/g'
}

# set logic
# 判断传入第一个参数是否包含在后续参数中
has() {
  local item=$1
  shift
  echo " $@ " | grep -q " $(escape $item) "
}

# loading settings that can be overridden using git config
gitflow_load_settings() {
  export DOT_GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)      # eg: /Users/codeme/workspace/vue-projects/automation-vue/.git
  export MASTER_BRANCH=$(git config --get gitflow.branch.master) # eg: master
  export DEVELOP_BRANCH=$(git config --get gitflow.branch.develop)
  export ORIGIN=$(git config --get gitflow.origin || echo origin)
}

cmd_finish "$@"
