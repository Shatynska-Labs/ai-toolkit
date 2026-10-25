#!/usr/bin/env bash
# Scenario (mechanical half only): No backlog exists.
# Requirement: The skill operates on the project it is invoked in.
# Change: one-file-per-backlog-entry (backlog-maintenance, MODIFIED).
#
# SPECIFIED: where the project has neither `docs/backlog/README.md` nor
# `docs/backlog.md`, the skill says so and names `project-init` as what seeds
# the backlog.
# DERIVED (operationalisation): a paragraph naming `project-init` and an
# absence (neither, absent, missing, not exist, no) names
# `docs/backlog/readme.md`.
#
# Deliberately untested: "creates nothing with text of its own"; a scan
# cannot tell a direction from a prohibition. Verified by reading.
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# until task 3.2 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/line-scan.sh"

line_select 'project-init'
line_select 'neither|absent|missing|not exist|(^|[^a-z])no '
line_scan require names-readme 'docs/backlog/readme[.]md'

fixture="$TESTDIR/SKILL.md"
cat > "$fixture" <<'FIXTURE'
# backlog

Where the project has neither `docs/backlog/README.md` nor `docs/backlog.md`, say so: `project-init` seeds the backlog.
FIXTURE

line_run "$fixture" skills/backlog/SKILL.md
