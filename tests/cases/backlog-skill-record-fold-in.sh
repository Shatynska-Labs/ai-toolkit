#!/usr/bin/env bash
# Scenario (mechanical half only): Work the change can fold in.
# Requirement: Record writes an entry the file can be relied on for.
# Change: fold-small-work-in (backlog-maintenance, MODIFIED).
#
# SPECIFIED: in a change, record first tests the work against the fold-in
# rule the project's workflow states, taking the test from the workflow
# rather than stating it; where the work meets it, record says so and writes
# no entry.
# DERIVED (operationalisation, Q1): read from the section under the heading
# naming `record` (as backlog-skill-record.sh does) — "fold", "workflow", and
# "no entry" in it; not stating the test is operationalised as the
# fragment's two most distinctive condition phrases, "screen of diff" and
# "direct tests", appearing nowhere in it; "first" as the first mention of
# folding preceding the first mention of the name check's `heading`.
#
# Not asserted: that no override is offered beyond the workflow's (a stated
# absence with no token to scan), and that record writes no entry when run.
# Conduct; verified by reading.
#
# Static read: red until the step lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" record fold-test 'fold'
scan require "$S" record from-workflow 'workflow'
scan require "$S" record no-entry 'no entry'
scan forbid "$S" record states-size 'screen of diff' 'Work is small if it is about a screen of diff.'
scan forbid "$S" record states-files 'direct tests' 'It touches only the change'"'"'s files or their direct tests.'

# Fold-in test precedes the name check within the record section.
# 0 ordered, 1 not, 2 unreadable.
order_check() {
  local text fold head
  text="$(scan_heading_section "$1/$S" record 2>/dev/null | tr '[:upper:]' '[:lower:]')"
  fold="$(printf '%s\n' "$text" | grep -n -E 'fold' | head -n1 | cut -d: -f1)"
  head="$(printf '%s\n' "$text" | grep -n -E 'entry files' | head -n1 | cut -d: -f1)"
  if [ -z "$fold" ] || [ -z "$head" ]; then return 2; fi
  [ "$fold" -lt "$head" ] || { echo "FAIL: [fold-test-first] record checks the name before it applies the fold-in test" >&2; return 1; }
}

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Record

First, where the session is in a change, test the work against the fold-in rule the project's workflow states. Where it meets it, say the work can be folded in and write no entry.
Check the name against the backlog's entry files.

## Pick

Lists takeable entries.
FIXTURE

order_check "$fixture" || { echo "FAIL: discriminator — the order check rejected the conforming fixture" >&2; exit 1; }
late="$TESTDIR/late"
mkdir -p "$late/skills/backlog"
cat > "$late/$S" <<'FIXTURE'
# backlog

## Record

Check the name against the backlog's entry files.
Then test the work against the fold-in rule the project's workflow states, and write no entry where it meets it.
FIXTURE
order_check "$late" 2>/dev/null; st=$?
[ "$st" -eq 1 ] || { echo "FAIL: discriminator — the order check passed a record that checks the name first (status $st)" >&2; exit 1; }

scan_discriminate "$fixture" || exit 1
scan_check "$TOOLKIT_ROOT"; status=$?
order_check "$TOOLKIT_ROOT"; ostatus=$?
if [ "$status" -eq 2 ]; then
  echo "FAIL: target absent — what this case reads does not exist yet" >&2
  exit 1
fi
if [ "$ostatus" -eq 2 ]; then
  echo "FAIL: [fold-test-first] record names no fold-in test and name check to order" >&2
fi
[ "$status" -eq 0 ] && [ "$ostatus" -eq 0 ] || exit 1
exit 0
