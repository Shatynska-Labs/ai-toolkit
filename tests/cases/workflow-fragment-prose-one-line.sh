#!/usr/bin/env bash
# Scenario (mechanical half only): A session writing prose keeps a paragraph
# on one line.
# Requirement: Fragment prose is not hard-wrapped.
# Change: reconcile-commit-rule-with-spec (session-workflow, ADDED).
#
# SPECIFIED: the fragment directs that Markdown prose is not hard-wrapped, each
# paragraph kept on a single line ("the fragment has told it so").
# DERIVED (lexical proxies, Q1 in test-plan.md): the rule is read from the
# fragment's lines naming Markdown prose or hard-wrapping; a negation ("not", "never", "no",
# "don't", "do not") before "hard-wrap" is the direction, "single line" or
# "one line" the paragraph's form.
#
# Not asserted: that a session keeps its paragraphs on one line; that the
# direction is phrased as an imperative (no lexical test separates "do not
# hard-wrap" from "prose is not hard-wrapped" reliably).
#
# Static read (third situation): the fragment already carries the rule
# (design.md, Context), so green at authoring; every scan is discriminated by
# a mutant of the conforming fixture below. A failing scan reports its tag
# only, never the fragment's text.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

F=rules/development-workflow.md
SELECT='markdown prose|hard[- ]?wrap'

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

lscan require negated '(not|never|no|don.t) (be )?hard[- ]?wrap'
lscan require one-line '(single|one) line'

fixture="$TESTDIR/fixture"
mkdir -p "$fixture/rules"
cat > "$fixture/$F" <<'FIXTURE'
# Workflow

## Throughout

**Markdown prose.** Do not hard-wrap Markdown prose: keep each paragraph on a single line whatever its length, and break a line only where Markdown's own structure requires one.
FIXTURE

ldiscriminate "$fixture"

lcheck "$TOOLKIT_ROOT"
status=$?
[ "$status" -eq 2 ] && { echo "FAIL: target absent — what this case reads does not exist" >&2; exit 1; }
exit "$status"
