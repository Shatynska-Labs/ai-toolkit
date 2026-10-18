#!/usr/bin/env bash
# Scenario (mechanical half only): A recursive tool does not descend into
# sibling working trees.
#
# The specification fixes these paths rather than leaving them to the
# fragment's author, and gives one reason for all of them: a path stated only
# in a change's own artifacts is archived with them, and every obligation
# that references it becomes uncheckable against the fragment afterwards.
# Asserting the paths verbatim is what that reason buys.
#
# The backlog's entry rules are not the fragment's: the file project-init
# seeds states them, and the workflow-fragment-backlog-* cases assert the
# fragment neither restates them nor mentions entry numbers.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"

assert_contains "$fragment" ".worktrees/" \
  "the working-tree location is a fixed path, so a requirement stated against it has a checkable subject"
assert_contains "$fragment" "docs/backlog.md" \
  "identified work is routed to the backlog at the path the specification fixes"
