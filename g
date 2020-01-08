#!/bin/bash

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


function output {
  printf "%10s (%s):  %s\n" "(${project})" "${background:-}" "${1}"
}


function warn {
  output "WARNING: (${?}) ${1}" >&2
}


function error {
  output "ERROR:   (${?}) ${1}" >&2
}


function fail {
  error "${1}"
  exit "${2:-1}"
}


function debug {
  output "DEBUG:   (${?}) ${1}" >&2
}


function submodules {
  if test -f .gitmodules; then
    grep -E '^\spath = ' .gitmodules \
    | sed 's/^\spath = //'
  fi
}


function phase1 {
  if git diff --quiet --exit-code >/dev/null 2>&1; then
    # Locking errors occur on:  .git/index.lock
    # Cause unknown.  'git checkout' returns:  128
    i=0
    git_checkout_ret=128
    while test $git_checkout_ret -eq 128; do
      i=$((i+1))
      if test $i -gt 5; then
        fail "Locked up."
      fi
      git checkout master >/dev/null 2>&1 && break
      git_checkout_ret=$?
      sleep .1
    done
  fi
  git submodule init >/dev/null 2>&1 || fail "submodule init"
}


function phase2 {
  git pull >/dev/null 2>&1 || fail "pull"
  git add . >/dev/null 2>&1 || fail "add files"
  git add -u . >/dev/null 2>&1 || fail "remove files"
}


function phase3 {
  git_tag_increment "${level}" || fail "tag"
  eval git commit ${commit_args} || fail "commit"
}


function phase4 {
  git checkout master >/dev/null 2>&1 || fail "checkout master (phase 4)"
  git push >/dev/null 2>&1 || fail "push"
  git push --tags >/dev/null 2>&1 || fail "push tags"
  git submodule update >/dev/null 2>&1 || fail "update"
  if ! test 'set' = "${background:+set}"; then
    echo -n "${project}:  "
    git tag | sort -V | tail -n 1 || fail "display current version"
  fi
}


function subproject {
  ret=0
  subproject=$1
  if test 'set' = "${2:+set}"; then
    local background="${2}"
  fi

  local oldpwd=$PWD
  cd $subproject || fail "Enter subproject directory:  ${subproject}"
  if test 'set' = "${background:+set}"; then
    project background &
    pid=$!
  else
    project
    ret=$?
  fi
  cd $oldpwd || fail "Leave subproject directory:  ${subproject}"

  return $ret
}


function project {
  project="${subproject:-[top]}"
  subproject_pids=()
  remedial_subprojects=()
  declare -A subprojects_by_pid
  ret=0
  if test 'set' = "${2:+set}"; then
    local background="${2}"
  fi

  phase1

  for subproject in $(submodules); do 
    unset pid
    subproject $subproject background
    test 'set' = "${pid:+set}" || fail "No PID set for subproject:  ${subproject}"
    subproject_pids+=( $pid )
    subprojects_by_pid[pid$pid]="${subproject}"
  done

  for subproject_pid in "${subproject_pids[@]}"; do
    subproject="${subprojects_by_pid[pid$subproject_pid]}"
    wait -f "${subproject_pid}" 
    subproject_ret=$?
    case $subproject_ret in
      0)
        true
        ;;
      2)
        # It may be more efficient to pass back a list of changed
        # sub-(sub-)projects, and only act on those directories.
        if test 'set' = "${background:+set}"; then
          ret=2
        else
          remedial_subprojects+=( $subproject )
        fi
        ;;
      *)
        fail "A forked process has failed:  (${subproject}) (${subproject_ret})"
        ;;
    esac
  done

  for subproject in "${remedial_subprojects[@]}"; do
    subproject $subproject || fail "Subproject:  ${subproject}"
  done

  for subproject_pid in "${subproject_pids[@]}"; do
    subproject="${subprojects_by_pid[pid$subproject_pid]}"
    git add $subproject >/dev/null 2>&1 || fail "git add ${subproject} # submodule"
  done

  phase2

  git diff-index --quiet HEAD
  git_diff_index_ret=$?
  case $git_diff_index_ret in
    0)
      phase4
      ;;
    1)
      if ! test 'set' = "${background:+set}"; then
        phase3
        phase4
      else
        # Alert parent to try again in foreground.
        ret=2
      fi
      ;;
    *)
      fail "unrecognized return code from git diff-index:  ${ret}"
  esac

  return $ret
}


project
