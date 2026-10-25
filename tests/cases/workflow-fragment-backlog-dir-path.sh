#!/usr/bin/env bash
# Requirement text, accounted under the scenarios that name the path (An
# unrelated improvement is recorded rather than implemented; Recording is
# stated as what is owed; Entry rules are read from the backlog, not the
# fragment): "The fragment SHALL name the backlog's path as `docs/backlog/`."
# Requirement: A second change surfacing in a session is recorded in the
# backlog. Change: one-file-per-backlog-entry (session-workflow, MODIFIED).
#
# SPECIFIED: the fragment names `docs/backlog/`.
# DERIVED (design.md decision 9, task 3.1 "wherever docs/backlog.md is
# named"): it no longer names `docs/backlog.md` anywhere.
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# until task 3.1 lands (state 1).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

F=rules/development-workflow.md
scan require "$F" "" names-directory 'docs/backlog/'
# shellcheck disable=SC2016 # backticks are literal markdown in the specimen
scan forbid "$F" "" no-single-file 'docs/backlog[.]md' 'Record it in `docs/backlog.md`.'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/rules"
cat > "$fixture/$F" <<'FIXTURE'
# Workflow

- Where it **does not**: record it in `docs/backlog/`. That is what is owed.
FIXTURE

scan_run "$fixture"
