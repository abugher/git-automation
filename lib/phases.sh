#!/bin/bash


function phase1() {
  if git diff --quiet --exit-code >/dev/null 2>&1; then
    # Locking errors occur on:  .git/index.lock
    # Cause unknown.  'git checkout' returns:  128
    # 2021-03-26:  Hypothesis:  There is a collision because subprojects' git
    # configuration refers to higher level projects' configuration, so while
    # processing subprojects in parallel, they will need to lock the same
    # file(s).
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
  if test -e bin/test && bin/test; then
    "${git_automation}/bin/git_tag_increment" "${level}" || fail "tag"
  fi
  # No quotes.
  eval git commit ${commit_args} || fail "commit"
  git push >/dev/null 2>&1 || fail "push"
  git push --tags >/dev/null 2>&1 || fail "push tags"
}


function phase3_alt() {
  # No changes to commit.  Try to push any commits sitting around, but don't
  # fail.  git push will always fail for those without write access.  This
  # could probably be more elegant.
  git push >/dev/null 2>&1 || warn "push"
  git push --tags >/dev/null 2>&1 || warn "push tags"
}


function phase4() {
  git submodule update >/dev/null 2>&1 || fail "update"
  if ! test 'set' = "${background:+set}"; then
    version="$(git tag | sort -V | tail -n 1)"
    if grep -q . <<< "${version}"; then
      echo "${project}:  ${version}"
    else
      echo "${project}:  no version"
    fi
  fi
}
