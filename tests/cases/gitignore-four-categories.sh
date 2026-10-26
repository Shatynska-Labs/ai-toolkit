#!/usr/bin/env bash
# seed-the-worktree-ignore-entry, project-bootstrap (MODIFIED requirement
# "The minimal ignore file is enumerated, not described"), scenario:
# Created ignore file carries no stack assumption — revised from three
# categories to four. Supersedes gitignore-enumerated-entries.sh, which
# asserts the three-category entry set and not "only"; see the change's
# test-plan.md.
#
#   [headings]  SPECIFIED  the created file's category headings are exactly
#                          `# Environment`, `# OS`, `# Editors`,
#                          `# Working trees` — "only the four enumerated
#                          categories"
#   [entries]   SPECIFIED  its entry lines are exactly the nine the
#                          requirement enumerates — "exactly these entries and
#                          no others"
#   [stack]     SPECIFIED  no entry names a language's dependency directory,
#                          build output or cache; the marker list itself is
#                          DERIVED (carried over from
#                          gitignore-enumerated-entries.sh)
#
# DERIVED reading: a line starting with `#` is a category heading, a blank
# line separates, and every other line is an entry. Order and blank-line
# layout are deliberately not asserted (design.md decision 3: entries, not
# layout).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1

bash "$PROJECT_INIT" >/dev/null 2>&1

assert_file "$work/.gitignore" "the ignore file was created"

# Sorted, de-duplicated sets, so the comparison ignores order.
expected_headings="$(printf '%s\n' '# Environment' '# OS' '# Editors' '# Working trees' | LC_ALL=C sort -u)"
expected_entries="$(printf '%s\n' '.env' '.env.*' '!.env.example' '.DS_Store' 'Thumbs.db' '.idea/' '.vscode/' '.worktrees/' '.claude/worktrees/' | LC_ALL=C sort -u)"

actual_headings="$(grep -E '^#' "$work/.gitignore" | sed 's/[[:space:]]*$//' | LC_ALL=C sort -u)"
actual_entries="$(grep -vE '^#|^[[:space:]]*$' "$work/.gitignore" | sed 's/[[:space:]]*$//' | LC_ALL=C sort -u)"

if [ "$actual_headings" != "$expected_headings" ]; then
  echo "FAIL: [headings] the created ignore file's categories are not exactly the four enumerated" >&2
  echo "  expected:" >&2; printf '%s\n' "$expected_headings" | sed 's/^/    /' >&2
  echo "  actual:" >&2; printf '%s\n' "$actual_headings" | sed 's/^/    /' >&2
  exit 1
fi

if [ "$actual_entries" != "$expected_entries" ]; then
  echo "FAIL: [entries] the created ignore file's entries are not exactly the enumerated nine" >&2
  echo "  expected:" >&2; printf '%s\n' "$expected_entries" | sed 's/^/    /' >&2
  echo "  actual:" >&2; printf '%s\n' "$actual_entries" | sed 's/^/    /' >&2
  exit 1
fi

for forbidden in 'node_modules' '__pycache__' 'target/' 'venv' '.venv' 'dist/' 'build/'; do
  if grep -qF -- "$forbidden" "$work/.gitignore"; then
    echo "FAIL: [stack] stack-specific entry present in the created ignore file: $forbidden" >&2
    exit 1
  fi
done
