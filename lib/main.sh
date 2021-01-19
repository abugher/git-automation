#!/bin/bash


function main() {
  l="${2}"
  message="${1}"

  unset background

  case "${l}" in
    'patch')
      level='patch'
      ;;
    'minor')
      level='minor'
      ;;
    'major')
      level='major'
      ;;
    'automatic')
      level='automatic'
      ;;
    '')
      level='automatic'
      ;;
    *)
      echo "What's ${l}?"
      exit 1
      ;;
  esac

  commit_args=''
  if grep -q '.' <<< "${message}"; then
    commit_args="-m '$(sed "s/'/'\"'\"'/g" <<< ${message})'"
  fi


  project
}
