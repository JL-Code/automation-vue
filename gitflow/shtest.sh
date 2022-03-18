#!/bin/bash
test_empty_string_is_false() {
  if ! ""; then
    echo "empty string is false"
  fi
}

test_empty_string_is_false
