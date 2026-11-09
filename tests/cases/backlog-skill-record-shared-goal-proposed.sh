#!/usr/bin/env bash
# Scenario (mechanical half only): Entries sharing a goal are proposed a
# workstream.
# Requirement: Record writes an entry the file can be relied on for.
# Change: propose-a-workstream-for-entries-sharing-a-goal (backlog-maintenance,
# MODIFIED).
#
# SPECIFIED: before writing the absent value, record reads the bodies of the
# other entries carrying it, not the repository, for a goal they share with the
# entry; where they share one it proposes opening a workstream for it as
# `docs/workstreams/AGENTS.md` directs, naming the entries and a draft Goal, and
# writes the absent value meanwhile.
# DERIVED (structure, as backlog-skill-record.sh assumes): read from the section
# under a heading naming `record`.
# DERIVED (wording, design.md decision 4): each require scan is one phrase of
# that step's text.
# DERIVED (design.md decision 4, "the skill does not restate"): [no-unasked]
# forbids the skill restating the rule's "opens none unasked"; the rule holds it
# (workstreams-block-proposes-a-workstream.sh).
#
# Not asserted: that a session reads the entries, judges a shared goal and
# creates no workstream file. Conduct (design.md decision 10); no scan holds it.
#
# Static read (third situation); every scan is discriminated by a mutant. Red at
# authoring on every require scan (state 1 on real content); goes green as task
# 2.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" record reads-bodies 'read the bodies of the other entries carrying it, not the repository'
scan require "$S" record shared-goal 'for a goal they share with this entry'
scan require "$S" record proposes 'propose opening a workstream for it as the workstreams readme directs'
scan require "$S" record names-draft 'naming the entries and a draft goal'
scan require "$S" record meanwhile 'write the absent value meanwhile'
scan forbid "$S" record no-unasked 'opens? none unasked|never open it unasked' 'Never open it unasked.'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Record

7. **Workstream.** Say in your answer which workstream you chose for each entry and why. Before writing the absent value, read the bodies of the other entries carrying it, not the repository, for a goal they share with this entry. Where they share one, propose opening a workstream for it as the workstreams README directs, naming the entries and a draft Goal, and write the absent value meanwhile. Say in your answer what you proposed, or that no shared goal was found.

## Pick

Lists takeable entries.
FIXTURE

scan_run "$fixture"
