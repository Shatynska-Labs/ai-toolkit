#!/usr/bin/env bash
# Scenario (mechanical half only): Pick meets an entry with no Kind (as
# revised: no `kind` key).
# Requirement: Entries in an older shape are reported, not rewritten.
# Change: one-file-per-backlog-entry (backlog-maintenance, MODIFIED).
#
# SPECIFIED: where an entry lacks a key the README's shape names, the skill
# reports it as unclassified wherever that key decides the outcome, and
# does not invent the value.
# DERIVED (operationalisation): a paragraph naming `unclassified` names a
# key (`key`, or `kind`). The unclassified listing itself is
# backlog-skill-older-shape-unclassified.sh's, unchanged.
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# until task 3.2 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select 'unclassified'
# shellcheck disable=SC2016 # backticks and $ are literal text in a pattern or fixture
line_scan require names-a-key '(^|[^a-z])key([^a-z]|$)|`kind`'

fixture="$TESTDIR/SKILL.md"
cat > "$fixture" <<'FIXTURE'
# backlog

Where an entry lacks a key the README's shape names, report it as unclassified wherever that key decides the outcome.
FIXTURE

line_run "$fixture" skills/backlog/SKILL.md
