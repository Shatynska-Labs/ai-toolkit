#!/usr/bin/env bash
# Scenarios: Empty directory takes the new-project path;
# Completion is verifiable rather than asserted;
# Discovery is named, not started; Nothing is committed without confirmation
# (script-side: it never runs `git commit` at all).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Precondition: no shadowing file (CLAUDE.md, CLAUDE.local.md or
# .claude/CLAUDE.md, other than $HOME/.claude/CLAUDE.md) above $TESTDIR, or
# the environment rather than the script decides the import report below.
for dir in "$TESTDIR" "$(cd "$TESTDIR" && pwd -P)"; do
  while :; do
    for cand in "${dir%/}/CLAUDE.md" "${dir%/}/CLAUDE.local.md" "${dir%/}/.claude/CLAUDE.md"; do
      [ "$cand" = "${HOME%/}/.claude/CLAUDE.md" ] && continue
      if [ -e "$cand" ]; then
        echo "FAIL: precondition not met — shadowing file above \$TESTDIR: $cand. Not a finding about the script." >&2
        exit 1
      fi
    done
    [ "$dir" = "/" ] && break
    dir="$(dirname "$dir")"
  done
done

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
report="$TESTDIR/report.txt"

bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status" "empty directory should succeed"
assert_file "$work/.git/HEAD" "git repository initialized"
assert_file "$work/openspec/config.yaml" "specification tooling initialized"
assert_file "$work/.gitignore" "ignore file created"
assert_file "$work/AGENTS.md" "conventions file created"
assert_contains "$work/AGENTS.md" "ai-toolkit:development-workflow" "managed block present"
assert_contains "$report" "Outcome: SUCCESS" "reports success"
assert_contains "$report" "Target:" "states the target directory"
assert_contains "$report" "foundation discovery" "names foundation discovery as next step"
# No shadowing file exists, so the import is not owed; the version note is.
if grep -qF "Import needed:" "$report"; then
  echo "FAIL: no shadowing file exists, so the report must not state the import as needed" >&2
  exit 1
fi
assert_contains "$report" "Note: Claude Code reads AGENTS.md without a CLAUDE.md from version 2.1.277" "the version note is reported where no shadowing file exists"

# Discovery is named, not started: no foundation change was created.
if [ -d "$work/openspec/changes" ] && find "$work/openspec/changes" -mindepth 1 -maxdepth 1 -not -name archive | grep -q .; then
  echo "FAIL: a change directory exists — foundation discovery was started, not merely named" >&2
  exit 1
fi

# Nothing is committed without confirmation: the script never commits.
if git -C "$work" log >/dev/null 2>&1; then
  echo "FAIL: a commit exists after a bare run — the script must never commit" >&2
  exit 1
fi
