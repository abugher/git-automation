#!/bin/bash

PATH="${project}/bin:${PATH}"

test_count=0
failure_count=0
success_count=0

test_dir="/tmp/git-automation_tests"
output_dir="/tmp/git-automation_tests_output"

repo_top_master="${test_dir}/top_master"
repo_bottom_master="${test_dir}/bottom_master"
repo_single_master="${test_dir}/single_master"
repo_top_stacked="${test_dir}/top"
repo_bottom_isolated="${test_dir}/bottom"
repo_single_isolated="${test_dir}/single"
repo_bottom_stacked="${repo_top_stacked}/bottom"
