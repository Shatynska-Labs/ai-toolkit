#!/usr/bin/env bash
# Scenario: A project without a backlog receives the seeded file — the
# statements add-backlog-skill's MODIFIED requirement adds or revises.
# Change: add-backlog-skill (project-bootstrap, MODIFIED "A backlog is seeded
# where none exists"). The statements the delta carries through unchanged
# stay asserted by backlog-seeded-new-project.sh.
#
# SPECIFIED: the created file states that a fix takes the entry's name as its
# branch's name only; that an entry states in its own fields what it waits on
# and which entries share a design with it; that an entry is kept short, with
# files, specifications and changes as pointers and without line numbers,
# census tables or step-by-step plans; that an entry is deleted when a change
# makes it obsolete; that when a change is archived the entries it unblocked
# or made stale are updated and their re-checked date set; that Waits on is
# `nothing` or something checkable — a change by name, a person's answer, an
# event; and that Re-checked is the date last verified against the repository.
#
# DERIVED (wording): the requirement fixes what the text states, not the text.
# Each statement is asserted by one stable phrase from the seeded text in
# design.md decision 2, as backlog-seeded-new-project.sh does. A rewording
# that keeps a statement but drops its phrase fails here.
# DERIVED (placement): the archive-time update and its Re-checked date are one
# line (paragraph), as design.md writes them.
#
# Executes the tool and reads its output, so no fixture is owed: the file
# exists only after the run.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"

backlog="$work/docs/backlog.md"
assert_file "$backlog" "the seeded file this case reads"

assert_contains "$backlog" "as its branch's only" \
  "statement 2: a fix takes the name as its branch's name only"
assert_contains "$backlog" "in its own fields" \
  "statement 3: an entry states in its own fields what it waits on and designs with"
assert_contains "$backlog" "Keep an entry short" \
  "brevity: an entry is kept short"
assert_contains "$backlog" "as pointers" \
  "brevity: files, specifications and changes named as pointers"
assert_contains "$backlog" "line numbers" \
  "brevity: without line numbers"
assert_contains "$backlog" "census tables" \
  "brevity: without census tables"
assert_contains "$backlog" "step-by-step plans" \
  "brevity: without step-by-step plans"
assert_contains "$backlog" "when a change makes it obsolete" \
  "deletion: when a change makes it obsolete"
assert_contains "$backlog" "unblocked or made stale" \
  "archive-time update: entries unblocked or made stale are updated"
assert_contains "$backlog" "something that can be checked" \
  "Waits on: something that can be checked"
assert_contains "$backlog" "a person's answer" \
  "Waits on: a change by name, a person's answer, an event"
assert_contains "$backlog" "share a design" \
  "Design with: entries sharing a design"
assert_contains "$backlog" "last verified against the repository" \
  "Re-checked: the date last verified against the repository"

if ! grep -E 'unblocked or made stale' "$backlog" | grep -q 'Re-checked'; then
  echo "FAIL: the archive-time update does not set the Re-checked date in the same statement" >&2
  grep -n 'unblocked or made stale' "$backlog" >&2
  exit 1
fi
