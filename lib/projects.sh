#!/bin/bash

function submodules {
  if test -f .gitmodules; then
    grep -E '^\spath = ' .gitmodules \
    | sed 's/^\spath = //'
  fi
}


function subproject {
  ret=0
  subproject=$1
  if test 'set' = "${2:+set}"; then
    local background="${2}"
  fi

  local oldpwd="${PWD}"
  cd "${subproject}" || fail "Enter subproject directory:  ${subproject}"
  if test 'set' = "${background:+set}"; then
    project background &
    pid="${!}"
  else
    project
    ret="${?}"
  fi
  cd "${oldpwd}" || fail "Leave subproject directory:  ${subproject}"

  return "${ret}"
}


function project {
  local project="${subproject:-"${top_project}"}"
  subproject_pids=()
  subdir_pids=()
  remedial_subprojects=()
  declare -A subprojects_by_pid
  declare -A subdirs_by_pid
  ret=0
  if test 'set' = "${2:+set}"; then
    local background="${2}"
  fi

  phase1

  while read subproject; do
    unset pid
    subproject "${subproject}" background
    test 'set' = "${pid:+set}" || fail "No PID set for subproject:  ${subproject}"
    subproject_pids+=( "${pid}" )
    subprojects_by_pid[pid$pid]="${subproject}"
  done < <(submodules)

  while read subdir; do
    unset pid
    subproject "${subdir}" background
    test 'set' = "${pid:+set}" || fail "No PID set for subdir:  ${subdir}"
    subdir_pids+=( "${pid}" )
    subdirs_by_pid[pid$pid]="${subdir}"
  done < <(
    if test -f .gitignore; then
      ls -d $(cat .gitignore) 2>/dev/null | while read d; do
        if test -d "${d}"; then
          echo "${d}"
        fi
      done
    fi
  )

  for subdir_pid in "${subdir_pids[@]}"; do
    subdir="${subdirs_by_pid[pid$subdir_pid]}"
    wait -f "${subdir_pid}"
    subdir_ret="${?}"
    case "${subdir_ret}" in
      0)
        true
        ;;
      2)
        # It may be more efficient to pass back a list of changed
        # sub-(sub-)projects, and only act on those directories.
        if test 'set' = "${background:+set}"; then
          ret=2
        else
          remedial_subprojects+=( "${subdir}" )
        fi
        ;;
      *)
        fail "A forked process has failed:  (${subdir}) (${subdir_ret})"
        ;;
    esac
  done

  for subproject_pid in "${subproject_pids[@]}"; do
    subproject="${subprojects_by_pid[pid$subproject_pid]}"
    wait -f "${subproject_pid}" 
    subproject_ret="${?}"
    case "${subproject_ret}" in
      0)
        true
        ;;
      2)
        # It may be more efficient to pass back a list of changed
        # sub-(sub-)projects, and only act on those directories.
        if test 'set' = "${background:+set}"; then
          ret=2
        else
          remedial_subprojects+=( "${subproject}" )
        fi
        ;;
      *)
        fail "A forked process has failed:  (${subproject}) (${subproject_ret})"
        ;;
    esac
  done

  for subproject in "${remedial_subprojects[@]}"; do
    subproject "${subproject}" || fail "Subproject:  ${subproject}"
  done

  for subproject_pid in "${subproject_pids[@]}"; do
    subproject="${subprojects_by_pid[pid$subproject_pid]}"
    git add "${subproject}" >/dev/null 2>&1 || fail "git add ${subproject} # submodule"
  done

  phase2

  git diff-index --quiet HEAD
  git_diff_index_ret=$?
  case "${git_diff_index_ret}" in
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

  return "${ret}"
}
