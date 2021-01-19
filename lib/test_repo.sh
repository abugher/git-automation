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

  initialize_repo "${repo_single_master}" "${repo_single_isolated}"
  initialize_repo "${repo_top_master}" "${repo_top_stacked}"
  initialize_repo "${repo_bottom_master}" "${repo_bottom_isolated}"

  cd "${repo_top_stacked}"
  git submodule add "${repo_bottom_master}" bottom
  git add "${repo_bottom_stacked}"
  git submodule update --init
  cd $oldpwd
}

