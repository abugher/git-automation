#!/bin/bash

case "${1}" in
  'patch')
    level='patch'
    ;;
  'minor')
    level='minor'
    ;;
  'major')
    level='major'
    ;;
  *)
    level='automatic'
    ;;
esac

    git pull \
&&  git add . \
&&  git add -u . \
&&  git commit \
&&  git_tag_increment "${level}" \
&&  git push \
&&  git push --tags

git tag | tail -n 1
