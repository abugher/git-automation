#!/bin/bash

l="${1}"

case "${l}" in
  'patch')
    level='patch'
    ;;
  'minor')
    level='minor'
    ;;
  'major')
    level='major'
    ;;
  'automatic')
    level='automatic'
    ;;
  '')
    level='automatic'
    ;;
  *)
    echo "What's ${l}?"
    exit 1
    ;;
esac

commit_args=''
message="${2}"
if echo "${message}" | grep -q '.'; then
  commit_args="-m '${message}'"
fi

    git pull \
&&  git add . \
&&  git add -u . \
&&  eval git commit ${commit_args} \
&&  git_tag_increment "${level}" \
&&  git push \
&&  git push --tags

git tag | sort -V | tail -n 1
