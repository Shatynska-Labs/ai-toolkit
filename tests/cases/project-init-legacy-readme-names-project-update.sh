#!/usr/bin/env bash
# Scenario: A backlog README is left alone (as revised).
# Requirement: A directory holding its rules in a README is reported, not
# converted. Change: update-managed-block (project-bootstrap, MODIFIED).
#
# SPECIFIED: where docs/backlog/ holds README.md and entry files and no
# AGENTS.md, no AGENTS.md or CLAUDE.md is created in it, every file in it is
# unchanged, and the report states the backlog's rules are in the shape
# before 1.0.0 and that scripts/project-update converts them.
# SPECIFIED (requirement text, not this scenario): the same report for
# docs/workstreams/ — the requirement names scripts/project-update for every
# directory the manifest targets, and the unchanged workstreams scenario does
# not restate it.
# DERIVED (token): read on the `backlog:` and `workstreams:` lines, stating
# `1.0.0` and `scripts/project-update`; the superseded "out of scope" wording
# must be gone from them.
#
# Executes project-init. Red until task 2.1 lands (state 1).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
work="$TESTDIR/work"
mkdir -p "$work/docs/backlog" "$work/docs/workstreams"
printf '# Backlog\n\nOur rules, as seeded before 1.0.0.\n' > "$work/docs/backlog/README.md"
printf -- '---\npriority: normal\nkind: fix\n---\n\nAn entry.\n' > "$work/docs/backlog/some-entry.md"
printf '# Workstreams\n\nOur rules.\n' > "$work/docs/workstreams/README.md"
b_before="$(tree_sum "$work/docs/backlog")"
w_before="$(tree_sum "$work/docs/workstreams")"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_tree "$work/docs/backlog" "$b_before" "docs/backlog/ gains or changes nothing"
assert_tree "$work/docs/workstreams" "$w_before" "docs/workstreams/ gains or changes nothing"
for name in backlog workstreams; do
  expect_line "$TESTDIR/report.txt" "$name" 1.0.0 "scripts/project-update"
  refuse_line "$TESTDIR/report.txt" "$name" "out of scope"
done
