#!/usr/bin/env bash
# Scenarios (mechanical half only): Record keeps a condition out of waits_on;
# An overlapping entry exists; Record parks an entry only on the operator's
# word (its `parked_until`).
# Requirement: Record writes an entry the file can be relied on for.
# Change: one-file-per-backlog-entry (backlog-maintenance, MODIFIED).
#
# SPECIFIED: record writes into `waits_on` only names of entries or changes,
# and a wait on anything else as a condition in `waits_for`; it writes into
# `design_with` only confirmed candidates; it writes `parked` with its
# `parked_until` only once the operator confirms; it sets `re_checked`; it
# writes the frontmatter in the README's form.
# DERIVED (operationalisation): in the record section, `waits_on` with
# "names" (or "only"), `waits_for` with "condition", `design_with` with
# "confirm", `parked_until`, `re_checked`, and "frontmatter".
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# until task 3.2 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog/references"

scan require "$S" record waits-on-names 'waits_on[^.]*(names|only)'
scan require "$S" record waits-for-condition 'waits_for[^.]*condition|condition[^.]*waits_for'
scan require "$S" record design-with-confirmed 'design_with[^.]*confirm|confirm[^.]*design_with'
scan require "$S" record parked-until 'parked_until'
scan require "$S" record rechecked 're_checked'
scan require "$S" record frontmatter 'frontmatter'

cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Record

Write the values as frontmatter in the README's form.
Write into `waits_on` only names of entries or changes.
Write any other wait as a condition in `waits_for`.
Write into `design_with` only the candidates the operator confirms.
Write `parked` with its `parked_until` only once the operator confirms.
Set `re_checked` to today.

## Pick

Lists takeable entries.
FIXTURE

scan_run "$fixture"
