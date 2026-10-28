#!/usr/bin/env bash
# Scenarios (mechanical half only): Entry rules are read from the backlog, not
# the fragment; The fragment defers the update's form to the file; Archiving
# the last step archives the workstream; The fragment defers the workstream
# rules to the README; Derived work is attached by the backlog's rule, not
# the fragment's.
# Requirements: A second change surfacing in a session is recorded in the
# backlog; Archiving a change re-reads the backlog against it; A change
# states the workstream it advances, and archiving re-reads it.
# Change: list-what-a-project-receives (session-workflow, MODIFIED).
#
# SPECIFIED: rules/development-workflow.md defers to docs/backlog/AGENTS.md
# and docs/workstreams/AGENTS.md for the directories' rules — an entry
# updated, a workstream archived, "as ... AGENTS.md directs" — rather than to
# a README.
# DERIVED (task 1.3: every reference to a directory's README is replaced):
# no `docs/backlog/README.md`, `docs/workstreams/README.md`, "its README" or
# "README directs" remains.
# DERIVED (wording): the backlog's file may be named by path or as "its
# AGENTS.md" on a line naming docs/backlog/.
#
# Static read (third situation); every scan is discriminated on a fixture.
# Red until task 1.3 lands (state 1: the fragment names the READMEs).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement: text scans).
# tests/cases/lib/static-scan.sh and line-scan.sh do this for files under a
# root; they are test modules, not a dispatched shared arrangement, so the
# scans are declared here.
#
#   scan_add MODE TAG REGEX [SPECIMEN]
#     MODE require | forbid; REGEX a lowercase ERE matched against the
#     lowercased text, where " && " joins parts that must all match one line;
#     SPECIMEN, forbid only, a line the discriminator appends to trip it.
# scan_text FILE returns 0 (every scan holds), 1 (a scan failed, printed as
# [TAG] on stderr) or 2 (FILE absent or empty: the target-absent state).
# scan_discriminate FIXTURE requires the fixture to pass, then one mutant per
# scan — a require scan's matching lines removed, a forbid scan's specimen
# appended — to be rejected with status 1 and that scan's own [TAG].
SC_MODE=()
SC_TAG=()
SC_RE=()
SC_SPEC=()
scan_add() { SC_MODE+=("$1"); SC_TAG+=("$2"); SC_RE+=("$3"); SC_SPEC+=("${4:-}"); }
scan_hits() {  # FILE REGEX: the lines of FILE matching every part of REGEX
  awk -v re="$2" '
    BEGIN { n = split(re, p, / && /) }
    { l = tolower($0); ok = 1; for (i = 1; i <= n; i++) if (l !~ p[i]) { ok = 0; break }; if (ok) print }
  ' "$1"
}
scan_text() {
  local f="$1" i st=0
  [ -s "$f" ] || return 2
  for i in "${!SC_TAG[@]}"; do
    if [ -n "$(scan_hits "$f" "${SC_RE[$i]}")" ]; then
      [ "${SC_MODE[$i]}" = forbid ] && { echo "[${SC_TAG[$i]}] forbidden text present: $(scan_hits "$f" "${SC_RE[$i]}" | head -n 1)" >&2; st=1; }
    else
      [ "${SC_MODE[$i]}" = require ] && { echo "[${SC_TAG[$i]}] required text absent" >&2; st=1; }
    fi
  done
  return "$st"
}
scan_discriminate() {
  local fx="$1" i m="$TESTDIR/scan-mutant.txt" out st
  if ! scan_text "$fx" 2>/dev/null; then
    echo "FAIL: discriminator — the conforming fixture is rejected:" >&2
    scan_text "$fx"
    exit 1
  fi
  for i in "${!SC_TAG[@]}"; do
    if [ "${SC_MODE[$i]}" = require ]; then
      awk -v re="${SC_RE[$i]}" '
        BEGIN { n = split(re, p, / && /) }
        { l = tolower($0); ok = 1; for (j = 1; j <= n; j++) if (l !~ p[j]) { ok = 0; break }; if (!ok) print }
      ' "$fx" > "$m"
      printf 'filler line\n' >> "$m"
    else
      { cat "$fx"; printf '%s\n' "${SC_SPEC[$i]}"; } > "$m"
    fi
    out="$(scan_text "$m" 2>&1)"
    st=$?
    if [ "$st" -ne 1 ] || ! printf '%s\n' "$out" | grep -q -F "[${SC_TAG[$i]}]"; then
      echo "FAIL: discriminator — scan [${SC_TAG[$i]}] does not reject its mutant (status $st)" >&2
      exit 1
    fi
  done
}
# scan_target FILE LABEL: holds FILE to the scans, failing the case on any.
scan_target() {
  local st
  scan_text "$1"
  st=$?
  [ "$st" -eq 2 ] && { echo "FAIL: target absent — $2 ($1) is absent or empty" >&2; exit 1; }
  [ "$st" -eq 0 ] || { echo "FAIL: $2 ($1) fails the scans above" >&2; exit 1; }
}

scan_add require backlog-agents 'docs/backlog/agents[.]md|docs/backlog/ && its `?agents[.]md'
scan_add require workstreams-agents 'docs/workstreams/agents[.]md'
scan_add require agents-directs 'agents[.]md`?[^.]*direct'
# shellcheck disable=SC2016 # backticks and $ are literal markdown or awk, not expansions
scan_add forbid no-dir-readme 'docs/(backlog|workstreams)/readme' 'Archive it as `docs/workstreams/README.md` directs.'
# shellcheck disable=SC2016 # backticks are literal markdown
scan_add forbid no-its-readme 'its readme|readme`? directs' 'Record it in `docs/backlog/`, as its README directs.'
fx="$TESTDIR/fragment.md"
cat > "$fx" <<'FIXTURE'
- Where it does not: record it in `docs/backlog/`, as its `AGENTS.md` directs.

**archive** — re-read `docs/backlog/` and update each entry as `docs/backlog/AGENTS.md` directs; archive the workstream as `docs/workstreams/AGENTS.md` directs.
FIXTURE
scan_discriminate "$fx"
scan_target "$TOOLKIT_ROOT/rules/development-workflow.md" "rules/development-workflow.md"
