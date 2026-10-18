#!/usr/bin/env bash
# Requirement: Workflow rules reach a project as a versioned managed block —
# only the target's own CLAUDE.md counts as importing AGENTS.md. Case: a
# CLAUDE.md above the target holds @AGENTS.md (which would import that
# directory's AGENTS.md, not the target's); the target has no CLAUDE.md.
# Derived by change-test-writer for retire-the-claude-md-import-notice; see
# that change's test-plan.md for each assertion's classification.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Asserts the report carries the import line, naming the target's own
# CLAUDE.md and that it may need creating, and does not carry the version note.
assert_import_line() {
  local report="$1" why="$2" line
  line="$(grep -F 'Import needed:' "$report")"
  if [ -z "$line" ]; then
    echo "FAIL: no 'Import needed:' line — $why" >&2
    exit 1
  fi
  case "$line" in
    *'@AGENTS.md'*) ;;
    *) echo "FAIL: the import line does not name @AGENTS.md: $line" >&2; exit 1 ;;
  esac
  case "$line" in
    *"own CLAUDE.md"*) ;;
    *) echo "FAIL: the import line does not name the target's own CLAUDE.md as where the import goes: $line" >&2; exit 1 ;;
  esac
  case "$line" in
    *creat*) ;;
    *) echo "FAIL: the import line does not say the file may need creating: $line" >&2; exit 1 ;;
  esac
  if grep -qF '2.1.277' "$report"; then
    echo "FAIL: the version note was printed where a shadowing file exists — the import line, not the note, is owed" >&2
    exit 1
  fi
}

parent="$TESTDIR/parent"
work="$parent/work"
mkdir -p "$work"
echo "@AGENTS.md" > "$parent/CLAUDE.md"
cd "$work" || exit 1

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_file "$work/AGENTS.md" "AGENTS.md created"
assert_import_line "$report" "an import in a CLAUDE.md above the target does not import the target's AGENTS.md"
