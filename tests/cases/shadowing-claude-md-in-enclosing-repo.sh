#!/usr/bin/env bash
# Scenario: A shadowing file above the target is reported like one in it.
# Case: the target is a subdirectory of an enclosing repository whose root
# holds a CLAUDE.md without the import.
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

outer="$TESTDIR/outer"
work="$outer/work"
mkdir -p "$work"
git -C "$outer" init -q
echo "# enclosing repository's conventions, no AGENTS.md import" > "$outer/CLAUDE.md"
sum_before="$(md5sum "$outer/CLAUDE.md" | awk '{print $1}')"
cd "$work" || exit 1

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_file "$work/AGENTS.md" "AGENTS.md created"
assert_import_line "$report" "the enclosing repository's CLAUDE.md shadows the AGENTS.md fallback"
assert_file_absent "$work/CLAUDE.md" "the tool creates no CLAUDE.md"
assert_unchanged "$outer/CLAUDE.md" "$sum_before" "the enclosing CLAUDE.md is never written to"
