#!/bin/bash


function get_version() {
  tail -n 1 < "${1}" \
    | cut -d ' ' -f 3
}
