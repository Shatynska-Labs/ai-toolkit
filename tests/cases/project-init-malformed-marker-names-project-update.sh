#!/usr/bin/env bash
# Scenario: An unreadable version is reported as malformed.
# Requirement: Workflow rules reach a project as a versioned managed block.
# Change: update-managed-block (project-bootstrap, MODIFIED).
#
# SPECIFIED: where AGENTS.md holds
# `<!-- ai-toolkit:development-workflow 1.0 sha256:<hash> -->`, the block is
# left unchanged, the run does not fail on the comparison, and the report
# states the marker is malformed and names scripts/project-update.
# DERIVED (token): "does not fail" read as exit 0; the statement read on the
# `conventions file:` line, stating `malformed` and `scripts/project-update`.
#
# Executes project-init. Red until task 2.1 lands (state 1).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
work="$TESTDIR/work"
mkdir -p "$work"
f="$work/$(target_of development-workflow)"
inner='some rules'
h="$(printf '%s\n' "$inner" | sha256_of)"
printf '<!-- ai-toolkit:development-workflow 1.0 sha256:%s -->\n%s\n<!-- /ai-toolkit:development-workflow -->\n' "$h" "$inner" > "$f"
sum="$(md5sum "$f" | awk '{print $1}')"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?" "the run does not fail on the comparison"
assert_unchanged "$f" "$sum" "the malformed block"
expect_line "$TESTDIR/report.txt" "conventions file" malformed "scripts/project-update"
