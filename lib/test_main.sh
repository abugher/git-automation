#!/bin/bash


function test_main() {
  rm -rf "${output_dir}"
  mkdir "${output_dir}"

  for t in tests/*; do
    if test 'tests/*' == "${t}"; then
      continue
    fi
    echo "Executing test:  ${t}"
    let test_count++
    cwd=$(pwd)
    refresh_test_dir > /dev/null 2>&1
    if source "${t}"; then
      echo "Success:  ${test_count}:  ${t}"
      success_count=$(( success_count + 1 ))
    else
      echo "Failure:  ${test_count}:  ${t} (${?})"
      failure_count=$(( failure_count + 1 ))
    fi
    cd $cwd
  done

  echo "Success:  ${success_count}/${test_count}"
  echo "Failures: ${failure_count}/${test_count}"

  return "${failure_count}"
}
