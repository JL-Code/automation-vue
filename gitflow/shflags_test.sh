#!/bin/sh

# source shflags
. ./shflags

parse_args() {
  # parse options
  # 解析选项
  FLAGS "$@" || exit $?
  eval set -- "${FLAGS_ARGV}"
  echo "parse_args-FLAGS_ARGV: $FLAGS_ARGV"
  echo "parse_args-FLAGS_fetch: $FLAGS_fetch"
}

run() {

  # define a 'name' command-line string flag
  DEFINE_string 'name' 'world' 'name to say hello to' 'n'
  DEFINE_boolean fetch false "fetch from $ORIGIN before performing finish" F

  # parse the command-line
  parse_args "$@"

  # say Hello!
  echo "Hello, ${FLAGS_name}!"
  echo "Fetch, ${FLAGS_fetch}!"
}

run "$@"

# ./shflags_test.sh -n jiangy -F