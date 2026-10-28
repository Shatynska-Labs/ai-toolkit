#!/usr/bin/env bash
# Scenario: Done when asks for an observable effect of the Goal — "its
# workstream shape gives Done when as an observable effect of the Goal". Also
# the revised shape statement of "A project without a workstream register
# receives the seeded file": Done when is an observable effect of the Goal
# that can be checked against the repository, the forge or production, with
# every step being archived beside it where that is wanted.
# Requirement: A workstream register is seeded where none exists.
# Change: observe-what-finishes-a-workstream (project-bootstrap, MODIFIED).
#
# SPECIFIED: the shape's Done when names an observable effect of the Goal,
# checked against the repository, the forge or production, with every step
# being archived beside it.
# DERIVED (placement): the shape is the fenced example, its Done when the
# fenced line beginning `**Done when**` (tests/lib.sh fenced_line), as
# workstreams-seeded-fields-are-a-list.sh reads it.
# DERIVED (wording): one stable phrase per clause, common to the requirement
# and design.md decision 1: "effect of the Goal"; "observ" (the requirement's
# "observable", the design's "can be observed"); "the forge or production";
# "every step is archived" and "beside it" (the design's quoted clause).
#
# Executes the tool and reads its output (second situation); no fixture owed.
# Red at authoring on the property "the shape's Done when names an effect of
# the Goal" (state 1: the tool runs and writes the old line); goes green as
# task 1.1 lands.
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
line="$(sed -n "${n}p" "$r")"
printf '%s\n' "$line" > "$TESTDIR/done-when.txt"

assert_contains "$TESTDIR/done-when.txt" "effect of the Goal" "the shape's Done when names an effect of the Goal"
assert_contains "$TESTDIR/done-when.txt" "observ" "the effect is observable"
assert_contains "$TESTDIR/done-when.txt" "the forge or production" "observed in the repository, the forge or production"
assert_contains "$TESTDIR/done-when.txt" "every step is archived" "every step being archived offered in the shape"
assert_contains "$TESTDIR/done-when.txt" "beside it" "every step being archived stands beside the effect"
