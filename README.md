**g [commit_message [automatic|patch|minor|major]]**

*Don't make me think; do git stuff.*

This command will pull any changes from upstream, then add, commit, and push
any changes from this repo and any subprojects, recursively, depth first.

If *bin/test* exists, *g* will also run it, and if it passes, will call
*git\_tag\_increment*.


**git_tag_increment [automatic|patch|minor|major]**

*Don't make me think; adjust the version string.*

This command increments a version string kept in git tags.

By default, the patch number is incremented.  If tests have been added or
changed, the minor number is incremented.  If tests have been removed, the
major number is incremented.  If a valid argument is specified, it is used
as the change level, overriding any automatic determination.

It is assumed that a collection of tests can be found, one test per file, under
a directory named *test*, and that each one is called by *bin/test*.

The goal is semantic versioning, but the automation relies on some shaky
assumptions.  It is assumed that a new test indicates a new feature and a
removed test indicates a removed feature.  It is also assumed that a removed
feature always and exclusively constitutes a break in backward compatibility.
