#!/usr/bin/env bash
# Scenario (mechanical half only): A project's workstream README differs from
# the seeded one.
# Requirement: The skill restates neither the entry rules nor the workflow's
# obligations. Change: add-workstreams (backlog-maintenance, MODIFIED).
#
# SPECIFIED: the skill reads how a workstream is named, shaped, kept and
# archived, and how a step's status is derived, from
# `docs/workstreams/README.md`, and does not restate those rules.
# DERIVED (operationalisation): SKILL.md names `docs/workstreams/README.md`;
# a restatement is recognised by the seeded README's distinctive phrases
# (design.md decision 8) — "holds the plan and never", "gates nothing",
# "unique among workstreams", "keep a workstream short", "when there is no
# workstream", "first of these that holds" — none of which may appear in
# SKILL.md or references/audit.md. Status names (done, in flight, recorded,
# planned) and the archive path are NOT scanned: the operations name them. A
# restatement in other words is not reached.
#
# Not asserted: that the skill derives status by what the project's file
# states rather than by rules of its own. Conduct; verified by reading.
#
# Static read: the forbid scans are green on the pre-change skill, so each is
# shown able to fail by its mutant; the require scan is red until it lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

scan require skills/backlog/SKILL.md "" reads-readme 'docs/workstreams/readme[.]md'
for f in skills/backlog/SKILL.md skills/backlog/references/audit.md; do
  b="$(basename "$f" .md)"
  scan forbid "$f" "" "$b-plan-not-progress" 'holds the plan and never' "A workstream file holds the plan and never its progress."
  scan forbid "$f" "" "$b-order" 'gates nothing' "The order of the steps gates nothing."
  scan forbid "$f" "" "$b-unique" 'unique among workstreams' "A name is unique among workstreams, open and archived."
  scan forbid "$f" "" "$b-short" 'keep a workstream short' "Keep a workstream short."
  scan forbid "$f" "" "$b-kept" 'when there is no workstream' "Keep the README when there is no workstream."
  scan forbid "$f" "" "$b-precedence" 'first of these that holds' "The first of these that holds wins."
done

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog/references"
cat > "$fixture/skills/backlog/SKILL.md" <<'FIXTURE'
# backlog

Read how a workstream is shaped, and how a step's status is derived, from `docs/workstreams/README.md`.
FIXTURE
cat > "$fixture/skills/backlog/references/audit.md" <<'FIXTURE'
# Audit brief

Say whether the workstream an entry names is open.
FIXTURE

scan_run "$fixture"
