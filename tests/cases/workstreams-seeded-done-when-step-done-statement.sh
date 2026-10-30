#!/usr/bin/env bash
# Scenario: Done when asks for an observable effect of the Goal (as revised) —
# "its prose states that every step being done may stand beside that effect
# but never in its place". Also the revised statement of "A project without a
# workstream register receives the seeded file".
# Requirement: A workstream register is seeded where none exists.
# Change: define-what-a-step-is (project-bootstrap, MODIFIED).
#
# SPECIFIED: the prose paragraph saying what may stand beside the Done when's
# effect names every step being done, and no longer every step being archived
# ("every step being done replaces every step being archived").
# DERIVED (placement): the paragraph is the one line outside fenced code
# containing "never in its place", as workstreams-seeded-done-when-statement.sh
# finds it.
# DERIVED (wording, design.md decision 4): "every step is done" present and
# "every step is archived" absent on that line, both case-insensitive (the
# design opens a sentence with the phrase).
# The rest of that paragraph's clauses are unchanged by this change and stay
# asserted by workstreams-seeded-done-when-statement.sh.
#
# Executes the tool and reads its output (second situation, as this suite
# classifies its seeded-text cases). Red at authoring on the property "the
# paragraph reads done, not archived" (state 1: the tool runs and writes the
# 1.0.0 text); goes green as task 1.1 lands. The local line locator is
# checked first against specimens it must accept and reject.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement): line number of
# the first line outside fenced code containing PHRASE, or nothing.
# tests/lib.sh's fenced_line is the near-miss: it reads only inside fences and
# matches a label at the start of a line.
prose_line() {
  awk -v want="$2" '
    /^[[:space:]]*(```|~~~)/ { infence = !infence; next }
    !infence && index($0, want) > 0 { print NR; exit }
  ' "$1"
}

# Discriminator for the local locator.
spec="$TESTDIR/specimen"
mkdir -p "$spec"
printf '%s\n' 'intro' '```' 'never in its place (fenced)' '```' '' 'Prose: never in its place.' > "$spec/ok.md"
[ "$(prose_line "$spec/ok.md" "never in its place")" = 6 ] \
  || { echo "FAIL: discriminator — prose_line does not skip the fenced match or misses the prose line" >&2; exit 1; }
printf '%s\n' '```' 'never in its place' '```' > "$spec/fenced-only.md"
[ -z "$(prose_line "$spec/fenced-only.md" "never in its place")" ] \
  || { echo "FAIL: discriminator — prose_line accepts a match inside fenced code" >&2; exit 1; }

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"

r="$work/docs/workstreams/AGENTS.md"
assert_file "$r" "the seeded file this case reads"

n="$(prose_line "$r" "never in its place")"
if [ -z "$n" ]; then
  echo "FAIL: no prose paragraph of the seeded register states what may stand beside the Done when's effect but never in its place" >&2
  exit 1
fi
p="$TESTDIR/paragraph.txt"
sed -n "${n}p" "$r" > "$p"

if ! grep -q -i -F -- "every step is done" "$p"; then
  echo "FAIL: the paragraph does not name every step being done" >&2
  cat "$p" >&2
  exit 1
fi
if grep -q -i -F -- "every step is archived" "$p"; then
  echo "FAIL: the paragraph still names every step being archived" >&2
  cat "$p" >&2
  exit 1
fi
