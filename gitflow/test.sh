#!/bin/bash
echo "当前执行脚本路径：$0"

. "./shflags"

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
      die "Could not fetch $MASTER_BRANCH from $ORIGIN."
    git_do fetch -q "$ORIGIN" "$DEVELOP_BRANCH" ||
      die "Could not fetch $DEVELOP_BRANCH from $ORIGIN."
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
#
git_local_branches() { git branch --no-color | sed 's/^[* ] //'; }
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
die() {
  warn "$@"
  exit 1
}

escape() {
  echo "$1" | sed 's/\([\.\$\*]\)/\\\1/g'
}

# set logic
has() {
  local item=$1
  shift
  echo " $@ " | grep -q " $(escape $item) "
}

cmd_finish "$@"
