g [{automatic|patch|minor|major} commit_message]
  
  "Don't make me think; do git stuff."  
  
  This command will pull any upstream changes, add or remove, commit, and push
  any changed files, including subprojects, in this repo and any subprojects,
  recursively, depth first.

  You made some changes?  They should get pushed upstream.  You want the latest
  from upstream?  You should get it.

  It also calls git_tag_increment.


git_tag_increment [automatic|patch|minor|major]

  "Don't make me think; adjust the version string."  This command increments a
  version string, kept in git tags.

  By default, the patch number is incremented.  If tests have been added or
  changed, the minor number is incremented.  If tests have been removed, the
  major number is incremented.  If a valid argument is specified, it is used
  as the change level, overriding any automatic determination.


BUGS:

  You shouldn't really have to specify the revision level to 'g' in order to
  specify the commit message.
