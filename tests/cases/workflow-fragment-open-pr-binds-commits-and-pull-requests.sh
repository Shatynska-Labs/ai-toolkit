#!/usr/bin/env bash
# Scenario: The binding names a shipped skill.
# Requirement: Writing a pull request is bound to a skill, not stated in the
# fragment.
# Change: describe-commits-and-pull-requests (session-workflow, ADDED).
# Written by change-test-writer; see that change's test-plan.md.
#
# Read over rules/development-workflow.md's body, from the first line naming
# `open pr` onward (DERIVED anchor: the case's author did not read the
# fragment, so "under open pr" is read as "after the first mention of open
# pr", which is weaker than the step's own scope and is recorded as such).
#   [binding]                  SPECIFIED  a Claude Code binding naming
#                                         ai-toolkit:commits-and-pull-requests
#   [binding-title-description] SPECIFIED as what writes a pull request's
#                                         title and description (one line)
#   [shipped]                  SPECIFIED  the library ships
#                                         skills/commits-and-pull-requests/
#                                         SKILL.md (assert_file; that every
#                                         ai-toolkit: name resolves is also
#                                         checked, with its own discriminators,
#                                         by workflow-fragment-names-shipped-
#                                         assets)
#
# Static read (third situation). Red at authoring on [binding] (state 1 on
# real content) and on [shipped] (target absent). Every scan is discriminated
# by a mutant of the conforming fixture below.
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

# Prints FILE's body from the first line naming open pr onward.
from_open_pr() {
  sc_body "$1" | awk 'f { print; next } tolower($0) ~ /open pr/ { f = 1; print }'
}

req binding '' 'claude code binding' 'ai-toolkit:commits-and-pull-requests'
req binding-title-description '' 'ai-toolkit:commits-and-pull-requests' 'title' 'description'

fixture="$TESTDIR/development-workflow.md"
cat > "$fixture" <<'FIXTURE'
---
kind: standing-constraint
version: 13
---
_Claude Code binding:_ a binding before the step, naming `ai-toolkit:commits-and-pull-requests` for a title and description, which must not count.

**ship** — `open pr`, then merge.

_Claude Code binding:_ write the pull request's title and description with `ai-toolkit:commits-and-pull-requests`.
FIXTURE
sc_discriminate "$(from_open_pr "$fixture")"

# The anchor itself: a binding only before open pr is not read.
# shellcheck disable=SC2016 # the backticks are literal markdown in the fixture, not an expansion
early="$(head -n 5 "$fixture"; echo 'Nothing here.'; echo '**ship** — `open pr`, then merge.')"
printf '%s\n' "$early" > "$TESTDIR/early.md"
if sc_check "$(from_open_pr "$TESTDIR/early.md")" >/dev/null; then
  echo "FAIL: discriminator — a binding stated only before open pr was accepted" >&2
  exit 1
fi

assert_file "$TOOLKIT_ROOT/rules/development-workflow.md" "the workflow fragment"
sc_run "$(from_open_pr "$TOOLKIT_ROOT/rules/development-workflow.md")" "rules/development-workflow.md (from open pr)"
assert_file "$TOOLKIT_ROOT/skills/commits-and-pull-requests/SKILL.md" "[shipped] the bound skill is shipped"
