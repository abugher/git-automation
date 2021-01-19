#!/bin/bash


function get_version() {
  tail -n 5 < "${1}" \
    | head -n 1 \
    | cut -d ' ' -f 3
}
