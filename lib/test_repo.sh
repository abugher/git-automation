#!/bin/bash


function initialize_repo() {
  master=$1
  main=$2

  mkdir "${master}"                                             || fail 51
  cd "${master}"                                                || fail 52
  git init --bare                                               || fail 53

  git clone "${master}" "${main}"                               || fail 54
  cd "${main}"                                                  || fail 55
  touch thing0                                                  || fail 56
  git add thing0                                                || fail 57
  git commit -m 'No comment.'                                   || fail 58
  git push                                                      || fail 59
}


function refresh_test_dir() {
  oldpwd=$PWD
  rm -rf "${test_dir}"
  mkdir "${test_dir}"
  cd "${test_dir}"

  initialize_repo "${master_single_repo}" "${main_single_repo}"
  initialize_repo "${master_super_repo}" "${main_super_repo}"
  initialize_repo "${master_sub_repo}" "${main_sub_repo}"

  cd "${main_super_repo}"
  git submodule add "${master_sub_repo}" "${sub_repo_name}"
  git add "${sub_sub_repo}"
  git submodule update --init
  cd $oldpwd
}

