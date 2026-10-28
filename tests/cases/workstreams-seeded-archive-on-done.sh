#!/usr/bin/env bash
# Scenario: A finished workstream is archived.
# Requirement: A workstream register is seeded where none exists.
# Change: add-workstreams (project-bootstrap, ADDED).
#
# SPECIFIED: read at the archive of the change that made a workstream's Done
# when hold, the file directs moving the workstream to a dated file under
# `archive/` in the record's commit, after its unfinished steps and the
# entries naming it are dealt with.
# DERIVED (placement and wording, design.md decision 8): the paragraph (line)
# naming `archive/<YYYY-MM-DD>-<name>.md` also carries "Done when", "in the
# commit that carries the record", "step not done" and "backlog entr".
#
# Executes the tool and reads its output; no fixture owed. Red until the
# concern lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"

r="$work/docs/workstreams/AGENTS.md"
assert_file "$r" "the seeded file this case reads"

line="$(grep -F 'archive/<YYYY-MM-DD>-<name>.md' "$r" | grep -F 'Done when' | head -n1)"
if [ -z "$line" ]; then
  echo "FAIL: no paragraph of the seeded register directs archiving a workstream to a dated file once its Done when holds" >&2
  exit 1
fi
for phrase in "in the commit that carries the record" "step not done" "backlog entr"; do
  if ! printf '%s\n' "$line" | grep -q -F -- "$phrase"; then
    echo "FAIL: the archive direction does not carry \"$phrase\"" >&2
    printf '%s\n' "$line" >&2
    exit 1
  fi
done
