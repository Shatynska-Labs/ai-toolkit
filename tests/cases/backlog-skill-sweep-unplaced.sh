#!/usr/bin/env bash
# Scenarios (mechanical half only): An entry naming the open workstream that no
# step names; An entry the change recorded is not yet on the trunk.
# Requirement: Sweep performs the archive step's re-read.
# Change: match-backlog-entries-to-a-workstream (backlog-maintenance, MODIFIED).
#
# SPECIFIED: where the change advanced an open workstream its archive does not
# archive, sweep gathers the entries the workstreams operation's unplaced read
# finds in it, that read made over the change's working tree as well as the trunk
# so that the entries the change recorded are among them, rather than by a second
# definition; each is presented to be placed among the steps, the position asked
# of the operator, or detached; the workstream's steps are the one edit sweep
# makes outside the entry files, in the same commit.
# DERIVED (structure, as backlog-skill-sweep.sh assumes): read from the section
# under a heading naming `sweep`.
# DERIVED (wording, design.md decision 4): each scan is one phrase of the group,
# and [one-outside-edit] and [same-commit] read the words of decision 4's last
# sentence, which fixes the sense and not the text.
#
# Not asserted: that sweep finds or presents such an entry. Conduct.
#
# Static read (third situation); every scan is discriminated by a mutant. Red at
# authoring (state 1 on real content); goes green as task 2.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" sweep open-workstream-group 'advanced an open workstream its archive does not archive'
scan require "$S" sweep reuses-unplaced '[*]unplaced[*] read'
scan require "$S" sweep working-tree 'working tree as well as the trunk'
scan require "$S" sweep own-entries 'entries this change recorded'
scan require "$S" sweep placed-or-detached 'placed among the steps, the order asked of the operator, or detached'
scan require "$S" sweep one-outside-edit 'one edit[^.]*outside the entry files'
scan require "$S" sweep same-commit 'same commit'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Sweep

The workstream's steps are the one edit it makes outside the entry files, in the same commit.

2. Gather these, and, where the change advanced an open workstream its archive does not archive, the entries the **workstreams** operation's *Unplaced* read finds in it, made over the change's working tree as well as the trunk so that the entries this change recorded are among them, each to be placed among the steps, the order asked of the operator, or detached as `docs/workstreams/AGENTS.md` directs, by the same read of the open workstreams' Goals **record** makes.

## Audit

Fans out.
FIXTURE

scan_run "$fixture"
