#!/usr/bin/env bash
# Scenario: A fix is distinguished from a change by what it owes.
# Change: add-backlog-skill (project-bootstrap, MODIFIED).
#
# SPECIFIED: the file defines Kind as `fix` or `change` with the reason, and
# states `fix` as owing no specification delta, needing no decision, and
# fitting one review sitting — so an entry owing a delta can only be a change.
# DERIVED (placement and wording): the definition is the Kind line of the
# fenced entry shape (design.md decision 2), and each condition is asserted by
# a phrase from that text: `no specification delta`, `no decision`,
# `one review sitting`.
#
# Executes the tool; no fixture owed.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"

backlog="$work/docs/backlog.md"
assert_file "$backlog" "the seeded file this case reads"

kind="$(awk '/^[[:space:]]*(```|~~~)/ { infence = !infence; next } infence && /^\*\*Kind\*\*/ { print }' "$backlog")"
if [ -z "$kind" ]; then
  echo "FAIL: the seeded entry shape carries no **Kind** line" >&2
  exit 1
fi

# shellcheck disable=SC2016 # backticks are literal markdown in the phrases
for phrase in '`fix`' '`change`' 'no specification delta' 'no decision' 'one review sitting'; do
  if ! printf '%s\n' "$kind" | grep -q -F -- "$phrase"; then
    echo "FAIL: the Kind definition does not state: $phrase" >&2
    printf '%s\n' "$kind" >&2
    exit 1
  fi
done
