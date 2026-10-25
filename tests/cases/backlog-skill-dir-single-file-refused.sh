#!/usr/bin/env bash
# Scenario (mechanical half only): A project on the single file.
# Requirement: The skill operates on the project it is invoked in.
# Change: one-file-per-backlog-entry (backlog-maintenance, MODIFIED).
#
# SPECIFIED: where the project has `docs/backlog.md` and no
# `docs/backlog/README.md`, the skill says the backlog is in the single-file
# shape, names `scripts/backlog-migrate`, and performs no operation.
# DERIVED (operationalisation): a paragraph naming `docs/backlog.md` and
# `backlog-migrate` says `single` and that no operation runs ("no
# operation", "performs nothing", "stop", "does nothing").
#
# Not asserted: that docs/backlog.md is left unchanged, and that the skill
# does not convert the file itself. A scan cannot tell a direction from a
# prohibition here; verified by reading.
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# until task 3.2 lands (state 2: no such paragraph).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select 'docs/backlog[.]md'
line_select 'backlog-migrate'
line_scan require single-file 'single'
line_scan require no-operation 'no operation|performs? nothing|does nothing|stop'

fixture="$TESTDIR/SKILL.md"
cat > "$fixture" <<'FIXTURE'
# backlog

Where the project has `docs/backlog.md` and no `docs/backlog/README.md`, say the backlog is in the single-file shape, name `scripts/backlog-migrate` as what converts it, and perform no operation.
FIXTURE

line_run "$fixture" skills/backlog/SKILL.md
