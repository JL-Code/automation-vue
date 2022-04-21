# 脚本执行目录
SHELL_DIR=$(dirname "$0")
TARGET_BRANCH=${1/origin\//}
SOURCE_BRANCH=${2/origin\//}
CURRENT_USER=$(who)
echo "谁在执行脚本：$CURRENT_USER"
echo "脚本执行目录：$SHELL_DIR"
echo "参数1：$TARGET_BRANCH"
echo "参数2：$SOURCE_BRANCH"

# if [ "$run_mode" = "docker-compose" ];then
#   docker-compose -f "$SHELL_DIR"/docker-compose.yml down
#   tags=$(docker images | grep "$repo" | awk '{ print $2}')
#   echo "$tags"
#   # 循环
#   for tag in $tags; do
#     if [ "$tag" = "$revision" ]; then
#       echo "$tag"
#       echo "$repo:$tag"
#       docker rmi "$repo:$tag"
#       docker images | grep "$repo"
#     fi
#   done
#   docker-compose -f "$SHELL_DIR"/docker-compose.yml up -d
# elif [ "$run_mode" = "docker-swarm" ]; then
#   echo """docker stack deploy -c $SHELL_DIR/docker-compose.yml $stack_name"""
#   docker stack deploy -c "$SHELL_DIR"/docker-compose.yml "$stack_name"
# fi

# 0.1 checkout source code
# 0.2 checkout target code

## 0.2 删除 source 的 .git
cd "$SHELL_DIR" && cd ../../source && rm -rf .git && cd ../target
# shellcheck disable=SC2063
echo "当前分支：$(git branch | grep ^\*)"
# shell 替换字符串 1. ${<str>//} 2. sed 3. awk 。 ref:https://blog.csdn.net/whatday/article/details/104963945
echo "切换到分支：""${TARGET_BRANCH}"
git checkout "${TARGET_BRANCH}"
# shellcheck disable=SC2063
echo "当前分支：$(git branch | grep ^\*)"
# 1.移除目标内冗余文件，但不包括 build/、src/apps/、Dockerfile、Jenkinsfile、.git/ .env.[MODE]

PWD_DIR=$(pwd)/
echo "当前目录：$PWD_DIR"

exclude_files=('docs','doc','build' 'src' 'Dockerfile' 'Jenkinsfile' '.dockerignore' '.git' '.' '..')
target_files=$(ls -a | grep -v '^.env.' | grep -v .git | grep -v .gitignore | grep -v Dockerfile | grep -v Jenkinsfile | grep -v nginx.conf)
# 判断一个字符串是否在数组中，语法： [[ "${array[@]}" =~ "字符串" ]] 。array 为数组变量
#  匹配以 .env. 开头的文本 (^) ls -a | grep '^.env.' https://www.myfreax.com/regular-expressions-in-grep/
# 反转匹配（不匹配） grep -v  https://linux.cn/article-6927-1.html
for fname in $target_files; do
  if [[ ! "${exclude_files[*]}" =~ $fname ]]; then
    # echo "rm $PWD_DIR$filename ..."
    rm -rf "$PWD_DIR$fname"
  fi
  # 1.1. 移除 src 目录内冗余文件，但不包括 apps
  if [ "$fname" = "src" ]; then
    src_files=$(cd src && ls | grep -v apps && cd ..)
    for filename in $src_files; do
      rm -rf "$PWD_DIR"src/"$filename"
    done
  fi
done

# ls -a

# 2. 将 source 复制到 target （静默覆盖策略）source/. 会拷贝 source目录下的隐藏文件到目标目录，source/* 则不会。
cd .. && cp -rf source/. target && cd ./target || exit

echo "当前目录: $(pwd)"

# 3. 提交代码变更

echo '============================commit before==========================='
git add .
git commit -m 'ci: 0000-脚本自动同步泽U代码-'"$SOURCE_BRANCH"' TO '"$TARGET_BRANCH"
echo '============================commit after============================'
git status
# 4. 推送代码变更
git push origin "${TARGET_BRANCH}"
echo '============================push done============================'
git status
