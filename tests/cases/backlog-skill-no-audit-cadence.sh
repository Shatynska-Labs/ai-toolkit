#!/usr/bin/env bash
# Scenario: The skill does not mandate an audit cadence.
# Requirement: The skill restates neither the entry rules nor the workflow's
# obligations. Change: add-backlog-skill (backlog-maintenance, ADDED).
#
# SPECIFIED: a session reading the skill finds no rule obliging an audit at
# any interval.
# DERIVED (operationalisation): an interval is recognised as `every <n|word>
# ... day/week/month/sprint`, `weekly`, `monthly`, `fortnight(ly)` or
# `(bi)weekly`, in SKILL.md or references/audit.md. The handoff's "every two
# to three weeks" is the specimen. An interval worded otherwise is not
# reached.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

re='every[[:space:]]+([0-9]+|one|two|three|four|few|other|couple)[^.]*(day|week|month|sprint)|weekly|monthly|fortnight'
scan forbid skills/backlog/SKILL.md "" skill-cadence "$re" "Run an audit every two to three weeks."
scan forbid skills/backlog/references/audit.md "" brief-cadence "$re" "Audits run monthly."

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog/references"
cat > "$fixture/skills/backlog/SKILL.md" <<'FIXTURE'
# backlog

## Audit

Run when the operator asks for it.
FIXTURE
cat > "$fixture/skills/backlog/references/audit.md" <<'FIXTURE'
# Audit brief

Verify every entry in the range you are given.
FIXTURE

scan_run "$fixture"
