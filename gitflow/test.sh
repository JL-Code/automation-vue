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

  # sanity checks
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

  # # try to merge into master
  # # in case a previous attempt to finish this release branch has failed,
  # # but the merge into master was successful, we skip it now
  # # 尝试合并到 master
  # # 如果之前尝试完成此发布分支失败，
  # # 但是合并到 master 是成功的，我们现在跳过它
  # if ! git_is_branch_merged_into "$BRANCH" "$MASTER_BRANCH"; then
  #   git_do checkout "$MASTER_BRANCH" ||
  #     die "Could not check out $MASTER_BRANCH."
  #   git_do merge --no-ff "$BRANCH" ||
  #     die "There were merge conflicts."
  #   # TODO: What do we do now?
  # fi

  # if noflag notag; then
  #   # try to tag the release
  #   # in case a previous attempt to finish this release branch has failed,
  #   # but the tag was set successful, we skip it now
  #   # 尝试标记版本
  #   # 如果之前尝试完成此发布分支失败，
  #   # 但是标签设置成功，我们现在跳过它
  #   local tagname=$VERSION_PREFIX$VERSION
  #   if ! git_tag_exists "$tagname"; then
  #     local opts="-a"
  #     flag sign && opts="$opts -s"
  #     [ "$FLAGS_signingkey" != "" ] && opts="$opts -u '$FLAGS_signingkey'"
  #     [ "$FLAGS_message" != "" ] && opts="$opts -m '$FLAGS_message'"
  #     [ "$FLAGS_messagefile" != "" ] && opts="$opts -F '$FLAGS_messagefile'"
  #     eval git_do tag $opts "$VERSION_PREFIX$VERSION" "$BRANCH" ||
  #       die "Tagging failed. Please run finish again to retry."
  #   fi
  # fi

  # # try to merge into develop
  # # in case a previous attempt to finish this release branch has failed,
  # # but the merge into develop was successful, we skip it now
  # # 尝试合并到 develop
  # # 如果之前尝试完成此发布分支失败，
  # # 但是合并到 develop 是成功的，我们现在跳过它
  # if ! git_is_branch_merged_into "$BRANCH" "$DEVELOP_BRANCH"; then
  #   git_do checkout "$DEVELOP_BRANCH" ||
  #     die "Could not check out $DEVELOP_BRANCH."

  #   # TODO: Actually, accounting for 'git describe' pays, so we should
  #   # ideally git merge --no-ff $tagname here, instead!
  #   git_do merge --no-ff "$BRANCH" ||
  #     die "There were merge conflicts."
  #   # TODO: What do we do now?
  # fi

  # # delete branch
  # # 删除分支
  # if noflag keep; then
  #   git_do branch -d "$BRANCH"
  # fi

  # if flag push; then
  #   git_do push "$ORIGIN" "$DEVELOP_BRANCH" ||
  #     die "Could not push to $DEVELOP_BRANCH from $ORIGIN."
  #   git_do push "$ORIGIN" "$MASTER_BRANCH" ||
  #     die "Could not push to $MASTER_BRANCH from $ORIGIN."
  #   if noflag notag; then
  #     git_do push --tags "$ORIGIN" ||
  #       die "Could not push tags to $ORIGIN."
  #   fi
  # fi

  # echo
  # echo "Summary of actions:"
  # echo "- Latest objects have been fetched from '$ORIGIN'"
  # echo "- Hotfix branch has been merged into '$MASTER_BRANCH'"
  # if noflag notag; then
  #   echo "- The hotfix was tagged '$VERSION_PREFIX$VERSION'"
  # fi
  # echo "- Hotfix branch has been back-merged into '$DEVELOP_BRANCH'"
  # if flag keep; then
  #   echo "- Hotfix branch '$BRANCH' is still available"
  # else
  #   echo "- Hotfix branch '$BRANCH' has been deleted"
  # fi
  # if flag push; then
  #   echo "- '$DEVELOP_BRANCH', '$MASTER_BRANCH' and tags have been pushed to '$ORIGIN'"
  # fi
  # echo
}

parse_args() {
  # parse options
  # 解析选项
  FLAGS "$@" || exit $?
  eval set -- "${FLAGS_ARGV}"

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

cmd_finish "$@"
