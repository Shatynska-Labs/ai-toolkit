#!/usr/bin/env bash
# Scenario: An unrun check is not reported as passing.
# Requirement: A pull request's description carries what changed, why, what
# else, and what was verified.
# Change: describe-commits-and-pull-requests (commit-and-pull-request-practice,
# ADDED). Written by change-test-writer; see that change's test-plan.md.
#
# Read over the skill's text (SKILL.md's body and references/).
#   [not-run-stated]      SPECIFIED  a check not run is stated as not run,
#                                    with the reason ("not run" with
#                                    reason/why/because, DERIVED proxy)
#   [not-run-not-passing] SPECIFIED  and never listed as passing (not
#                                    run/never run/unrun with pass and a
#                                    never/rather than/instead of, DERIVED)
#
# Not asserted: that a session's description does so. Conduct.
#
# Static read (third situation). Red at authoring: the skill does not exist
# yet (target absent). Every scan is discriminated by a mutant of the
# conforming fixture below.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# --- Local arrangement, declared in this file on purpose -------------------
# A line scanner over a text, with a fixture-driven discriminator. The shared
# arrangement (tests/lib.sh) holds no scanner that can be run over a fixture
# and observed to fail without ending the case. Similar machinery lives in
# tests/cases/lib/line-scan.sh and tests/cases/lib/static-scan.sh, which are
# test modules, not shared arrangement, so neither is sourced. Recorded under
# "Missing shared arrangement" in describe-commits-and-pull-requests's
# test-plan.md.
#
#   req    TAG SEL PAT...         some line selected by SEL matches every PAT
#   forbid TAG SEL SAMPLE PAT...  no line selected by SEL matches every PAT;
#                                 SAMPLE is a line that must trip it
# SEL and PAT are ERE, matched case-insensitively; an empty SEL selects all.
SC_KIND=()
SC_TAG=()
SC_SEL=()
SC_SAMPLE=()
SC_PATS=()

req() {
  local IFS=$'\n'
  SC_KIND+=(require); SC_TAG+=("$1"); SC_SEL+=("$2"); SC_SAMPLE+=("")
  shift 2
  SC_PATS+=("$*")
}

forbid() {
  local IFS=$'\n'
  SC_KIND+=(forbid); SC_TAG+=("$1"); SC_SEL+=("$2"); SC_SAMPLE+=("$3")
  shift 3
  SC_PATS+=("$*")
}

# Prints the lines of TEXT selected by SEL that match every pattern in PATS.
sc_hits() {
  local out pat
  out="$(printf '%s\n' "$1" | grep -iE -- "${2:-.}")" || return 1
  while IFS= read -r pat; do
    [ -n "$pat" ] || continue
    out="$(printf '%s\n' "$out" | grep -iE -- "$pat")" || return 1
  done <<<"$3"
  printf '%s\n' "$out"
}

# 0 every scan holds; 1 otherwise, printing each failed scan as [TAG].
sc_check() {
  local text="$1" i bad=""
  for i in "${!SC_TAG[@]}"; do
    if sc_hits "$text" "${SC_SEL[$i]}" "${SC_PATS[$i]}" >/dev/null; then
      [ "${SC_KIND[$i]}" = forbid ] && bad="$bad [${SC_TAG[$i]}]"
    else
      [ "${SC_KIND[$i]}" = require ] && bad="$bad [${SC_TAG[$i]}]"
    fi
  done
  [ -z "$bad" ] && return 0
  printf '%s\n' "$bad"
  return 1
}

# The conforming TEXT must pass; for each require scan, TEXT without the
# lines that satisfy it must fail by that tag; for each forbid scan, TEXT
# plus its SAMPLE must fail by that tag.
sc_discriminate() {
  local text="$1" i mutant matched out
  if ! out="$(sc_check "$text")"; then
    echo "FAIL: discriminator — the conforming fixture was rejected:$out" >&2
    exit 1
  fi
  for i in "${!SC_TAG[@]}"; do
    if [ "${SC_KIND[$i]}" = require ]; then
      matched="$(sc_hits "$text" "${SC_SEL[$i]}" "${SC_PATS[$i]}")"
      mutant="$(printf '%s\n' "$text" | grep -vxF -f <(printf '%s\n' "$matched"))"
    else
      mutant="$text"$'\n'"${SC_SAMPLE[$i]}"
    fi
    if out="$(sc_check "$mutant")"; then
      echo "FAIL: discriminator — the mutant for [${SC_TAG[$i]}] passed" >&2
      exit 1
    fi
    case "$out" in
      *"[${SC_TAG[$i]}]"*) ;;
      *) echo "FAIL: discriminator — the mutant for [${SC_TAG[$i]}] was rejected, but not by that scan:$out" >&2; exit 1 ;;
    esac
  done
}

# Runs the scans over the real TEXT read from WHAT; never prints its content.
sc_run() {
  local text="$1" what="$2" out
  if [ -z "$text" ]; then
    echo "FAIL: target absent — $what does not exist yet or is empty" >&2
    exit 1
  fi
  if ! out="$(sc_check "$text")"; then
    echo "FAIL: $what:$out" >&2
    exit 1
  fi
}

# Prints FILE without its leading YAML frontmatter.
sc_body() {
  awk 'NR == 1 && /^---[[:space:]]*$/ { fm = 1; next }
       fm && /^---[[:space:]]*$/ { fm = 0; next }
       !fm' "$1"
}

# Prints the commits-and-pull-requests skill's text under ROOT: SKILL.md's
# body, then every file under its references/. Nothing where SKILL.md is
# absent.
skill_text() {
  local dir="$1/skills/commits-and-pull-requests" f
  [ -s "$dir/SKILL.md" ] || return 0
  sc_body "$dir/SKILL.md"
  for f in "$dir"/references/*.md; do
    [ -f "$f" ] && cat -- "$f"
  done
  return 0
}
# --- end of local arrangement ----------------------------------------------

req not-run-stated '' 'not run' '(reason|why|because)'
req not-run-not-passing '' '(not run|never run|unrun)' 'pass' '(never|rather than|instead of)'

sc_discriminate "## Verification

A check that was not run is stated as not run, with the reason, and never listed as passing."

sc_run "$(skill_text "$TOOLKIT_ROOT")" "skills/commits-and-pull-requests"
