#!/usr/bin/env bash
# Scenario (mechanical half only): Record refuses a name colliding with the
# rules' files.
# Requirement: Record writes an entry the file can be relied on for.
# Change: list-what-a-project-receives (backlog-maintenance, MODIFIED).
#
# SPECIFIED: record's name check refuses `readme`, `agents` and `claude` in
# any case, which would collide with README.md, AGENTS.md or CLAUDE.md on a
# filesystem that ignores case.
# DERIVED (structure, as backlog-skill-dir-record-file.sh): read from the
# section under the heading naming `record`; `agents` and `claude` as words
# not followed by `.md`, so a mention of the files alone does not satisfy it.
# NOT ASSERTED: that no file is written and another name asked for — conduct.
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

# Local arrangement (test-plan.md, Missing shared arrangement: md_section).
# md_section FILE WORD: the section under the first heading naming WORD, up
# to the next heading of the same or a higher level; fenced code is not a
# heading.
md_section() {
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

scan_add require names-three 'readme && (^|[^a-z])agents([^.a-z]|$) && (^|[^a-z])claude([^.a-z]|$)'
scan_add require any-case 'any case|ignores case|case-insensitive'
fx="$TESTDIR/fixture.md"
cat > "$fx" <<'FIXTURE'
Never use `readme`, `agents` or `claude`, in any case: their files would collide with `README.md`, `AGENTS.md` or `CLAUDE.md`.
FIXTURE
scan_discriminate "$fx"
skill="$TOOLKIT_ROOT/skills/backlog/SKILL.md"
assert_file "$skill" "the skill this case reads"
md_section "$skill" record > "$TESTDIR/record.md"
scan_target "$TESTDIR/record.md" "the record section of skills/backlog/SKILL.md"
