#!/usr/bin/env bash
# Scenarios (mechanical half only): An entry completed by an archived change
# is removed with its record; An entry waiting on the archived change is
# marked takeable; The fragment defers the update's form to the file; The
# obligation holds where the skill is absent.
# Requirement: Archiving a change re-reads the backlog against it.
# Change: one-file-per-backlog-entry (session-workflow, MODIFIED).
#
# SPECIFIED: the archive step directs, before the record's pull request is
# opened, a re-read of `docs/backlog/` for the entries the change completed,
# made obsolete, unblocked or made stale — including entries naming the files
# or specifications it touched, not only entries naming it — each updated as
# `docs/backlog/README.md` (the backlog's README) directs, in the commit that
# carries the record. It names no entry field, date rule or deletion ground,
# and depends on no backlog skill.
# DERIVED (carried from the superseded workflow-fragment-archive-backlog-
# reread.sh and -archive-reread-names-no-field.sh, path and deferral
# revised): the archive line naming `docs/backlog/` and a re-read carries
# each term below; "as its README directs" is read as `readme ... directs`;
# no field label or frontmatter key anywhere in the fragment; no `date` or
# `delet` on that line; no backlog skill named on it.
#
# Static read (third situation); every scan is discriminated by a mutant. Red
# until task 3.1 lands (state 2: no archive line names docs/backlog/).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

check() {
  local file="$1" line labels problems=""
  labels="$(grep -n -E 'Waits on|Design with|Re-checked|Recorded by|Depends on|\*\*Kind\*\*|(^|[^A-Za-z])Kind:|waits_on|waits_for|design_with|re_checked|recorded_by|parked_until' "$file")"
  [ -z "$labels" ] || problems="$problems
  [field-label] the fragment names an entry field: $labels"
  line="$(grep -i -F 'docs/backlog/' "$file" | grep -i -E 're-?read' | grep -i 'archiv')"
  if [ -z "$line" ]; then
    echo "ABSENT: $file has no archive-step line re-reading docs/backlog/$problems" >&2
    return 2
  fi
  need() {
    printf '%s\n' "$line" | grep -q -i -E -- "$2" || problems="$problems
  [$1] the re-read does not state /$2/"
  }
  need completed 'complet'
  need obsolete 'obsolete'
  need unblocked 'unblocked'
  need stale 'stale'
  need touched 'touch'
  need touched-files 'files'
  need touched-specifications 'specification'
  need not-only-by-name 'not only'
  need as-readme-directs 'readme[^.]*directs'
  need in-the-record-commit 'commit[^.]*record'
  need before-the-pull-request 'pull request'
  printf '%s\n' "$line" | grep -q -i -E 'backlog skill|ai-toolkit:backlog|skills/backlog|(^|[[:space:]`(])/backlog' && problems="$problems
  [names-skill] the re-read depends on a backlog skill rather than standing alone"
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
conforming='**archive** — open the record'"'"'s pull request. Before opening that pull request, re-read `docs/backlog/` for the entries this change completed, made obsolete, unblocked or made stale (including entries naming files or specifications it touched, not only entries naming it) and update each as its README directs, in the commit that carries the record.'

fixture="$TESTDIR/fragment.md"
printf '# Workflow\n\n%s\n' "$conforming" > "$fixture"
out="$(check "$fixture" 2>&1)" || { echo "FAIL: discriminator — the check rejected the conforming fixture" >&2; printf '%s\n' "$out" >&2; exit 1; }

mutate_and_expect() {
  local tag="$1" st
  printf '# Workflow\n\n%s\n' "$2" > "$TESTDIR/mutant.md"
  out="$(check "$TESTDIR/mutant.md" 2>&1)"
  st=$?
  if [ "$st" -ne 1 ]; then echo "FAIL: discriminator — mutant for [$tag] returned status $st, not 1" >&2; printf '%s\n' "$out" >&2; exit 1; fi
  case "$out" in *"[$tag]"*) ;; *) echo "FAIL: discriminator — mutant for [$tag] rejected by another scan" >&2; printf '%s\n' "$out" >&2; exit 1 ;; esac
}
m() { printf '%s\n' "$conforming" | sed -E "$1"; }
mutate_and_expect completed "$(m 's/completed, //')"
mutate_and_expect obsolete "$(m 's/made obsolete, //')"
mutate_and_expect unblocked "$(m 's/unblocked or //')"
mutate_and_expect stale "$(m 's/ or made stale//')"
mutate_and_expect touched "$(m 's/ it touched//')"
mutate_and_expect touched-files "$(m 's/files or //')"
mutate_and_expect touched-specifications "$(m 's/ or specifications//')"
mutate_and_expect not-only-by-name "$(m 's/, not only entries naming it//')"
mutate_and_expect as-readme-directs "$(m 's/as its README directs/as the file says/')"
mutate_and_expect in-the-record-commit "$(m 's/, in the commit that carries the record//')"
mutate_and_expect before-the-pull-request "$(m 's/open the record.s pull request\. Before opening that pull request, //')"
mutate_and_expect names-skill "$(m 's/\.$/, using the backlog skill./')"
mutate_and_expect date-rule "$(m "s/\\.\$/, setting today's date on each./")"
mutate_and_expect deletion-ground "$(m 's/\.$/, deleting each it completed./')"
# shellcheck disable=SC2016 # backticks and $ are literal text in a pattern or fixture
mutate_and_expect field-label "$(printf 'Set the entry'"'"'s `waits_on` to [].\n\n%s' "$conforming")"
mutate_and_expect field-label "$(printf 'An entry with **Kind** fix is small.\n\n%s' "$conforming")"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"
check "$fragment"
status=$?
[ "$status" -eq 2 ] && echo "FAIL: target absent — the archive step carries no re-read of docs/backlog/ yet" >&2
[ "$status" -eq 0 ] || exit 1
