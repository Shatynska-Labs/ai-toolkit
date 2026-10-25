#!/usr/bin/env bash
# Scenario (mechanical half only): Invoked from a consuming project.
# Requirement: The skill operates on the project it is invoked in.
# Change: one-file-per-backlog-entry (backlog-maintenance, MODIFIED).
#
# SPECIFIED: the skill operates on `docs/backlog/` — its README.md and one
# file per entry; its description distinguishes it from
# `scripts/backlog-migrate`, which converts a single-file backlog.
# DERIVED (operationalisation): SKILL.md names `docs/backlog/` and
# `docs/backlog/README.md`; the description names `backlog-migrate`.
#
# Not asserted: that it reads and writes the invoking project's directory and
# touches nothing in this library. Conduct; verified by the trigger fixtures
# (task 3.2).
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

scan require "$S" "" names-directory 'docs/backlog/'
scan require "$S" "" names-readme 'docs/backlog/readme[.]md'
scan require "$S" @description names-migrate 'backlog-migrate'

cat > "$fixture/$S" <<'FIXTURE'
---
name: backlog
description: >
  Records, picks, closes, sweeps, audits and reports workstreams. Not
  project-init, which seeds the README, nor scripts/backlog-migrate, which
  converts a single-file backlog.
---

# backlog

Operates on `docs/backlog/` of the project it is invoked in, reading its rules from `docs/backlog/README.md`.
FIXTURE

scan_run "$fixture"
