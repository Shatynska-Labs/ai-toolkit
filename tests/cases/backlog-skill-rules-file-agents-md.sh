#!/usr/bin/env bash
# Scenarios (mechanical half only): A project on the rules' earlier README;
# No backlog exists; No workstream register exists; A project's preamble
# differs from the seeded one; A project's workstream README differs from the
# seeded one.
# Requirements: The skill operates on the project it is invoked in; The
# skill restates neither the entry rules nor the workflow's obligations.
# Change: list-what-a-project-receives (backlog-maintenance, MODIFIED).
#
# SPECIFIED: skills/backlog/SKILL.md reads a directory's rules from its
# AGENTS.md — docs/backlog/AGENTS.md and docs/workstreams/AGENTS.md — and
# from its README.md where AGENTS.md holds no block; it counts neither
# AGENTS.md, CLAUDE.md nor README.md as an entry; where the rules file is
# absent it names project-init.
# DERIVED (task 3.2): the description no longer says "seeding either README".
# DERIVED (wording): each statement is read by the tolerant pattern below.
# NOT ASSERTED: that the skill writes no rules file and performs the
# operation on a README project — conduct, not text.
#
# Static read (third situation); every scan is discriminated on a fixture.
# Red until task 3.2 lands.
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

scan_add require backlog-agents 'docs/backlog/agents[.]md'
scan_add require workstreams-agents 'docs/workstreams/agents[.]md'
scan_add require readme-fallback 'readme[.]md && (no (managed )?block|holds none|holds no|fall(s|ing)? ?back|where it holds)'
scan_add require not-entries 'agents[.]md && claude[.]md && readme[.]md && entr'
scan_add require absent-names-project-init 'project-init && (absent|missing|neither|not exist|no rules)'
scan_add forbid no-seeding-readme 'seeding either readme' 'Not for seeding either README (project-init).'
fx="$TESTDIR/SKILL.md"
cat > "$fx" <<'FIXTURE'
---
description: Not for writing either directory's rules (project-init).
---
Read the entry rules from `docs/backlog/AGENTS.md`, and the workstream rules from `docs/workstreams/AGENTS.md`.
Where that file holds no block, read the directory's `README.md` instead, the shape before 1.0.0.
Count neither `AGENTS.md`, `CLAUDE.md` nor `README.md` as an entry.
Where the directory holds no rules file, say so: `project-init` writes it.
FIXTURE
scan_discriminate "$fx"
scan_target "$TOOLKIT_ROOT/skills/backlog/SKILL.md" "skills/backlog/SKILL.md"
