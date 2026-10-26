#!/usr/bin/env bash
# Scenario: Done when asks for an observable effect of the Goal — "its prose
# states that every step being archived may stand beside that effect but
# never in its place". Also the added statement of "A project without a
# workstream register receives the seeded file": what finishes a workstream,
# its Done when, is an observable effect of its Goal — what to look at in the
# repository, the forge or production, what provokes it where something must,
# and the result that means the Goal holds — and every step being archived
# may stand beside that effect but never in its place, since it shows only
# that the step list was worked through, which a list missing a step
# satisfies as well.
# Requirement: A workstream register is seeded where none exists.
# Change: observe-what-finishes-a-workstream (project-bootstrap, MODIFIED).
#
# SPECIFIED: the statement above, as prose (outside the fenced shape).
# DERIVED (placement): the statement is one paragraph, written as one line
# (AGENTS.md: prose is not hard-wrapped), outside fenced code, found by
# "never in its place"; every phrase below is asserted on that line.
# DERIVED (wording): one stable phrase per clause, common to the requirement
# and design.md decision 2: "effect of its Goal"; "what to look at"; "the
# forge or production"; "provokes it"; "means the Goal holds"; "every step is
# archived" (case-insensitive: the design opens a sentence with it); "worked
# through"; "a list missing a step"; "never in its place".
# DERIVED (order, design.md decision 2, not the requirement): the paragraph
# stands immediately before the archive paragraph, the next non-blank line
# being the one naming `archive/<YYYY-MM-DD>-<name>.md`.
#
# Executes the tool and reads its output (second situation). The local line
# locators are checked first against specimens they must accept and reject.
# Red at authoring on the property "the prose states what finishes a
# workstream" (state 1: the tool runs and writes no such paragraph); goes
# green as task 1.1 lands.
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

# Local arrangement: line number of the first non-blank line after line N,
# or nothing.
next_nonblank() {
  awk -v n="$2" 'NR > n && $0 !~ /^[[:space:]]*$/ { print NR; exit }' "$1"
}

# Discriminator for the local locators.
spec="$TESTDIR/specimen"
mkdir -p "$spec"
# shellcheck disable=SC2016 # backticks are literal markdown in the specimen
printf '%s\n' 'intro' '```' 'never in its place (fenced)' '```' '' \
  'Prose: never in its place.' '' '' 'Archive: `archive/<YYYY-MM-DD>-<name>.md`.' > "$spec/ok.md"
[ "$(prose_line "$spec/ok.md" "never in its place")" = 6 ] \
  || { echo "FAIL: discriminator — prose_line does not skip the fenced match or misses the prose line" >&2; exit 1; }
[ "$(next_nonblank "$spec/ok.md" 6)" = 9 ] \
  || { echo "FAIL: discriminator — next_nonblank does not skip blank lines" >&2; exit 1; }
printf '%s\n' '```' 'never in its place' '```' > "$spec/fenced-only.md"
[ -z "$(prose_line "$spec/fenced-only.md" "never in its place")" ] \
  || { echo "FAIL: discriminator — prose_line accepts a match inside fenced code" >&2; exit 1; }

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"

r="$work/docs/workstreams/README.md"
assert_file "$r" "the seeded file this case reads"

n="$(prose_line "$r" "never in its place")"
if [ -z "$n" ]; then
  echo "FAIL: no prose paragraph of the seeded register states that every step being archived may stand beside the effect but never in its place" >&2
  exit 1
fi
p="$TESTDIR/paragraph.txt"
sed -n "${n}p" "$r" > "$p"

assert_contains "$p" "effect of its Goal" "what finishes a workstream is an effect of its Goal"
assert_contains "$p" "what to look at" "what to look at"
assert_contains "$p" "the forge or production" "in the repository, the forge or production"
assert_contains "$p" "provokes it" "what provokes it where something must"
assert_contains "$p" "means the Goal holds" "the result that means the Goal holds"
if ! grep -q -i -F -- "every step is archived" "$p"; then
  echo "FAIL: the paragraph does not name every step being archived" >&2
  exit 1
fi
assert_contains "$p" "worked through" "it shows only that the step list was worked through"
assert_contains "$p" "a list missing a step" "which a list missing a step satisfies as well"

m="$(next_nonblank "$r" "$n")"
if [ -z "$m" ] || ! sed -n "${m}p" "$r" | grep -q -F -- 'archive/<YYYY-MM-DD>-<name>.md'; then
  echo "FAIL: the paragraph (line $n) does not stand immediately before the archive paragraph (design.md decision 2)" >&2
  exit 1
fi
