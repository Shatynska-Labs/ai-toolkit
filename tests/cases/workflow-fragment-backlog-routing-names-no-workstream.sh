#!/usr/bin/env bash
# Scenario (mechanical half only): Derived work is attached by the backlog's
# rule, not the fragment's.
# Requirement: A change states the workstream it advances, and archiving
# re-reads it. Change: add-workstreams (session-workflow, ADDED).
#
# SPECIFIED: where the fragment routes an identified change to
# `docs/backlog.md`, it states nothing about which workstream the entry
# takes.
# DERIVED (operationalisation): the routing paragraphs are the lines naming
# `docs/backlog.md` and `record`, other than the archive re-read (a line also
# carrying `re-read`/`reread`, which the archive insertion may share with the
# workstream re-read); none of them names `workstream`. The half that the
# file gives the entry its workstream is backlog-seeded-workstream-default-none.sh.
#
# Static read: green on the pre-change fragment, which names no workstream at
# all, so the fixtures below are what establish the check can fail.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

check() {
  local file="$1" lines hits
  lines="$(grep -i -F 'docs/backlog.md' "$file" | grep -i -E 'record' | grep -v -i -E 're-?read')"
  if [ -z "$lines" ]; then
    echo "ABSENT: $file has no paragraph routing work to docs/backlog.md" >&2
    return 2
  fi
  hits="$(printf '%s\n' "$lines" | grep -i 'workstream')"
  if [ -n "$hits" ]; then
    echo "FAIL: $file
  [routing-names-workstream] the backlog routing states which workstream an entry takes: $hits" >&2
    return 1
  fi
  return 0
}

expect() {  # pass | <tag>, file
  local out st
  out="$(check "$2" 2>&1)"; st=$?
  if [ "$1" = pass ]; then
    [ "$st" -eq 0 ] && return 0
  else
    [ "$st" -eq 1 ] && case "$out" in *"[$1]"*) return 0 ;; esac
  fi
  echo "FAIL: discriminator — fixture expected $1, check returned status $st" >&2
  printf '%s\n' "$out" >&2
  exit 1
}

f="$TESTDIR/conforming.md"
# shellcheck disable=SC2016 # backticks are literal markdown, not expansions
printf '# Workflow\n\n- Where it does not: record it in `docs/backlog.md`, as the file directs.\n\nWhere the change advanced a workstream, re-read `docs/backlog.md` and the workstream.\n' > "$f"
expect pass "$f"
f="$TESTDIR/violating.md"
# shellcheck disable=SC2016 # backticks are literal markdown, not expansions
printf '# Workflow\n\n- Where it does not: record it in `docs/backlog.md`, giving the entry this change'"'"'s workstream.\n' > "$f"
expect routing-names-workstream "$f"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"
check "$fragment"
status=$?
if [ "$status" -eq 2 ]; then
  echo "FAIL: the fragment carries no backlog routing paragraph for this case to read" >&2
fi
[ "$status" -eq 0 ] || exit 1
