#!/usr/bin/env bash
# No scenario of its own: guards the deferral the MODIFIED backlog-maintenance
# requirements state for Priority ("as the file directs", "the file's
# default") against the skill restating the file's Priority rule.
# Requirement: The skill restates neither the entry rules nor the workflow's
# obligations (unchanged), as applied by add-a-backlog-priority.
#
# DERIVED (design.md decisions 5 and 8; tasks.md 2.1 "each deferring to the
# file for what the values mean"): the seeded Priority definition's
# distinctive phrases — `harm happening now`, `an entry without this field is`
# — appear in neither SKILL.md nor references/audit.md. Field and value names
# (Priority, `high`, `normal`, `parked`) are NOT scanned: the operations name
# them. A restatement in other words is not reached.
#
# Static read over a target that already lacks these phrases: it passes on its
# first run, which establishes nothing on its own; the discriminator below is
# what shows each scan can fail.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

for f in skills/backlog/SKILL.md skills/backlog/references/audit.md; do
  b="$(basename "$f" .md)"
  scan forbid "$f" "" "$b-high-definition" 'harm happening now' "A high entry needs evidence of harm happening now."
  scan forbid "$f" "" "$b-default-definition" 'an entry without this field is' "An entry without this field is normal."
done

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog/references"
cat > "$fixture/skills/backlog/SKILL.md" <<'FIXTURE'
# backlog

Set Priority to the file's default, and propose another value as the file directs.
FIXTURE
cat > "$fixture/skills/backlog/references/audit.md" <<'FIXTURE'
# Audit brief

For an entry whose Priority is high, say whether the evidence it names still holds.
FIXTURE

scan_run "$fixture"
