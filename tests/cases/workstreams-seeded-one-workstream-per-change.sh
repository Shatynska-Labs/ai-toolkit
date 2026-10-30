#!/usr/bin/env bash
# Scenario: A change needed by two workstreams is listed in one. Also the
# added statement of "A project without a workstream register receives the
# seeded file": a change is a step of one workstream only; another workstream
# whose goal also needs it does not list it among its steps, and a step of that
# workstream that cannot start before the change names it in its backlog
# entry's `waits_on`, an entry being recorded for that step where it has none.
# Requirement: A workstream register is seeded where none exists.
# Change: define-what-a-step-is (project-bootstrap, MODIFIED).
#
# SPECIFIED: the statement above, as prose (outside the fenced shape).
# DERIVED (placement): the statement is one paragraph, written as one line
# (AGENTS.md: prose is not hard-wrapped), outside fenced code, found by "A
# change is a step of one workstream only"; every phrase below is asserted on
# that line.
# DERIVED (wording, design.md decision 3): "A change is a step of one
# workstream only"; "another workstream"; "does not list it among its steps";
# "`waits_on`"; "has no entry yet"; "recorded".
# DERIVED (order, design.md decision 3, not the requirement): the paragraph
# immediately follows the one stating that order gates nothing, the previous
# non-blank line containing "gates nothing".
#
# Executes the tool and reads its output (second situation, as this suite
# classifies its seeded-text cases). Red at authoring on the property "the
# file states a change is a step of one workstream only" (state 1: the tool
# runs and writes no such paragraph); goes green as task 1.1 lands. The local
# line locators are checked first against specimens they must accept and
# reject.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement: line number of the last non-blank line before line N,
# or nothing.
prev_nonblank() {
  awk -v n="$2" 'NR >= n { exit } $0 !~ /^[[:space:]]*$/ { last = NR } END { if (last) print last }' "$1"
}

# Discriminator for the local locators.
spec="$TESTDIR/specimen"
mkdir -p "$spec"
printf '%s\n' 'intro' '```' 'one workstream only (fenced)' '```' 'Order gates nothing.' '' '' \
  'Prose: one workstream only.' > "$spec/ok.md"
[ "$(prose_line "$spec/ok.md" "one workstream only")" = 8 ] \
  || { echo "FAIL: discriminator — prose_line does not skip the fenced match or misses the prose line" >&2; exit 1; }
[ "$(prev_nonblank "$spec/ok.md" 8)" = 5 ] \
  || { echo "FAIL: discriminator — prev_nonblank does not skip blank lines" >&2; exit 1; }
[ -z "$(prev_nonblank "$spec/ok.md" 1)" ] \
  || { echo "FAIL: discriminator — prev_nonblank reports a line before the first" >&2; exit 1; }
printf '%s\n' '```' 'one workstream only' '```' > "$spec/fenced-only.md"
[ -z "$(prose_line "$spec/fenced-only.md" "one workstream only")" ] \
  || { echo "FAIL: discriminator — prose_line accepts a match inside fenced code" >&2; exit 1; }

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"

r="$work/docs/workstreams/AGENTS.md"
assert_file "$r" "the seeded file this case reads"

n="$(prose_line "$r" "A change is a step of one workstream only")"
if [ -z "$n" ]; then
  echo "FAIL: no prose paragraph of the seeded register states that a change is a step of one workstream only" >&2
  exit 1
fi
p="$TESTDIR/paragraph.txt"
sed -n "${n}p" "$r" > "$p"

assert_contains "$p" "another workstream" "another workstream whose goal also needs the change"
assert_contains "$p" "does not list it among its steps" "the other workstream does not list the change among its steps"
# shellcheck disable=SC2016 # backticks are literal markdown, not expansions
assert_contains "$p" '`waits_on`' "the dependent step names the change in its entry's waits_on"
assert_contains "$p" "has no entry yet" "where the dependent step has no entry"
assert_contains "$p" "recorded" "an entry is recorded for it"

m="$(prev_nonblank "$r" "$n")"
if [ -z "$m" ] || ! sed -n "${m}p" "$r" | grep -q -F -- 'gates nothing'; then
  echo "FAIL: the paragraph (line $n) does not immediately follow the paragraph stating that order gates nothing (design.md decision 3)" >&2
  exit 1
fi
