#!/bin/bash


function initialize_repo() {
  master="${1}"
  main="${2}"

  mkdir "${master}"                                                     || fail '' 51
  cd "${master}"                                                        || fail '' 52
  git init --bare                                                       || fail '' 53

  git clone "${master}" "${main}"                                       || fail '' 54
  cd "${main}"                                                          || fail '' 55
  mkdir bin                                                             || fail '' 56
  if test 'set' = "${test_ret:+set}"; then
    echo '#!/bin/bash' > bin/test                                       || fail '' 57
    echo "${test_ret}" >> bin/test                                      || fail '' 58
    chmod 0755 bin/test                                                 || fail '' 59
  else
    touch thing0                                                        || fail '' 61
  fi
  git add .                                                             || fail '' 62
  git commit -m 'No comment.'                                           || fail '' 63
  git push                                                              || fail '' 64
}


function refresh_test_dir() {
  if test 'set' = "${1:+set}"; then
    test_ret="${1}"
  else
    unset test_ret
  fi
  oldpwd=$PWD
  rm -rf "${test_dir}"                                                  || fail '' 65
  mkdir "${test_dir}"                                                   || fail '' 66
  cd "${test_dir}"                                                      || fail '' 67

  initialize_repo "${repo_single_master}" "${repo_single_isolated}" >/dev/null 2>&1
  initialize_repo "${repo_top_master}" "${repo_top_stacked}" >/dev/null 2>&1
  initialize_repo "${repo_bottom_master}" "${repo_bottom_isolated}" >/dev/null 2>&1

  cd "${repo_top_stacked}"                                              || fail '' 68
  git submodule add "${repo_bottom_master}" bottom >/dev/null 2>&1      || fail '' 69
  git add "${repo_bottom_stacked}" >/dev/null 2>&1                      || fail '' 70
  git submodule update --init >/dev/null 2>&1                           || fail '' 71
  cd $oldpwd                                                            || fail '' 72
}

