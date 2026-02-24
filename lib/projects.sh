#!/bin/bash

function subprojects {
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


function subprojects_background {
  while read subproject; do
    unset pid
    subproject "${subproject}" background
    test 'set' = "${pid:+set}" || fail "No PID set for subproject:  ${subproject}"
    subproject_pids+=( "${pid}" )
    subs_by_pid[pid$pid]="${subproject}"
  done < <(subprojects)
}


function subdirs_background {
  while read subdir; do
    unset pid
    if test -e "${subdir}/.git"; then
      subproject "${subdir}" background
      test 'set' = "${pid:+set}" || fail "No PID set for subdir:  ${subdir}"
      subdir_pids+=( "${pid}" )
      subs_by_pid[pid$pid]="${subproject}"
    fi
  done < <(subdirs)
}


function subdirs {
  if test -f .gitignore; then
    ls -d $(cat .gitignore) 2>/dev/null | while read d; do
      if test -d "${d}"; then
        echo "${d}"
      fi
    done
  fi
}


function project {
  local project="${subproject:-"${top_project}"}"
  subproject_pids=()
  subdir_pids=()
  remedial_subprojects=()
  declare -A subs_by_pid
  ret=0
  if test 'set' = "${2:+set}"; then
    local background="${2}"
  fi

  case "${self_name}" in
    g)
      git_checkout
      git_submodule_init
    ;;
    sync_from)
      git_sync_from_branch
    ;;
    *)
      fail "I don't know how to be:  '${self_name}'"
    ;;
  esac

  cache_pull

  subprojects_background
  subdirs_background

  for sub_pid in "${subproject_pids[@]}" "${subdir_pids[@]}"; do
    if test '' = "${sub_pid}"; then
      warn "Empty PID:  '${sub_pid}'"
      continue
    fi
    sub="${subs_by_pid[pid$sub_pid]}"
    wait -f "${sub_pid}" 
    sub_ret="${?}"
    case "${sub_ret}" in
      0)
        true
        ;;
      2)
        if test 'set' = "${background:+set}"; then
          ret=2
        else
          remedial_subprojects+=( "${sub}" )
        fi
        ;;
      *)
        fail "A forked process has failed:  (${sub}) (${sub_ret})"
        ;;
    esac
  done

  for subproject in "${remedial_subprojects[@]}"; do
    subproject "${subproject}" || fail "Subproject:  ${subproject}"
  done

  for subproject_pid in "${subproject_pids[@]}"; do
    subproject="${subs_by_pid[pid$subproject_pid]}"
    if test '' = "${subproject}"; then
      warn "Empty subproject:  '${subproject}'"
      warn "PID:  '${suproject_pid}'"
      continue
    fi
    git add "${subproject}" >/dev/null 2>&1 || fail "git add ${subproject} # submodule"
  done

  git_pull
  git_add

  git_change_status
  change_status=$?

  case "${change_status}" in
    0)
      git_push_old
      git_submodule_update
      ;;
    1)
      if ! test 'set' = "${background:+set}"; then
        case "${self_name}" in
          g)
            git_commit
            git_push
            git_submodule_update
          ;;
          sync_from)
            true
          ;;
          *)
            fail "I don't know how to be:  '${self_name}'"
          ;;
        esac
      else
        # Alert parent to try again in foreground.
        ret=2
      fi
      ;;
    *)
      fail "unrecognized return code from git diff-index:  ${ret}"
  esac

  cache_push

  return "${ret}"
}


# cache_pull, cache_push:  Special handling for my own style of local caching.
# *.sync is a working repo intended to pull from the network upstream and push
# to the local cache.  *.git is a bare repo intended to serve as local cache.


function cache_pull() {
  for sync in *.sync; do
    local oldpwd="${PWD}"
    cd "${sync}" || fail "Failed to enter cache sync repo directory:  '${sync}'"
    git_pull
    git push
    cd "${oldpwd}" || fail "Failed to leave cache sync repo directory:  '${sync}'"
  done
}


function cache_push() {
  for cache in *.git; do
    local oldpwd="${PWD}"
    cd "${cache}" || fail "Failed to enter cache repo directory:  '${cache}'"
    git push
    cd "${oldpwd}" || fail "Failed to leave cache repo directory:  '${cache}'"
  done
}
