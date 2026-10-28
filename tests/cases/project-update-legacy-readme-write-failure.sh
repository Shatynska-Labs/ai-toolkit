#!/usr/bin/env bash
# Scenario: A failed write during a conversion keeps the README.
# Requirement: The shapes before 1.0.0 are converted only where git holds the
# original. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where writing docs/backlog/AGENTS.md fails during a README
# conversion, the tool reports ERROR, docs/backlog/README.md is still
# present, and the report names every file the run wrote, created or removed.
# DERIVED (mechanism): docs/backlog/ is made unwritable (mode 555) after the
# commit, so every precondition holds and the write fails. The root AGENTS.md
# holds a v12 block too; where the manifest lists the workflow record before
# backlog (test-plan.md, Q3), that block was written first and the report must
# name AGENTS.md. Permissions do not bind as root; the case fails there.
# DERIVED (scope): exit 1.
#
# Executes the tool. Red until task 1.5 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
if [ "$(id -u)" = 0 ]; then
  echo "FAIL: running as root, an unwritable directory cannot be arranged" >&2; exit 1
fi
work="$TESTDIR/work"
d="$work/docs/backlog"
mkdir -p "$d"
printf '%s\n' "$V12_BLOCK" > "$work/$(target_of development-workflow)"
printf '# Backlog\n\nOur rules.\n' > "$d/README.md"
git_fixture "$work"
chmod 555 "$d"
trap 'chmod 755 "$d"' EXIT
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
status=$?
chmod 755 "$d"
assert_outcome "$TESTDIR/report.txt" 1 "$status" ERROR
assert_file "$d/README.md" "the README is kept"
wf_first="$(records | awk '$1 == "development-workflow" { w = NR } $1 == "backlog" { b = NR } END { print (w && b && w < b) ? "yes" : "no" }')"
if [ "$wf_first" = yes ] && [ "$(marker_version "$work/$(target_of development-workflow)" development-workflow)" = "$(fversion development-workflow)" ]; then
  grep -v "^Target:" "$TESTDIR/report.txt" | grep -q -E "(^|[^/A-Za-z])AGENTS[.]md" || { echo "FAIL: the root AGENTS.md was converted, and the report does not name it" >&2; cat "$TESTDIR/report.txt" >&2; exit 1; }
fi
