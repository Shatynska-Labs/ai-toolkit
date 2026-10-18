#!/usr/bin/env bash
# Scenario: The fragment defers the update's form to the file.
# Change: add-backlog-skill (session-workflow, ADDED "Archiving a change
# re-reads the backlog against it").
#
# SPECIFIED: the fragment names no entry field, date rule or deletion ground
# itself; how an entry is updated is the file's.
# DERIVED (operationalisation): no entry-field label appears anywhere in the
# fragment — `Waits on`, `Design with`, `Re-checked`, `Recorded by`,
# `Depends on` (case-sensitive, so prose "waits on" is not caught), or Kind as
# `**Kind**` / `Kind:`; and the re-read line (Q3) carries no `date` and no
# `delet`. The "as the file directs" half is
# workflow-fragment-archive-backlog-reread.sh.
#
# Static read. The label scan is green on the pre-change fragment, so the
# fixtures are what establish it can fail; the re-read-line scans are red
# until the sentence lands (status 2: no line to read).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

check() {
  local file="$1" line labels problems=""
  labels="$(grep -n -E 'Waits on|Design with|Re-checked|Recorded by|Depends on|\*\*Kind\*\*|(^|[^A-Za-z])Kind:' "$file")"
  [ -z "$labels" ] || problems="$problems
  [field-label] the fragment names an entry field: $labels"
  line="$(grep -i -E 'docs/backlog\.md' "$file" | grep -i -E 're-?read' | grep -i 'archiv')"
  if [ -z "$line" ]; then
    echo "ABSENT: $file has no archive-step line re-reading docs/backlog.md$problems" >&2
    return 2
  fi
  printf '%s\n' "$line" | grep -q -i -E '(^|[^a-z])date' && problems="$problems
  [date-rule] the re-read states a date rule"
  printf '%s\n' "$line" | grep -q -i 'delet' && problems="$problems
  [deletion-ground] the re-read states when an entry is deleted"
  if [ -n "$problems" ]; then
    echo "FAIL: $file$problems" >&2
    return 1
  fi
  return 0
}

# shellcheck disable=SC2016 # backticks are literal markdown in the fixture
reread='- **archive**: before opening that pull request, re-read `docs/backlog.md` for the entries this change completed, made obsolete, unblocked or made stale and update each as the file directs, in the commit that carries the record.'

expect() {  # tag, file
  local out st
  out="$(check "$2" 2>&1)"; st=$?
  if [ "$1" = pass ]; then
    [ "$st" -eq 0 ] && return 0
    echo "FAIL: discriminator — the check rejected the conforming fixture" >&2
  else
    [ "$st" -eq 1 ] && case "$out" in *"[$1]"*) return 0 ;; esac
    echo "FAIL: discriminator — mutant for [$1] not rejected by that scan (status $st)" >&2
  fi
  printf '%s\n' "$out" >&2
  exit 1
}

f="$TESTDIR/conforming.md"
# shellcheck disable=SC2016 # backticks are literal markdown in the fixture
printf '# Workflow\n\nRecord out-of-scope work in `docs/backlog.md`.\n\n%s\n' "$reread" > "$f"
expect pass "$f"
f="$TESTDIR/label.md"; printf '# Workflow\n\nSet the entry'"'"'s **Waits on** to nothing.\n\n%s\n' "$reread" > "$f"; expect field-label "$f"
f="$TESTDIR/kind.md"; printf '# Workflow\n\nAn entry with **Kind** fix is small.\n\n%s\n' "$reread" > "$f"; expect field-label "$f"
f="$TESTDIR/date.md"; printf '# Workflow\n\n%s\n' "${reread%.}, setting today's date on each." > "$f"; expect date-rule "$f"
f="$TESTDIR/delete.md"; printf '# Workflow\n\n%s\n' "${reread%.}, deleting each it completed." > "$f"; expect deletion-ground "$f"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"
check "$fragment"
status=$?
if [ "$status" -eq 2 ]; then
  echo "FAIL: target absent — the archive step carries no backlog re-read yet" >&2
fi
[ "$status" -eq 0 ] || exit 1
