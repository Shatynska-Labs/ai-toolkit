#!/usr/bin/env bash
# Scenario: Done when asks for an observable effect of the Goal (as revised) —
# "its workstream shape gives Done when as an observable effect of the Goal".
# Also the revised shape statement of "A project without a workstream register
# receives the seeded file": Done when ... with every step being done beside
# it where that is wanted.
# Requirement: A workstream register is seeded where none exists.
# Change: define-what-a-step-is (project-bootstrap, MODIFIED).
#
# SPECIFIED: the shape's Done when offers every step being done beside the
# effect, and no longer every step being archived.
# DERIVED (placement): the shape's Done when is the fenced line beginning
# `**Done when**` (tests/lib.sh fenced_line), as
# workstreams-seeded-done-when-shape.sh reads it.
# DERIVED (wording, design.md decision 4): "every step is done" and "beside
# it" present, "every step is archived" absent.
# The line's other clauses are unchanged by this change and stay asserted by
# workstreams-seeded-done-when-shape.sh.
#
# Executes the tool and reads its output (second situation, as this suite
# classifies its seeded-text cases); uses only tests/lib.sh's fenced_line, so
# no local helper and no fixture is owed. Red at authoring on the property
# "the shape's Done when reads done, not archived" (state 1: the tool runs and
# writes the 1.0.0 line); goes green as task 1.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"

r="$work/docs/workstreams/AGENTS.md"
assert_file "$r" "the seeded file this case reads"

n="$(fenced_line "$r" "Done when")"
if [ -z "$n" ]; then
  echo "FAIL: the seeded workstream shape carries no fenced **Done when** line" >&2
  exit 1
fi
d="$TESTDIR/done-when.txt"
sed -n "${n}p" "$r" > "$d"

assert_contains "$d" "every step is done" "every step being done offered in the shape"
assert_contains "$d" "beside it" "every step being done stands beside the effect"
if grep -q -F -- "every step is archived" "$d"; then
  echo "FAIL: the shape's Done when still offers every step being archived" >&2
  cat "$d" >&2
  exit 1
fi
