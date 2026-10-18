#!/usr/bin/env bash
# Scenario: The user's own instructions file does not shadow.
# Case: the target sits under $HOME, whose .claude/CLAUDE.md is the only
# shadowing candidate. HOME is pointed under $TESTDIR (design.md, Risks).
# Derived by change-test-writer for retire-the-claude-md-import-notice; see
# that change's test-plan.md for each assertion's classification.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Asserts the report carries the version note and not the import line.
assert_version_note() {
  local report="$1" note
  if grep -qF 'Import needed:' "$report"; then
    echo "FAIL: the report states the import as needed where no shadowing file exists" >&2
    exit 1
  fi
  if grep -qF 'for the rules to take effect' "$report"; then
    echo "FAIL: the report still says an import is needed for the rules to take effect" >&2
    exit 1
  fi
  note="$(grep -F '2.1.277' "$report")"
  if [ -z "$note" ]; then
    echo "FAIL: no note naming Claude Code 2.1.277, the version from which AGENTS.md is read without a CLAUDE.md" >&2
    exit 1
  fi
  case "$note" in
    'Import needed:'*) echo "FAIL: the note begins 'Import needed:': $note" >&2; exit 1 ;;
  esac
  case "$note" in
    'Note:'*) ;;
    *) echo "FAIL: the note does not begin 'Note:' (design.md Decision 2 wording): $note" >&2; exit 1 ;;
  esac
  assert_contains "$report" "2.1.281" "the note names the later version for the providers and sessions reached afterwards"
  assert_contains "$report" "Project instructions" "the note names the setting that can turn the fallback off"
}

export HOME="$TESTDIR/home" XDG_CONFIG_HOME="$TESTDIR/xdg" GIT_CONFIG_NOSYSTEM=1

# Precondition (design.md, Risks): no shadowing file — CLAUDE.md,
# CLAUDE.local.md or .claude/CLAUDE.md — in $TESTDIR or any directory above
# it, other than $HOME/.claude/CLAUDE.md for the HOME in effect. If one
# exists, the environment, not the script, decides the report, so the case
# fails with that reason rather than reporting a script defect.
shadows_above_testdir() {
  local start dir p cand found=""
  for start in "$TESTDIR" "$(cd "$TESTDIR" && pwd -P)"; do
    dir="$start"
    while :; do
      p="${dir%/}"
      for cand in "$p/CLAUDE.md" "$p/CLAUDE.local.md" "$p/.claude/CLAUDE.md"; do
        [ "$cand" = "${HOME%/}/.claude/CLAUDE.md" ] && continue
        if [ -e "$cand" ]; then found="$found $cand"; fi
      done
      [ "$dir" = "/" ] && break
      dir="$(dirname "$dir")"
    done
  done
  printf '%s' "$found"
}
shadows="$(shadows_above_testdir)"
if [ -n "$shadows" ]; then
  echo "FAIL: precondition not met — shadowing file(s) above \$TESTDIR:$shadows. This case cannot observe the no-shadowing-file report here; it is not a finding about the script." >&2
  exit 1
fi

work="$HOME/work"
mkdir -p "$work" "$HOME/.claude" "$XDG_CONFIG_HOME"
echo "# the user's own instructions" > "$HOME/.claude/CLAUDE.md"
sum_before="$(md5sum "$HOME/.claude/CLAUDE.md" | awk '{print $1}')"
cd "$work" || exit 1

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_file "$work/AGENTS.md" "AGENTS.md created"
assert_version_note "$report"
assert_file_absent "$work/CLAUDE.md" "the tool creates no CLAUDE.md"
assert_unchanged "$HOME/.claude/CLAUDE.md" "$sum_before" "the user's own CLAUDE.md is never written to"
