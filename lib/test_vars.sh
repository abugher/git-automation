#!/bin/bash

PATH="$HOME/code/github/abugher/git-automation:${PATH}"

test_dir="/tmp/git-automation_tests"
output_dir="/tmp/git-automation_tests_output"
master_super_repo="${test_dir}/master_super"
master_sub_repo="${test_dir}/master_sub"
master_single_repo="${test_dir}/master_single"
main_super_repo="${test_dir}/super"
main_sub_repo="${test_dir}/sub"
main_single_repo="${test_dir}/single"
sub_repo_name='sub'
sub_sub_repo="${main_super_repo}/${sub_repo_name}"
old_cwd="${PWD}"

test_count=0
failure_count=0
success_count=0
