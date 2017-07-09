g [{automatic|patch|minor|major} commit_message]
  
  "Don't make me think; do git stuff."  
  
  This command will pull, then add any local changes, then commit, then
  increment the version automatically, then push code and tags.


git_tag_increment [automatic|patch|minor|major]

  "Don't make me think; adjust the version string."  This command increments
  the patch, minor, or major level, automatically.  (Or specify the level to
  increment.)

  By default, the patch level is incremented.

  If tests have been added or changed, or if a recognized testing system has
  been introduced, the minor level is incremented.  (Patch is set to zero.)

  If tests have been removed, the major level is incremented.  (Minor and
  patch are set to zero.)


BUGS:

  You shouldn't really have to specify the version level to g in order to
  specify the commit message.
