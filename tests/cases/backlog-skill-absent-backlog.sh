#!/usr/bin/env bash
# Scenario (mechanical half only): No backlog exists.
# Requirement: The skill operates on the project it is invoked in.
# Change: add-backlog-skill (backlog-maintenance, ADDED).
#
# SPECIFIED: where the project has no `docs/backlog.md`, the skill says so and
# names `project-init` as what seeds the file.
# DERIVED (operationalisation): one line (paragraph) of SKILL.md names
# `project-init` together with an absence condition — absent, missing, does
# not exist, not exist, or "no docs/backlog.md".
#
# Deliberately untested: "does not create the file with text of its own". A
# lexical scan cannot tell a direction to create the file from a sentence
# saying not to, so a scan would fail compliant wording. Verified by reading.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

S=skills/backlog/SKILL.md
# shellcheck disable=SC2016 # backticks are literal markdown in the pattern
scan require "$S" "" absent-names-seeder 'project-init.*(absent|missing|not exist|no `?docs/backlog[.]md)|(absent|missing|not exist|no `?docs/backlog[.]md).*project-init'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

Where the project has no `docs/backlog.md`, say so: `project-init` seeds it.
FIXTURE

scan_run "$fixture"
