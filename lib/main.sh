#!/bin/bash


function main() {
  message="${1}"

  unset background

  commit_args=''
  if grep -q '.' <<< "${message}"; then
    commit_args="-S -m '$(sed "s/'/'\"'\"'/g" <<< ${message})'"
  fi

  project
}
