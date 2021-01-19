#!/bin/bash

libs+=(
  'output'
)

for lib in "${libs[@]}"; do
  lib_path="${git_automation}/lib/${lib}.sh"
  if ! . "${lib_path}"; then
    echo "Failed to load library:  ${lib_path}" >&2
    exit 1
  fi
done
