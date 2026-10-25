#!/usr/bin/env bash
# Scenario (mechanical half only): Derived work is attached by the backlog's
# rule, not the fragment's.
# Requirement: A change states the workstream it advances, and archiving
# re-reads it. Change: one-file-per-backlog-entry (session-workflow,
# MODIFIED).
#
# SPECIFIED: where the fragment routes an identified change to
# `docs/backlog/`, it states nothing about which workstream the entry takes.
# DERIVED (carried from the superseded workflow-fragment-backlog-routing-
# names-no-workstream.sh, path revised): the lines naming `docs/backlog/` and
# `record`, other than the archive re-read, do not name a workstream.
#
# Static read (third situation); checked on a conforming and a violating
# fixture first. Red until task 3.1 lands (state 2: no routing line names
# docs/backlog/).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

check() {
  local file="$1" lines hits
  lines="$(grep -i -F 'docs/backlog/' "$file" | grep -i -E 'record' | grep -v -i -E 're-?read')"
  if [ -z "$lines" ]; then
    echo "ABSENT: $file has no paragraph routing work to docs/backlog/" >&2
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
# shellcheck disable=SC2016 # backticks are literal markdown in the fixture
printf '# Workflow\n\n- Where it does not: record it in `docs/backlog/`, as its README directs.\n\nWhere the change advanced a workstream, re-read `docs/backlog/` and the workstream.\n' > "$f"
expect pass "$f"
f="$TESTDIR/violating.md"
# shellcheck disable=SC2016
printf '# Workflow\n\n- Where it does not: record it in `docs/backlog/`, giving the entry this change'"'"'s workstream.\n' > "$f"
expect routing-names-workstream "$f"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"
check "$fragment"
status=$?
[ "$status" -eq 2 ] && echo "FAIL: target absent — the fragment carries no routing line naming docs/backlog/" >&2
[ "$status" -eq 0 ] || exit 1
