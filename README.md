g [{automatic|patch|minor|major} commit_message]
  
  "Don't make me think; do git stuff."  
  
  This command will add or remove, commit, and push any changed files,
  including subprojects, and pull any upstream changes, in this repo and any
  subprojects, recursively, depth first.

  You made some changes?  They should get pushed upstream.  You want the latest
  from upstream?  You should get it.


git_tag_increment [automatic|patch|minor|major]

  "Don't make me think; adjust the version string."  This command increments
  the patch, minor, or major level, automatically.  (Or specify the level to
  increment.)  Intended to be used by 'g', but it's kind of its own thing.

  By default, the patch level is incremented.  If tests have been added or
  changed, the minor level is incremented.  If tests have been removed, the
  major level is incremented.

  Is it as useful as a version string updated by human decision?  Depends on
  the human, I guess.


BUGS:

  You shouldn't really have to specify the revision level to 'g' in order to
  specify the commit message.

  Syncing multiple downstream repos (possibly belonging to multiple people) to
  and from the same master has not been tried much.  Conflicts must be resolved
  normally, and this tool does nothing to avoid them.
