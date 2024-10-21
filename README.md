# Usage

`g [commit_message]`

*Use git as thoughtlessly as possible.*

This command will pull any changes from upstream, then add, commit, and push
any changes from this repo (the current working directory) and any subprojects,
recursively, depth first.  If a commit message is specified, it will be applied
to all commits; otherwise, git will start an editor for a message for each
commit.

# BUGS

It is currently assumed that only the `master` branch is in use for each
project.  If a project or subproject has a different branch checked out when
`g` is run, the expected results are undocumented.  Decide on correct behavior
and codify that.

New subprojects must be added by hand with `git submodule`.  Ideally `g`
should recognize and add any new subproject, but there may not be a clear basis
on which to distinguish a subproject from a directory to be added to the
current project.

Adding a submodule may result in problems during the first sync to upstream
and/or the first sync from there down to a different instance of the repo.  Get
some notes.

Collisions will stop the show.  That is probably good, but it is annoying.
