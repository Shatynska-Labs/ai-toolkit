#!/usr/bin/env bash
# Scenario: The seeded file offers no low priority.
# Change: add-a-backlog-priority (project-bootstrap, MODIFIED).
#
# SPECIFIED: the file offers no `low` value.
# DERIVED (operationalisation): the values the file offers are those on the
# fenced **Priority** line (design.md decision 5); that line must exist (a
# vacuity guard, so the scan cannot pass on a file carrying no Priority at
# all) and must not contain the word `low`. Only that line is scanned: a
# sentence elsewhere saying there is no `low` offers none and must not fail.
#
# Not asserted: "so the entry is either parked with a condition or not
# recorded" — the deletion ground it rests on (`will not be made`) is asserted
# by backlog-seeded-new-project.sh; what a session then does is conduct.
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

priority="$(awk '/^[[:space:]]*(```|~~~)/ { infence = !infence; next } infence && /^\*\*Priority\*\*/ { print }' "$backlog")"
if [ -z "$priority" ]; then
  echo "FAIL: the seeded entry shape carries no **Priority** line; there is nothing to check for a low value" >&2
  exit 1
fi

low_re='(^|[^a-z])low([^a-z]|$)'
# Discriminator for the regex: it must catch a low value and must not catch
# words merely containing the letters (below, follow, allow, lower).
# shellcheck disable=SC2016 # backticks are literal markdown in the specimen
printf '%s\n' '**Priority**: `high`, `normal` or `Low`.' | grep -i -E -q "$low_re" \
  || { echo "FAIL: discriminator — the low-value scan misses a line offering Low" >&2; exit 1; }
if printf '%s\n' 'Follow below; allow a lower bar.' | grep -i -E -q "$low_re"; then
  echo "FAIL: discriminator — the low-value scan fires on words merely containing low" >&2
  exit 1
fi

if printf '%s\n' "$priority" | grep -i -E -q "$low_re"; then
  echo "FAIL: the Priority definition offers a low value" >&2
  printf '%s\n' "$priority" >&2
  exit 1
fi
