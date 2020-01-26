g [commit_message [automatic|patch|minor|major]]
  
  **Don't make me think; do git stuff.**
  
  This command will pull any changes from upstream, then add, commit, and push
  any changes from your repo, including subprojects, in this repo and any
  subprojects, recursively, depth first.

  It also runs git_tag_increment.


git_tag_increment [automatic|patch|minor|major]

  **Don't make me think; adjust the version string.**
  
  This command increments a version string kept in git tags.

  By default, the patch number is incremented.  If tests have been added or
  changed, the minor number is incremented.  If tests have been removed, the
  major number is incremented.  If a valid argument is specified, it is used
  as the change level, overriding any automatic determination.
