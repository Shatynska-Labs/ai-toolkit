#!/usr/bin/env bash
# seed-the-worktree-ignore-entry, project-bootstrap (MODIFIED requirement
# "The minimal ignore file is enumerated, not described"), scenario:
# Created ignore file ignores the working-tree roots.
#
#   [root-worktrees]         SPECIFIED  the created file contains `.worktrees/`
#   [root-claude-worktrees]  SPECIFIED  the created file contains
#                                       `.claude/worktrees/`
#
# DERIVED reading: "contains" is read as a whole line, because an ignore
# file's entry is a line; a substring match would let `.claude/worktrees/`
# stand in for nothing and a commented-out `# .worktrees/` stand in for an
# entry.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

bash "$PROJECT_INIT" >/dev/null 2>&1

assert_file "$work/.gitignore" "the ignore file was created"

for pair in 'root-worktrees:.worktrees/' 'root-claude-worktrees:.claude/worktrees/'; do
  tag="${pair%%:*}"
  entry="${pair#*:}"
  if ! grep -qxF -- "$entry" "$work/.gitignore"; then
    echo "FAIL: [$tag] the created ignore file has no line reading exactly: $entry" >&2
    exit 1
  fi
done
