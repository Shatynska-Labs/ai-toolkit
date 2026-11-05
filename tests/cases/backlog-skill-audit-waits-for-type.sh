#!/usr/bin/env bash
# Scenarios (mechanical half only): A condition without a type; A type without
# a condition; Audit leaves need alone.
# Requirement: Audit verifies every entry independently and changes nothing
# without the operator.
# Change: report-a-tasks-kind-and-wait (backlog-maintenance, MODIFIED).
#
# SPECIFIED: for an entry carrying `waits_for`, the agent says whether its
# `waits_for_type` states the kinds of wait the condition holds, proposing them
# where it has none, and reports a `waits_for_type` carried without
# `waits_for`; the merged report lists among the stale facts each condition
# whose type is wrong or missing, with the types proposed, and each
# `waits_for_type` without `waits_for`; audit proposes no `need`.
# DERIVED (placement, as backlog-skill-audit.sh assumes): the brief and the
# report's sections live in skills/backlog/references/audit.md, scanned whole.
# DERIVED (operationalisation), each within one sentence: `waits_for_type` with
# "kind" or "condition"; `waits_for_type` with "none" or "missing" and "propos",
# or "types proposed"; "type" with "wrong"
# or "missing"; `waits_for_type` with "without" or "no" before `waits_for`.
# For need: every line of audit.md naming `need` also says "no", "not" or
# "never", so audit.md may say audit proposes no need, or not name need at all,
# but cannot ask for one.
#
# Not asserted: that an agent proposes `[decision]` for "the operator's choice
# of model", or that the report lists the entries. Conduct; verified by reading.
#
# Static read (third situation): the need check is green while audit.md names
# no need, so it is discriminated on specimens below; the scans are red until
# task 2.2 lands and each is discriminated by a mutant.
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

# need_left_alone FILE: every line naming `need` negates; a line asking for
# one fails.
need_left_alone() {
  local bad
  # shellcheck disable=SC2016 # backticks are literal text
  bad="$(tr '[:upper:]' '[:lower:]' < "$1" | grep -F '`need`' | grep -vE '(^|[^a-z])(no|not|never)([^a-z]|$)')"
  [ -z "$bad" ] || { echo "FAIL: [need-left-alone] $1 asks for a need: $bad" >&2; return 1; }
}

# ---- the case
A=skills/backlog/references/audit.md
# shellcheck disable=SC2016 # backticks are literal text in a pattern or fixture
{
scan require "$A" "" type-states-kinds '`waits_for_type`[^.]*(kind|condition)'
scan require "$A" "" propose-where-none '`waits_for_type`[^.]*(none|missing)[^.]*propos|propos[^.]*`waits_for_type`|types proposed'
scan require "$A" "" stale-type 'type[^.]*(wrong|missing)|(wrong|missing)[^.]*type'
scan require "$A" "" type-without-condition '`waits_for_type`[^.]*(without|no) `waits_for`'
}
fixture="$TESTDIR/fixture"
mkdir -p "$fixture/skills/backlog/references"
cat > "$fixture/$A" <<'FIXTURE'
# Audit brief

- **Waits for**: whether the condition now holds, and whether its `waits_for_type` states the kinds the condition holds; where it has none, propose them. Report a `waits_for_type` with no `waits_for` beside it.
- Audit proposes no `need`: it is the operator's judgement.

## Report

- **Stale facts**: each condition whose type is wrong or missing, with the types proposed.
FIXTURE

# The need check's discriminator: it accepts a negation and an absence, and
# rejects a request.
spec="$TESTDIR/specimen"
mkdir -p "$spec"
cp "$fixture/$A" "$spec/negates.md"
# shellcheck disable=SC2016 # backticks are literal text
grep -v -F '`need`' "$fixture/$A" > "$spec/absent.md"
# shellcheck disable=SC2016 # backticks are literal text
{ cat "$fixture/$A"; echo '- Propose a `need` for an entry missing one.'; } > "$spec/asks.md"
need_left_alone "$spec/negates.md" || { echo "FAIL: discriminator — the need check rejects a negation" >&2; exit 1; }
need_left_alone "$spec/absent.md" || { echo "FAIL: discriminator — the need check rejects an absence" >&2; exit 1; }
if need_left_alone "$spec/asks.md" 2>/dev/null; then echo "FAIL: discriminator — the need check accepts a request for a need" >&2; exit 1; fi
assert_file "$TOOLKIT_ROOT/$A" "the audit brief this case reads"
need_left_alone "$TOOLKIT_ROOT/$A" || exit 1

sc_run "$fixture" "$TOOLKIT_ROOT"
