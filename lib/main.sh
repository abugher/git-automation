#!/bin/bash


function main() {
  shopt -s nullglob

  # The argument can be a message or a branch depending on context.
  message="${1}"
  upstream_branch="${1}"

  unset background

  commit_args=''
  if grep -q '.' <<< "${message}"; then
    commit_args="-S -m '$(sed "s/'/'\"'\"'/g" <<< ${message})'"
  fi

  branch="$(git branch | grep '^\*' | sed 's/^* //')" || fail "Failed to find branch."

  project
}
