#!/bin/bash


function main() {
  message="${1}"

  unset background

  commit_args=''
  if grep -q '.' <<< "${message}"; then
    commit_args="-S -m '$(sed "s/'/'\"'\"'/g" <<< ${message})'"
  fi

  branch="$(git branch | grep '^\*' | sed 's/^* //')" || fail "Failed to find branch."
  debug "branch='${branch}'"

  project
}
