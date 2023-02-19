#!/bin/bash


function git_checkout() {
  if git diff --quiet --exit-code >/dev/null 2>&1; then
    # Locking errors occur on:  .git/index.lock
    # Cause unknown.  'git checkout' returns:  128
    # 2021-03-26:  Hypothesis:  There is a collision because subprojects' git
    # configuration refers to higher level projects' configuration, so while
    # processing subprojects in parallel, they will need to lock the same
    # file(s).
    # 2023-02-19:  Haven't seen that lately.
    i=0
    git_checkout_ret=128
    while test 128 -eq "${git_checkout_ret}"; do
      i="$(( i + 1 ))"
      if test 5 -lt "${i}"; then
        fail "Locked up."
      fi
      git checkout master >/dev/null 2>&1 && break
      git_checkout_ret="${?}"
      sleep .1
    done
  fi
}


function git_submodule_init() {
  git submodule init >/dev/null 2>&1 || fail "submodule init"
}


function git_pull() {
  git pull >/dev/null 2>&1 || fail "pull"
}


function git_add() {
  git add . >/dev/null 2>&1 || fail "add files"
  git add -u . >/dev/null 2>&1 || fail "remove files"
}


function git_commit() {
  # No quotes.
  eval git commit ${commit_args} || fail "commit"
}


function git_push() {
  git push >/dev/null 2>&1 || fail "push"
}


function git_push_old() {
  # No changes to commit.  Push any old commits.
  git push --dry-run >/dev/null 2>&1 && git push >/dev/null 2>&1 || warn "push"
  git push --tags >/dev/null 2>&1 || warn "push tags"
}


function git_submodule_update() {
  git submodule update >/dev/null 2>&1 || fail "update"
}


function git_change_status() {
  git diff-index --quiet HEAD
}
