#!/bin/bash

libs+=(
  'test_output'
)
for lib in "${libs[@]}"; do
  lib_path="${project}/lib/${lib}.sh"
  if ! . "${lib_path}"; then
    echo "Failed to load library:  ${lib_path}" >&2
    exit 1
  fi
done
