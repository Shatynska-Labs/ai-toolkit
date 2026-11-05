#!/usr/bin/env bash
# Scenario (mechanical half only): Pick meets an untyped condition.
# Requirement: Entries in an older shape are reported, not rewritten.
# Change: report-a-tasks-kind-and-wait (backlog-maintenance, MODIFIED).
#
# SPECIFIED: an entry carrying `waits_for` without `waits_for_type` is read as
# waiting, its type unknown, and not reported as unclassified.
# SPECIFIED (the requirement's body): an entry without `need` reads as the
# README states, `should` in the seeded README, and is not unclassified.
# DERIVED (structure, tasks.md 2.1): read from the section under the heading
# naming "missing" (*Entries missing a key*).
# DERIVED (operationalisation): within one sentence, `waits_for` before
# `waits_for_type` with "untyped" or "wait"; `need` with `should`. Within one
# line (one paragraph), `waits_for_type` with "unclassified".
#
# Not asserted: that pick treats such an entry as waiting. Conduct; verified by
# reading.
#
# Static read (third situation): red until task 2.1 lands; every scan is
# discriminated by a mutant.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime
source "$TESTLIB"

# ---- local arrangement (test-plan.md, Missing shared arrangement: scan machinery)
# Declared here rather than sourced from tests/cases/lib/static-scan.sh, a file
# inside the test-path glob that no convention names as shared arrangement.
#
#   scan MODE REL WHERE TAG REGEX [SPECIMEN]
#     MODE require | forbid; REL a path under the root checked; WHERE "" for the
#     whole file, or a word naming the heading whose section is read; REGEX a
#     lowercase ERE matched per line against the lowercased text, portable
#     between grep -E and awk; SPECIMEN a line a forbid scan's mutant inserts.
# sc_check ROOT: 0 every scan holds, 1 a scan failed ([TAG] on stderr), 2 a
# scanned file or section is absent or empty (the target-absent state).
# sc_discriminate FIXTURE: the fixture passes, and one mutant per scan — a
# require scan's matches blanked, a forbid scan's specimen inserted — is
# rejected by that scan's own [TAG].
SC_MODE=(); SC_REL=(); SC_WHERE=(); SC_TAG=(); SC_RE=(); SC_SPEC=()
scan() { SC_MODE+=("$1"); SC_REL+=("$2"); SC_WHERE+=("$3"); SC_TAG+=("$4"); SC_RE+=("$5"); SC_SPEC+=("${6:-}"); }
sc_section() {
  awk -v w="$2" '
    /^[[:space:]]*(```|~~~)/ { infence = !infence; if (f) print; next }
    !infence && /^#+[[:space:]]/ {
      match($0, /^#+/); lvl = RLENGTH
      if (f && lvl <= start) exit
      if (!f && tolower($0) ~ ("(^|[^a-z-])" w "([^a-z-]|$)")) { f = 1; start = lvl; next }
    }
    f { print }
  ' "$1"
}
sc_text() {
  [ -f "$1/$2" ] || return 0
  if [ -z "$3" ]; then cat "$1/$2"; else sc_section "$1/$2" "$3"; fi
}
sc_check() {
  local root="$1" problems="" i text hits
  for i in "${!SC_TAG[@]}"; do
    text="$(sc_text "$root" "${SC_REL[$i]}" "${SC_WHERE[$i]}")"
    if [ -z "$text" ]; then
      echo "UNREADABLE [${SC_TAG[$i]}]: $root/${SC_REL[$i]}${SC_WHERE[$i]:+ (section ${SC_WHERE[$i]})} is absent or empty" >&2
      return 2
    fi
    hits="$(printf '%s\n' "$text" | tr '[:upper:]' '[:lower:]' | grep -E -- "${SC_RE[$i]}")"
    if [ "${SC_MODE[$i]}" = require ] && [ -z "$hits" ]; then
      problems="$problems
  [${SC_TAG[$i]}] ${SC_REL[$i]}${SC_WHERE[$i]:+ (${SC_WHERE[$i]})} states nothing matching /${SC_RE[$i]}/"
    elif [ "${SC_MODE[$i]}" = forbid ] && [ -n "$hits" ]; then
      problems="$problems
  [${SC_TAG[$i]}] ${SC_REL[$i]}${SC_WHERE[$i]:+ (${SC_WHERE[$i]})} states what it must not: $(printf '%s' "$hits" | head -n 3)"
    fi
  done
  if [ -n "$problems" ]; then echo "FAIL: under $root$problems" >&2; return 1; fi
  return 0
}
sc_mutate() {
  local file="$1" i="$2"
  if [ "${SC_MODE[$i]}" = require ]; then
    awk -v re="${SC_RE[$i]}" '/^#/ || /^---[[:space:]]*$/ { print; next } { l = tolower($0); gsub(re, "redacted", l); print l }' "$file" > "$file.tmp"
  elif [ -z "${SC_WHERE[$i]}" ]; then
    { cat "$file"; printf '%s\n' "${SC_SPEC[$i]}"; } > "$file.tmp"
  else
    awk -v w="${SC_WHERE[$i]}" -v s="${SC_SPEC[$i]}" '{ print } !d && /^#+[[:space:]]/ && tolower($0) ~ ("(^|[^a-z-])" w "([^a-z-]|$)") { print ""; print s; d = 1 }' "$file" > "$file.tmp"
  fi
  mv "$file.tmp" "$file"
}
sc_discriminate() {
  local fixture="$1" i mutant out st
  out="$(sc_check "$fixture" 2>&1)"; st=$?
  [ "$st" -eq 0 ] || { echo "FAIL: discriminator — the check rejects the conforming fixture (status $st)" >&2; printf '%s\n' "$out" >&2; return 1; }
  for i in "${!SC_TAG[@]}"; do
    mutant="$fixture.mutant-$i"
    rm -rf "$mutant"; cp -R "$fixture" "$mutant"
    sc_mutate "$mutant/${SC_REL[$i]}" "$i"
    out="$(sc_check "$mutant" 2>&1)"; st=$?
    [ "$st" -eq 1 ] || { echo "FAIL: discriminator — the mutant for [${SC_TAG[$i]}] returned $st, not 1" >&2; printf '%s\n' "$out" >&2; return 1; }
    case "$out" in *"[${SC_TAG[$i]}]"*) ;; *) echo "FAIL: discriminator — the mutant for [${SC_TAG[$i]}] was rejected by another scan" >&2; printf '%s\n' "$out" >&2; return 1 ;; esac
  done
  return 0
}
# sc_run FIXTURE ROOT: discriminates on the fixture, then holds ROOT to the scans.
sc_run() {
  local st
  sc_discriminate "$1" || exit 1
  sc_check "$2"; st=$?
  [ "$st" -eq 2 ] && { echo "FAIL: target absent — what this case reads does not exist yet" >&2; exit 1; }
  [ "$st" -eq 0 ] || exit 1
  exit 0
}

# ---- the case
S=skills/backlog/SKILL.md
# shellcheck disable=SC2016 # backticks are literal text in a pattern or fixture
{
scan require "$S" missing untyped-wait '`waits_for`[^.]*`waits_for_type`[^.]*(untyped|wait)'
scan require "$S" missing not-unclassified '`waits_for_type`.*unclassified'
scan require "$S" missing need-should '`need`[^.]*`should`'
}
fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog"
cat > "$fixture/$S" <<'FIXTURE'
# backlog

## Entries missing a key

An entry missing `kind` is listed as unclassified. An entry without `need` is `should` by the README; one with `waits_for` and no `waits_for_type` is untyped, a wait as before. Neither is reported as unclassified.

## Pick

Lists takeable entries.
FIXTURE

sc_run "$fixture" "$TOOLKIT_ROOT"
