#!/usr/bin/env bash
# Scenario (mechanical half only): A handoff is not left uncommitted on a
# branch the session leaves.
# Requirement: A second change surfacing in a session is recorded in the
# backlog. Change: reconcile-commit-rule-with-spec (session-workflow,
# MODIFIED).
#
# SPECIFIED: "The fragment SHALL direct committing that branch as soon as it
# is opened." and "The commit is made, not proposed, so the fragment states no
# path for a declined one."
# DERIVED (lexical proxies, unresolved question Q1 in test-plan.md): the rule
# is read from the fragment's lines naming a handoff (the fragment keeps one
# paragraph per line); "commit that/the/this/its branch" is the direction,
# "at once", "immediately" or "as soon as" its timing; "propose(s|d) a commit"
# and "declin"/"unsaved" mark the superseded proposed-and-declined form.
#
# Not asserted: that a session does commit the branch.
#
# Static read (third situation): the fragment already carries the rule
# (design.md, Context), so green at authoring; every scan is discriminated by
# a mutant of the conforming fixture below. A failing scan reports its tag
# only, never the fragment's text.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

F=rules/development-workflow.md
SELECT='handoff'

# Local arrangement (see test-plan.md, Missing shared arrangement): a scan over
# the lines a selector picks, fenced code skipped, lowercased.
MODES=() TAGS=() RES=() SPECS=()
lscan() { MODES+=("$1"); TAGS+=("$2"); RES+=("$3"); SPECS+=("${4:-}"); }

lselect() {
  awk -v sel="$SELECT" '
    /^[[:space:]]*(```|~~~)/ { infence = !infence; next }
    infence { next }
    { l = tolower($0); if (l ~ sel) print l }
  ' "$1"
}

lcheck() {
  local file="$1/$F" lines i problems=""
  [ -s "$file" ] || { echo "UNREADABLE: $file is absent or empty" >&2; return 2; }
  lines="$(lselect "$file")"
  [ -n "$lines" ] || { echo "UNREADABLE: no line of $file matches /$SELECT/" >&2; return 2; }
  for i in "${!TAGS[@]}"; do
    if printf '%s\n' "$lines" | grep -qE -- "${RES[$i]}"; then
      [ "${MODES[$i]}" = forbid ] && problems="$problems [${TAGS[$i]}]"
    else
      [ "${MODES[$i]}" = require ] && problems="$problems [${TAGS[$i]}]"
    fi
  done
  [ -z "$problems" ] && return 0
  echo "FAIL: $file:$problems" >&2
  return 1
}

ldiscriminate() {
  local fixture="$1" i mutant out status
  out="$(lcheck "$fixture" 2>&1)"; status=$?
  [ "$status" -eq 0 ] || { echo "FAIL: discriminator — conforming fixture rejected (status $status): $out" >&2; exit 1; }
  for i in "${!TAGS[@]}"; do
    mutant="$TESTDIR/mutant-$i"
    mkdir -p "$mutant/rules"
    if [ "${MODES[$i]}" = require ]; then
      awk -v re="${RES[$i]}" '{ l = tolower($0); gsub(re, "redacted", l); print l }' "$fixture/$F" > "$mutant/$F"
    else
      { cat "$fixture/$F"; printf '%s\n' "${SPECS[$i]}"; } > "$mutant/$F"
    fi
    out="$(lcheck "$mutant" 2>&1)"; status=$?
    [ "$status" -eq 1 ] || { echo "FAIL: discriminator — mutant for [${TAGS[$i]}] returned status $status, not 1: $out" >&2; exit 1; }
    case "$out" in *"[${TAGS[$i]}]"*) ;; *) echo "FAIL: discriminator — mutant for [${TAGS[$i]}] rejected by another scan: $out" >&2; exit 1 ;; esac
  done
}

lscan require commit-branch 'commit (that|the|this|its) (handoff |new )?branch'
lscan require at-once '(at once|immediately|as soon as)'
# shellcheck disable=SC2016 # the backticks are literal markdown, not a command substitution
lscan forbid no-proposed-commit 'propos(e|es|ed|ing) (a )?commit' \
  'Propose a commit on that branch as soon as it is opened, carrying its `handoff.md`.'
# shellcheck disable=SC2016 # the backticks are literal markdown, not a command substitution
lscan forbid no-declined-path '(declin|unsaved)' \
  'Where that commit is declined, report that the `handoff.md` is unsaved and stop.'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/rules"
cat > "$fixture/$F" <<'FIXTURE'
# Workflow

- Where it **does not**: record it in `docs/backlog/`, or open it on a branch of its own carrying a `handoff.md` and no proposal. Commit that branch at once: you are not returning to it, so no later commit carries the handoff.
FIXTURE

ldiscriminate "$fixture"

lcheck "$TOOLKIT_ROOT"
status=$?
[ "$status" -eq 2 ] && { echo "FAIL: target absent — what this case reads does not exist" >&2; exit 1; }
exit "$status"
