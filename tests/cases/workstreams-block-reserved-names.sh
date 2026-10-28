#!/usr/bin/env bash
# Scenario: A project without a workstream register receives the seeded file
# — the statement this change adds.
# Requirement: A workstream register is seeded where none exists.
# Change: list-what-a-project-receives (project-bootstrap, MODIFIED).
#
# SPECIFIED: the block states that `readme`, `agents` and `claude`, in any
# case, are not workstream names, for the same collision; and it speaks of
# itself as "this file", not as a README ("this file is kept when there is no
# workstream").
# DERIVED (wording): each statement is read by the tolerant pattern below.
#
# Reads the block a run writes (third situation); every scan is
# discriminated on a fixture first. Red until task 1.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement: block readers).
# block_body FILE NAME: the lines strictly between NAME's opening and closing
# markers, each with its newline.
block_body() {
  awk -v n="$2" '
    index($0, "<!-- /ai-toolkit:" n " -->") == 1 { exit }
    f { print }
    index($0, "<!-- ai-toolkit:" n " ") == 1 { f = 1 }
  ' "$1"
}
# marker_line FILE NAME: NAME's opening line in the form
# `<!-- ai-toolkit:NAME MAJOR.MINOR.PATCH sha256:<64 hex> -->`, or nothing.
marker_line() {
  grep -E "^<!-- ai-toolkit:$2 [0-9]+[.][0-9]+[.][0-9]+ sha256:[0-9a-f]{64} -->\$" "$1" 2>/dev/null
}

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

scan_add require reserved-names 'readme && agents && claude && workstream name'
scan_add require any-case 'in any case|any capitali[sz]ation|case-insensitive'
scan_add forbid not-a-readme 'this readme' 'Keep this README when there is no workstream.'
fx="$TESTDIR/fixture.md"
cat > "$fx" <<'FIXTURE'
`readme`, `agents` and `claude`, in any case, are not workstream names, for the same collision.
Keep this file when there is no workstream.
FIXTURE
scan_discriminate "$fx"

work="$TESTDIR/work"
mkdir -p "$work"
(cd "$work" && bash "$PROJECT_INIT") >"$TESTDIR/report.txt" 2>&1
block_body "$work/docs/workstreams/AGENTS.md" workstreams > "$TESTDIR/block.md" 2>/dev/null
scan_target "$TESTDIR/block.md" "the workstreams block"
