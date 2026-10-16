#!/usr/bin/env bash
# Scenarios (mechanical half only): A recursive tool does not descend into
# sibling working trees; A backlog entry is cited by name; The backlog does
# not yet exist.
#
# The specification fixes these paths rather than leaving them to the
# fragment's author, and gives one reason for all of them: a path stated only
# in a change's own artifacts is archived with them, and every obligation
# that references it becomes uncheckable against the fragment afterwards.
# Asserting the paths verbatim is what that reason buys.
#
# The cite-by-name direction is asserted verbatim because it is what keeps a
# reference to an entry valid after other entries are deleted or reordered.
#
# The obligations attached to each path are prose and are verified by
# reading: the create-it-if-absent direction on `docs/backlog.md`
# (tasks 1.4, 1.14).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"

assert_contains "$fragment" ".worktrees/" \
  "the working-tree location is a fixed path, so a requirement stated against it has a checkable subject"
assert_contains "$fragment" "docs/backlog.md" \
  "identified work is routed to the backlog at the path the specification fixes"
assert_contains "$fragment" "cite an entry by name, never by number" \
  "a backlog entry is cited by its stable name, not its unstable number"
