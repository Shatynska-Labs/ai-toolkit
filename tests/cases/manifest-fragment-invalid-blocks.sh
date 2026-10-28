#!/usr/bin/env bash
# DERIVED from requirement text, not a scenario: Every run ends in one of
# three outcomes, and the exit code agrees (project-bootstrap, MODIFIED by
# list-what-a-project-receives) — a fragment the manifest lists "lacking a
# `kind`, or a `version` that is not MAJOR.MINOR.PATCH" is a BLOCKED
# precondition, read before anything else.
#
# SPECIFIED: a copy whose rules/workstreams.md carries `version: 12`, and a
# copy whose rules/backlog.md carries no `kind`, each block (exit 2,
# Outcome: BLOCKED) and write nothing in an empty target.
#
# Executes the tool. Red until tasks 1.1 and 2.1 land (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement: toolkit_copy).
# toolkit_copy DIR: rules/ and scripts/ of the toolkit under test, copied to
# DIR, so a case can alter the copy without touching the repository.
toolkit_copy() {
  mkdir -p "$1"
  cp -R "$TOOLKIT_ROOT/rules" "$1/rules" || exit 1
  cp -R "$TOOLKIT_ROOT/scripts" "$1/scripts" || exit 1
}

for f in manifest backlog.md workstreams.md; do
  assert_file "$TOOLKIT_ROOT/rules/$f" "target absent — rules/$f"
done
# rewrite_fm FILE AWK-PROGRAM: applies the program to FILE's frontmatter lines only.
rewrite_fm() {
  awk "NR == 1 && \$0 == \"---\" { fm = 1; print; next } fm && \$0 == \"---\" { fm = 0; print; next } fm { $2; next } { print }" "$1" > "$1.new" && mv "$1.new" "$1"
}
run_blocked() {  # LABEL COPY
  local work="$TESTDIR/work-$1"
  mkdir -p "$work"
  (cd "$work" && bash "$2/scripts/project-init") >"$TESTDIR/report-$1.txt" 2>&1
  assert_exit 2 "$?" "$1 blocks"
  assert_contains "$TESTDIR/report-$1.txt" "Outcome: BLOCKED"
  [ -z "$(ls -A "$work")" ] || { echo "FAIL: the blocked run ($1) wrote into the target" >&2; exit 1; }
}
counter="$TESTDIR/counter"
toolkit_copy "$counter"
# shellcheck disable=SC2016 # backticks and $ are literal markdown or awk, not expansions
rewrite_fm "$counter/rules/workstreams.md" 'if ($0 ~ /^version:/) print "version: 12"; else print'
grep -q -x 'version: 12' "$counter/rules/workstreams.md" || { echo "FAIL: fixture — the version was not rewritten" >&2; exit 1; }
run_blocked counter-version "$counter"

nokind="$TESTDIR/nokind"
toolkit_copy "$nokind"
# shellcheck disable=SC2016 # backticks and $ are literal markdown or awk, not expansions
rewrite_fm "$nokind/rules/backlog.md" 'if ($0 !~ /^kind:/) print'
if grep -q '^kind:' "$nokind/rules/backlog.md"; then echo "FAIL: fixture — the kind was not removed" >&2; exit 1; fi
run_blocked no-kind "$nokind"
