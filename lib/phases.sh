#!/bin/bash


function phase1() {
  if git diff --quiet --exit-code >/dev/null 2>&1; then
    # Locking errors occur on:  .git/index.lock
    # Cause unknown.  'git checkout' returns:  128
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
  git submodule init >/dev/null 2>&1 || fail "submodule init"
}


function phase2() {
  git pull >/dev/null 2>&1 || fail "pull"
  git add . >/dev/null 2>&1 || fail "add files"
  git add -u . >/dev/null 2>&1 || fail "remove files"
}


function phase3() {
  if test 'yes' = "${increment_tag}"; then
    "${git_automation}/bin/git_tag_increment" "${level}" || fail "tag"
  fi
  # No quotes.
  eval git commit ${commit_args} || fail "commit"
}


function phase4() {
  git checkout master >/dev/null 2>&1 || fail "checkout master (phase 4)"
  git push >/dev/null 2>&1 || fail "push"
  git push --tags >/dev/null 2>&1 || fail "push tags"
  git submodule update >/dev/null 2>&1 || fail "update"
  if ! test 'set' = "${background:+set}"; then
    version="$(git tag | sort -V | tail -n 1)"
    if grep . <<< "${version}"; then
      echo "${project}:  ${version}"
    else
      echo "${project}:  no version"
    fi
  fi
}
