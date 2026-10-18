#!/usr/bin/env bash
# Scenarios (mechanical half only): An entry completed by an archived change
# is removed with its record; An entry waiting on the archived change is
# marked takeable; The obligation holds where the skill is absent (ADDED
# "Archiving a change re-reads the backlog against it"); An operational skill
# carries procedure, not obligation (MODIFIED "A rule states an action ...",
# fragment half). Change: add-backlog-skill (session-workflow).
#
# SPECIFIED: the archive step directs, before the record's pull request is
# opened, a re-read of `docs/backlog.md` for entries the change completed,
# made obsolete, unblocked or made stale — including entries naming the files
# or specifications it touched, not only entries naming it — each updated as
# the file directs, in the commit that carries the record. The obligation and
# its edge case are stated in the fragment itself, sufficient without a skill.
#
# DERIVED (placement, unresolved question Q3): the fragment is one paragraph
# per line, and the sentence is appended to the archive step (design.md
# decision 3), so it is the line naming `docs/backlog.md`, a re-read, and
# `archive`. DERIVED (wording): `complet`, `obsolete`, `unblocked`, `stale`,
# `touch`, `files`, `specification`, `not only`, `as <the file|it|...>
# directs`, `commit ... record`, `pull request`. DERIVED (operationalisation of
# "holds where the skill is absent"): that line names no backlog skill
# (`backlog skill`, `ai-toolkit:backlog`, `skills/backlog`, `/backlog`).
#
# Static read; red until the sentence lands. The fixtures below establish that
# each scan can fail on the property it names.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Prints problems as [tag]; returns 0, 1, or 2 when no re-read line exists.
check() {
  local file="$1" line problems=""
  line="$(grep -i -E 'docs/backlog\.md' "$file" | grep -i -E 're-?read' | grep -i 'archiv')"
  if [ -z "$line" ]; then
    echo "ABSENT: $file has no archive-step line re-reading docs/backlog.md" >&2
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
  # shellcheck disable=SC2016 # backticks are literal markdown in the pattern
  need as-the-file-directs 'as (the file|it|that file|`?docs/backlog\.md`?) directs'
  need in-the-record-commit 'commit[^.]*record'
  need before-the-pull-request 'pull request'
  if printf '%s\n' "$line" | grep -q -i -E 'backlog skill|ai-toolkit:backlog|skills/backlog|(^|[[:space:]`(])/backlog'; then
    problems="$problems
  [names-skill] the re-read depends on a backlog skill rather than standing alone"
  fi
  if [ -n "$problems" ]; then
    echo "FAIL: $file$problems" >&2
    return 1
  fi
  return 0
}

# shellcheck disable=SC2016 # backticks are literal markdown in the fixture
conforming='- **archive**: open the record'"'"'s pull request. Before opening that pull request, re-read `docs/backlog.md` for the entries this change completed, made obsolete, unblocked or made stale (including entries naming files or specifications it touched, not only entries naming it) and update each as the file directs, in the commit that carries the record.'

fixture="$TESTDIR/fragment.md"
printf '# Workflow\n\n%s\n' "$conforming" > "$fixture"
out="$(check "$fixture" 2>&1)" || {
  echo "FAIL: discriminator — the check rejected the conforming fixture" >&2
  printf '%s\n' "$out" >&2
  exit 1
}

# One mutant per scan: the conforming line with the scanned words removed.
mutate_and_expect() {
  local tag="$1" sedexpr="$2" st
  printf '# Workflow\n\n%s\n' "$conforming" | sed -E "$sedexpr" > "$TESTDIR/mutant.md"
  out="$(check "$TESTDIR/mutant.md" 2>&1)"
  st=$?
  if [ "$st" -ne 1 ]; then
    echo "FAIL: discriminator — mutant for [$tag] returned status $st, not 1" >&2
    printf '%s\n' "$out" >&2
    exit 1
  fi
  case "$out" in
    *"[$tag]"*) ;;
    *) echo "FAIL: discriminator — mutant for [$tag] rejected by another scan" >&2
       printf '%s\n' "$out" >&2
       exit 1 ;;
  esac
}
mutate_and_expect completed 's/completed, //'
mutate_and_expect obsolete 's/made obsolete, //'
mutate_and_expect unblocked 's/unblocked or //'
mutate_and_expect stale 's/ or made stale//'
mutate_and_expect touched 's/ it touched//'
mutate_and_expect touched-files 's/files or //; s/ files / /g'
mutate_and_expect touched-specifications 's/ or specifications//'
mutate_and_expect not-only-by-name 's/, not only entries naming it//'
mutate_and_expect as-the-file-directs 's/ as the file directs//'
mutate_and_expect in-the-record-commit 's/, in the commit that carries the record//'
mutate_and_expect before-the-pull-request 's/open the record.s pull request\. Before opening that pull request, //'
mutate_and_expect names-skill 's/\.$/, using the backlog skill./'

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"
check "$fragment"
status=$?
if [ "$status" -eq 2 ]; then
  echo "FAIL: target absent — the archive step carries no backlog re-read yet" >&2
fi
[ "$status" -eq 0 ] || exit 1
