#!/usr/bin/env bash
# Scenario (mechanical half only): The fragment defers the workstream rules to
# the README.
# Requirement: A change states the workstream it advances, and archiving
# re-reads it. Change: add-workstreams (session-workflow, ADDED).
#
# SPECIFIED: the fragment directs a session to `docs/workstreams/README.md`
# and names the directory as `docs/workstreams/`; it states no workstream
# field, file shape or archive path itself; it names no entry field; it does
# not direct creating the README where it is absent.
# DERIVED (operationalisation): a restatement is recognised by the seeded
# README's field labels (`**Goal**`, `**Done when**`, `**Not in scope**`,
# `**Open questions**`, `**Opened**`), its archive path
# (`workstreams/archive`, `archive/<yyyy-mm-dd>`), and its distinctive status
# phrases (design.md decision 8); the entry field by `**Workstream**`; a
# creation direction by the README with an absence condition or a creation
# verb applied to it. Wording outside these is not reached; verified by
# reading.
#
# Static read: the forbid scans are green on the pre-change fragment, so each
# is shown able to fail by its mutant; the require scans are red until the
# references land.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck disable=SC1091 # resolved beside this case at runtime; the helper is checked on its own
source "$(dirname "${BASH_SOURCE[0]}")/lib/static-scan.sh"

F=rules/development-workflow.md
scan require "$F" "" defers-to-readme 'docs/workstreams/agents[.]md'
scan require "$F" "" names-directory 'docs/workstreams/([^r]|$)'
scan forbid "$F" "" shape-field '[*][*](goal|done when|not in scope|open questions|opened)[*][*]' '**Done when**: a condition that can be checked.'
# shellcheck disable=SC2016 # backticks are literal markdown in the pattern and specimen
scan forbid "$F" "" archive-path 'workstreams/archive|archive/<yyyy-mm-dd>' 'Move it to `docs/workstreams/archive/<YYYY-MM-DD>-<name>.md`.'
scan forbid "$F" "" status-rule 'holds the plan and never|first of these that holds|freshly fetched trunk holds an archived' 'A workstream file holds the plan and never its progress.'
scan forbid "$F" "" entry-field '[*][*]workstream[*][*]' 'Set the entry'"'"'s **Workstream** to this change'"'"'s workstream.'
# shellcheck disable=SC2016 # backticks are literal markdown in the pattern and specimen
scan forbid "$F" "" creates-readme 'readme[^.]*(if|where|when) (it is )?(absent|missing)|creat(e|ing) (the|that|a|its) readme|creat(e|ing) `?docs/workstreams' 'Create `docs/workstreams/README.md` where it is absent.'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/rules"
cat > "$fixture/$F" <<'FIXTURE'
# Workflow

Where a workstream in `docs/workstreams/` names this change, the proposal names it.

At archive, re-read the workstream as `docs/workstreams/AGENTS.md` directs.
FIXTURE

scan_run "$fixture"
