#!/bin/bash


function output {
  printf "%10s (%s):  %s\n" "(${project})" "${background:-}" "${1}"
}


function warn {
  output "WARNING: (${?}) ${1}" >&2
}


function error {
  output "ERROR:   (${?}) ${1}" >&2
}


function fail {
  error "${1}"
  exit "${2:-1}"
}


function debug {
  output "DEBUG:   (${?}) ${1}" >&2
}
