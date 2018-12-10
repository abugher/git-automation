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
  echo "DEBUG:  recurse"
  git submodule init

  echo "DEBUG:  enter subprojects"
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
  echo "DEBUG:  exit subprojects"

  echo "DEBUG:  add files"
  git add . || fail "add files"
  echo "DEBUG:  remove files"
  git add -u . || fail "remove files"

  echo "DEBUG:  check for changes"
  git diff-index --quiet HEAD
  case $? in
    0)
      echo "DEBUG:  no changes"
      true
      ;;
    1)
      echo "DEBUG:  changes:  commit"
      eval git commit ${commit_args} || fail "commit"
      echo "DEBUG:  changes:  git_tag_increment"
      git_tag_increment "${level}" || fail "tag"
      echo "DEBUG:  changes:  add files"
      git add . || fail "add files"
      echo "DEBUG:  changes:  check for changes"
      git diff-index --quiet HEAD
      case $? in
        0)
          echo "DEBUG:  changes:  unchanged"
          true
          ;;
        1)
          echo "DEBUG:  changes:  changed:  commit"
          eval git commit ${commit_args} -m "'Posting old test files for comparison.'" || fail "commit"
          ;;
        *)
          echo "DEBUG:  changes:  confused"
          fail "check for old test files to commit"
          ;;
      esac
      ;;
    *)
      echo "DEBUG:  confusion"
      fail "check for changes to commit"
  esac

  echo "DEBUG:  checkout master"
  git checkout master || fail "checkout master"

  echo "DEBUG:  push"
  git push || fail "push"
  echo "DEBUG:  push tags"
  git push --tags || fail "push tags"
  echo "DEBUG:  pull"
  git pull || fail "pull"
  echo "DEBUG:  pull"
  git submodule update || fail "update"
  echo "DEBUG:  tag"
  git tag | sort -V | tail -n 1 || fail "display current version"
}


recurse

