#!/usr/bin/env bash
# Scenarios (mechanical half only): The row names the workstream first; A
# change with no proposal takes its workstream from the plan.
# Requirement: A session reports where its change stands before acting.
# Change: add-workstreams (session-workflow, MODIFIED).
#
# SPECIFIED: the fragment states, beside the row, the source of the first
# cell in order: the open workstream whose steps name the change; else the
# workstream its proposal names; else the workstream its backlog entry names;
# else `none`. A change in plan:explore with no proposal therefore takes its
# workstream from the workstream's steps.
# DERIVED (operationalisation): one paragraph (line) of the fragment carries
# `workstream`, and in that order `step`, `proposal`, `backlog` and `none`.
# DERIVED (placement): "beside the row" is read as anywhere in the fragment;
# the paragraph's position is not asserted.
#
# Not asserted: that a session reads its workstream's file. Conduct.
#
# Static read: red until the sentence lands (status 2: no such paragraph).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

check() {
  local file="$1" lines
  lines="$(tr '[:upper:]' '[:lower:]' < "$file" | grep -E 'workstream' | grep -E 'proposal' | grep -E 'backlog' | grep -E 'none')"
  if [ -z "$lines" ]; then
    echo "ABSENT: $file has no paragraph naming the workstream cell's sources" >&2
    return 2
  fi
  if ! printf '%s\n' "$lines" | grep -q -E 'step.*proposal.*backlog.*none'; then
    echo "FAIL: $file
  [source-order] the workstream cell's sources are not stated in the order steps, proposal, backlog entry, none" >&2
    return 1
  fi
  return 0
}

expect() {  # pass | <tag> | absent, file
  local out st
  out="$(check "$2" 2>&1)"; st=$?
  case "$1" in
    pass) [ "$st" -eq 0 ] && return 0 ;;
    absent) [ "$st" -eq 2 ] && return 0 ;;
    *) [ "$st" -eq 1 ] && case "$out" in *"[$1]"*) return 0 ;; esac ;;
  esac
  echo "FAIL: discriminator — fixture expected $1, check returned status $st" >&2
  printf '%s\n' "$out" >&2
  exit 1
}

# shellcheck disable=SC2016 # backticks are literal markdown in the fixture
src='The first cell is the open workstream whose steps name the change; else the workstream its proposal names; else the workstream its backlog entry names; else `none`.'
f="$TESTDIR/conforming.md"; printf '# Workflow\n\n%s\n' "$src" > "$f"; expect pass "$f"
f="$TESTDIR/reordered.md"
# shellcheck disable=SC2016 # backticks are literal markdown, not expansions
printf '# Workflow\n\n%s\n' 'The first cell is the workstream its backlog entry names; else the workstream its proposal names; else the open workstream whose steps name the change; else `none`.' > "$f"; expect source-order "$f"
f="$TESTDIR/absent.md"; printf '# Workflow\n\nReport the row.\n' > "$f"; expect absent "$f"

fragment="$TOOLKIT_ROOT/rules/development-workflow.md"
assert_file "$fragment" "the fragment this case reads"
check "$fragment"
status=$?
if [ "$status" -eq 2 ]; then
  echo "FAIL: target absent — the fragment states no source order for the workstream cell yet" >&2
fi
[ "$status" -eq 0 ] || exit 1
