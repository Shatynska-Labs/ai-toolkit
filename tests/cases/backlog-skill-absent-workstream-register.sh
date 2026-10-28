#!/usr/bin/env bash
# Scenario (mechanical half only): No workstream register exists.
# Requirement: The skill operates on the project it is invoked in.
# Change: add-workstreams (backlog-maintenance, MODIFIED).
#
# SPECIFIED: where `docs/workstreams/README.md` is absent, an operation step
# that reads workstreams says so, names `project-init` as what seeds it, and
# is skipped.
# DERIVED (operationalisation): one line (paragraph) of SKILL.md names the
# README's path with an absence condition (absent, missing, not exist, or
# "no docs/workstreams/README.md"); one line names the path and
# `project-init`; one line pairs `workstream` with `skip`.
#
# Deliberately untested: "creates nothing" / "SHALL NOT create the file". A
# lexical scan cannot tell a direction to create it from a sentence saying
# not to; verified by reading.
#
# Static read: red until the step lands; every scan is discriminated by a
# mutant in scan_discriminate.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
# shellcheck disable=SC2016 # backticks are literal markdown in the pattern
scan require "$S" "" register-absent 'docs/workstreams/agents[.]md[^.]*(absent|missing|not exist)|(absent|missing|not exist)[^.]*docs/workstreams/agents[.]md|no `?docs/workstreams/agents[.]md'
scan require "$S" "" register-seeder 'docs/workstreams/agents[.]md.*project-init|project-init.*docs/workstreams/agents[.]md'
scan require "$S" "" register-steps-skipped 'workstream[^.]*skip|skip[^.]*workstream'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Before any operation

Where the project has no `docs/workstreams/AGENTS.md`, say so: `project-init` seeds it.
Then skip every step that reads a workstream.
FIXTURE

scan_run "$fixture"
