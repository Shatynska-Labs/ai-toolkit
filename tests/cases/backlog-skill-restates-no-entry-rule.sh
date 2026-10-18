#!/usr/bin/env bash
# Scenario (mechanical half only): A project's preamble differs from the
# seeded one. Requirement: The skill restates neither the entry rules nor the
# workflow's obligations. Change: add-backlog-skill (backlog-maintenance).
#
# SPECIFIED: the skill reads the entry rules from the file's preamble and
# SHALL NOT restate them.
# DERIVED (operationalisation): a restatement is recognised by the seeded
# preamble's distinctive phrases (design.md decision 2) — `kebab-case`,
# `carries no meaning`, `has no entries`, `census tables`, `step-by-step
# plans`, `will not be made`. None may appear in SKILL.md or
# references/audit.md. Field names (Kind, Waits on, ...) are NOT scanned: the
# operations act on fields and the spec names them in the operations
# themselves. A restatement in other words is not reached.
#
# Not asserted: that the skill checks entries against the shape the file
# states rather than one of its own. Conduct at run time; verified by reading.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

for f in skills/backlog/SKILL.md skills/backlog/references/audit.md; do
  b="$(basename "$f" .md)"
  scan forbid "$f" "" "$b-kebab" 'kebab-case' "An entry's heading is the change's name in kebab-case."
  scan forbid "$f" "" "$b-order" 'carries no meaning' "The order of entries carries no meaning."
  scan forbid "$f" "" "$b-empty" 'has no entries' "Keep the file when it has no entries."
  scan forbid "$f" "" "$b-census" 'census tables' "Leave out census tables."
  scan forbid "$f" "" "$b-plans" 'step-by-step plans' "Leave out step-by-step plans."
  scan forbid "$f" "" "$b-notmade" 'will not be made' "Delete it when the change will not be made."
done

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog/references"
cat > "$fixture/skills/backlog/SKILL.md" <<'FIXTURE'
# backlog

Read how an entry is shaped and when it is deleted from the file's own preamble.
FIXTURE
cat > "$fixture/skills/backlog/references/audit.md" <<'FIXTURE'
# Audit brief

Check each entry against the shape the backlog's preamble states.
FIXTURE

scan_run "$fixture"
