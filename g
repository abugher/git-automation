#!/bin/bash

l="${1}"

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
message="${2}"
if echo "${message}" | grep -q '.'; then
  commit_args="-m '${message}'"
fi


function fail {
  ret=$?
  echo "Failed:  ${1}" >&2
  exit $ret
}


function recurse {
  git submodule init

  for subproject in $(
    if test -f .gitmodules; then
      grep -E '^\spath = ' .gitmodules \
      | sed 's/^\spath = //'
    fi
  ); do 
    echo "Enter subproject:  ${subproject}"
    cd $subproject || fail "enter subproject directory:  ${subproject}"
    recurse || fail "recurse"
    cd - || fail "leave subproject directory:  ${subproject}"
    git add $subproject || fail "git add ${subproject} # submodule"
    echo "Leave subproject:  ${subproject}"
  done

  git add . || fail "add files"
  git add -u . || fail "remove files"

  git diff-index --quiet HEAD

  case $? in
    0)
      true
      ;;
    1)
      eval git commit ${commit_args} || fail "commit"
      git_tag_increment "${level}" || fail "tag"
      git add . || fail "add files"
      git diff-index --quiet HEAD
      case $? in
        0)
          true
          ;;
        1)
          eval git commit ${commit_args} -m "'Posting old test files for comparison.'" || fail "commit"
          ;;
        *)
          fail "check for old test files to commit"
          ;;
      esac
      ;;
    *)
      fail "check for changes to commit"
  esac

  git checkout master || fail "checkout master"

  git push || fail "push"
  git push --tags || fail "push tags"
  git pull || fail "pull"
  git submodule update || fail "update"
  git tag | sort -V | tail -n 1 || fail "display current version"
}


recurse

