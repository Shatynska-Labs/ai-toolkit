#!/usr/bin/env bash
# Scenario (mechanical half only): Invoked from a consuming project.
# Requirement: The skill operates on the project it is invoked in.
# Change: add-backlog-skill (backlog-maintenance, ADDED).
#
# SPECIFIED: the skill sits at skills/backlog/SKILL.md with `name: backlog`;
# it operates on `docs/backlog.md`; its description states the five
# operations (record, pick, close, sweep, audit) and distinguishes it from
# `project-init` and from the OpenSpec skills.
# DERIVED (design.md decision 5, not the spec): `metadata.tags` carries
# `project-lifecycle`.
# DERIVED (operationalisation): "distinguishes it from the OpenSpec skills" is
# read as the description naming OpenSpec; the distinction itself is prose.
#
# Not asserted: that the skill reads and writes the invoking project's file
# and touches nothing in this library. That is conduct at run time; verified
# by the create-skill trigger and post-write checks (tasks 3.2, 3.4).
#
# Static read: every scan is discriminated by a mutant in scan_discriminate.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
scan require "$S" "" name '^name:[[:space:]]*backlog[[:space:]]*$'
scan require "$S" "" target-file 'docs/backlog[.]md'
scan require "$S" "" tag-project-lifecycle 'project-lifecycle'
scan require "$S" @description op-record 'record'
scan require "$S" @description op-pick 'pick'
scan require "$S" @description op-close 'close'
scan require "$S" @description op-sweep 'sweep'
scan require "$S" @description op-audit 'audit'
scan require "$S" @description not-project-init 'project-init'
scan require "$S" @description not-openspec 'openspec'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
---
name: backlog
description: >
  Use to record an entry, pick work, close an entry, sweep at archive, or audit
  the backlog. Not project-init, which seeds the file, and not the OpenSpec
  skills, which open the change.
metadata:
  tags: [project-lifecycle]
---

# backlog

Operates on `docs/backlog.md` of the project it is invoked in.
FIXTURE

scan_run "$fixture"
