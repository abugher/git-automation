#!/bin/bash

l="${2}"
message="${1}"

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
if echo "${message}" | grep -q '.'; then
  commit_args="-m '$(sed "s/'/'\"'\"'/g" <<< ${message})'"
fi


function fail {
  ret=$?
  echo "Failed:  ${1}" >&2
  exit $ret
}


function recurse {
  if git diff --quiet --exit-code; then
    git checkout master || fail "checkout master"
  fi
  git submodule init || fail "submodule init"

  for s in $(
    if test -f .gitmodules; then
      grep -E '^\spath = ' .gitmodules \
      | sed 's/^\spath = //'
    fi
  ); do 
    local subproject=$s
    echo "Begin subproject:  ${subproject}"
    local oldpwd=$PWD
    cd $subproject || fail "Enter subproject directory:  ${subproject}"
    recurse || fail "recurse"
    cd $oldpwd || fail "Leave subproject directory:  ${subproject}"
    git add $subproject || fail "git add ${subproject} # submodule"
    echo "End subproject:  ${subproject}"
  done

  git pull || fail "pull"
  git add . || fail "add files"
  git add -u . || fail "remove files"

  git diff-index --quiet HEAD
  ret=$?
  case $ret in
    0)
      true
      ;;
    1)
      git_tag_increment "${level}" || fail "tag"
      eval git commit ${commit_args} || fail "commit"
      ;;
    *)
      fail "unrecognized return code from git diff-index:  ${ret}"
  esac

  git checkout master || fail "checkout master"

  git push || fail "push"
  git push --tags || fail "push tags"
  git submodule update || fail "update"
  git tag | sort -V | tail -n 1 || fail "display current version"
}


recurse

