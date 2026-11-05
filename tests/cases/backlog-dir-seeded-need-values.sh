#!/usr/bin/env bash
# Scenario: Need's values and default are stated
# Requirement: The backlog's rules are written where none exist
# Change: report-a-tasks-kind-and-wait (project-bootstrap, MODIFIED).
#
# SPECIFIED: the seeded block states need's three values must, should and
# could, each measured against the Goal of the entry's workstream or, naming
# none, against the project, and that an entry without the key is should.
# SPECIFIED (the requirement's body): Need is among the body's reasons, on a
# must or could entry only.
# DERIVED (operationalisation), each within one sentence of one line: the three
# values backticked in that order; `need` with "goal"; `need` or "naming no
# workstream" with "project"; "without" with `need` and `should`; **Need**
# with `must` or `could`.
#
# Executes project-init, then reads the block it seeds (third situation for the
# assertions): every scan is discriminated on a fixture. Red until task 1.1.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime
source "$TESTLIB"

R=docs/backlog/AGENTS.md

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
# shellcheck disable=SC2016 # backticks are literal text in a pattern or fixture
{
scan require "$R" "" three-values '`must`[^.]*`should`[^.]*`could`'
scan require "$R" "" against-goal '`need`[^.]*goal|goal[^.]*`need`'
scan require "$R" "" against-project '(no workstream|naming none|names none)[^.]*project'
scan require "$R" "" absent-should 'without[^.]*`need`[^.]*`should`'
scan require "$R" "" need-reason '[*][*]need[*][*][^.]*(`must`|`could`)'
}
mkdir -p "$TESTDIR/fixture/docs/backlog"
cat > "$TESTDIR/fixture/$R" <<'FIXTURE'
# Backlog

- `need`, `must`, `should` or `could`, measured against the Goal of the entry's workstream; for an entry naming no workstream, against the project.
- An entry without `need` is `should`.
- **Need**, on a `must` or `could` entry only, why.
FIXTURE

work="$TESTDIR/work"
mkdir -p "$work"
(cd "$work" && bash "$PROJECT_INIT") > "$TESTDIR/report.txt" 2>&1
sc_run "$TESTDIR/fixture" "$work"
