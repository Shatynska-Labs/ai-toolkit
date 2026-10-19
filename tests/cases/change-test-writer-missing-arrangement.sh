#!/usr/bin/env bash
# hand-missing-test-arrangement-to-apply, change-test-authoring scenarios
# (mechanical half only): Missing arrangement is declared locally and
# recorded; A near-miss is recorded, not extended; Arrangement found in an
# earlier test module is not imported; Two test files written by one pass do
# not share arrangement by import; An absent shared arrangement does not
# block; A shared double is read without following it to the port; A local
# declaration is listed with everything promotion needs; Nothing missing is
# stated, not omitted.
#
# Each scenario is the writer's conduct, verified by create-agent's cold-run
# check (tasks 1.5, 5.1). What a case can reach is that the contract in
# agents/change-test-writer.md states what the conduct needs:
#   [section-named]  SPECIFIED  the manifest section is named **Missing shared
#                               arrangement** — read from the section headed
#                               "The manifest", the heading tasks 1.4 names
#   [near-miss]      SPECIFIED  that section's entry records a **near-miss**
#   [no-import]      SPECIFIED  a line names the **test module** term and import
#   [dispatch-input] SPECIFIED  the dispatch contract names the shared arrangement
#   [read-bound]     SPECIFIED  the read bound admits the shared arrangement
#   [no-port-read]   SPECIFIED  the read bound states the double/port rule
#   [additive-kept]  DERIVED    from design.md's goal that the additive-only
#                               guarantee is unchanged: the property dispatchers
#                               rely on is still stated verbatim
#
# Section anchors ("The manifest", "dispatch contract", "What you may read")
# are DERIVED: they are the headings tasks 1.1-1.4 name, not ones the spec fixes.
# A scan matching on one line, where the spec sets no single sentence, is a
# DERIVED reading of the repository's one-paragraph-per-line convention.
#
# Not asserted: the other entry fields (stands in for, tests using it, where
# found, proposed home), the "nothing declared locally" and "no shared
# arrangement named" statements, and when the unresolved project question is
# raised. None has a token the spec fixes; verified by the cold-run check.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# --- Local arrangement, declared in this file on purpose -------------------
# A line-co-occurrence scanner and its discriminator. The shared test
# arrangement (tests/lib.sh) holds no scanner that can be run over a fixture
# and observed to fail without ending the case — `assert_contains` exits on
# failure, matches one fixed string, and reads a whole file. Similar machinery
# exists in tests/cases/lib/static-scan.sh, which is a test module rather than
# shared arrangement, so it is not sourced. Recorded under "Missing shared
# arrangement" in hand-missing-test-arrangement-to-apply's test-plan.md.
#
#   require_line TAG REL WHERE PATTERN...
#     REL      path relative to the root being checked
#     WHERE    ""     the whole file
#              @body  the file after its frontmatter
#              @after:<ere>  the lines after the first line whose lowercased
#                     text matches <ere>, to the end of the file
#              <ere>  the section under the first heading whose lowercased
#                     text matches <ere>, up to the next heading of the same
#                     or a higher level (fenced code is not a heading)
#     PATTERN  lowercase ERE, portable between grep -E and awk; every pattern
#              must match one and the same line of the region
SCAN_TAG=()
SCAN_REL=()
SCAN_WHERE=()
SCAN_PATS=()

require_line() {
  local tag="$1" rel="$2" where="$3" IFS=$'\n'
  shift 3
  SCAN_TAG+=("$tag")
  SCAN_REL+=("$rel")
  SCAN_WHERE+=("$where")
  SCAN_PATS+=("$*")
}

region_of() {
  local file="$1" where="$2"
  case "$where" in
    "") cat -- "$file" ;;
    @body)
      awk 'NR == 1 && /^---[[:space:]]*$/ { fm = 1; next }
           fm && /^---[[:space:]]*$/ { fm = 0; next }
           !fm' "$file" ;;
    @after:*)
      awk -v re="${where#@after:}" 'f { print } !f && tolower($0) ~ re { f = 1 }' "$file" ;;
    *)
      awk -v re="$where" '
        /^[[:space:]]*(```|~~~)/ { infence = !infence; if (f) print; next }
        !infence && /^#+[[:space:]]/ {
          match($0, /^#+/); lvl = RLENGTH
          if (f && lvl <= start) exit
          if (!f && tolower($0) ~ re) { f = 1; start = lvl; next }
        }
        f { print }
      ' "$file" ;;
  esac
}

# Prints the lines of TEXT matching every newline-separated pattern in PATS.
lines_matching_all() {
  local out="$1" pat
  while IFS= read -r pat; do
    [ -n "$pat" ] || continue
    out="$(printf '%s\n' "$out" | grep -iE -- "$pat")"
    [ -n "$out" ] || return 1
  done <<<"$2"
  printf '%s\n' "$out"
}

# 0 every scan holds; 1 a scan failed, each printed as [TAG]; 2 a file or
# region is absent or empty, so the scans cannot be read.
check() {
  local root="$1" i file text where problems=""
  for i in "${!SCAN_TAG[@]}"; do
    file="$root/${SCAN_REL[$i]}"
    where="${SCAN_WHERE[$i]}"
    if [ ! -s "$file" ]; then
      echo "UNREADABLE [${SCAN_TAG[$i]}]: $file is absent or empty" >&2
      return 2
    fi
    text="$(region_of "$file" "$where")"
    if [ -z "$text" ]; then
      echo "UNREADABLE [${SCAN_TAG[$i]}]: $file has no region for '$where'" >&2
      return 2
    fi
    if ! lines_matching_all "$text" "${SCAN_PATS[$i]}" >/dev/null; then
      problems="$problems
  [${SCAN_TAG[$i]}] ${SCAN_REL[$i]}${where:+ ($where)}: no line states all of: $(printf '%s' "${SCAN_PATS[$i]}" | tr '\n' ' ')"
    fi
  done
  if [ -n "$problems" ]; then
    echo "FAIL: under $root$problems" >&2
    return 1
  fi
  return 0
}

# Requires FIXTURE to pass, then for each scan deletes every line matching all
# its patterns from a copy and requires the copy rejected by that scan's tag.
discriminate() {
  local fixture="$1" i mutant out status
  out="$(check "$fixture" 2>&1)"
  status=$?
  if [ "$status" -ne 0 ]; then
    echo "FAIL: discriminator — the check rejected the conforming fixture (status $status)" >&2
    printf '%s\n' "$out" >&2
    return 1
  fi
  for i in "${!SCAN_TAG[@]}"; do
    mutant="$fixture.mutant-$i"
    rm -rf -- "$mutant"
    cp -R -- "$fixture" "$mutant"
    awk -v pats="${SCAN_PATS[$i]}" '
      BEGIN { n = split(pats, p, "\n") }
      { l = tolower($0); all = 1
        for (k = 1; k <= n; k++) if (p[k] != "" && l !~ p[k]) { all = 0; break }
        if (!all) print }
    ' "$mutant/${SCAN_REL[$i]}" > "$mutant/${SCAN_REL[$i]}.tmp" &&
      mv -- "$mutant/${SCAN_REL[$i]}.tmp" "$mutant/${SCAN_REL[$i]}"
    out="$(check "$mutant" 2>&1)"
    status=$?
    if [ "$status" -ne 1 ]; then
      echo "FAIL: discriminator — the mutant for [${SCAN_TAG[$i]}] returned status $status, not 1" >&2
      printf '%s\n' "$out" >&2
      return 1
    fi
    case "$out" in
      *"[${SCAN_TAG[$i]}]"*) ;;
      *)
        echo "FAIL: discriminator — the mutant for [${SCAN_TAG[$i]}] was rejected, but not by that scan" >&2
        printf '%s\n' "$out" >&2
        return 1 ;;
    esac
  done
  return 0
}

# Discriminator first, then the check over the toolkit under test.
run_case() {
  local status
  discriminate "$1" || exit 1
  check "$TOOLKIT_ROOT"
  status=$?
  if [ "$status" -eq 2 ]; then
    echo "FAIL: target absent — what this case reads does not exist yet" >&2
    exit 1
  fi
  [ "$status" -eq 0 ] || exit 1
}
# --- end of local arrangement ----------------------------------------------

AGENT="agents/change-test-writer.md"
MANIFEST='^#+ +the manifest[[:space:]]*$'

require_line section-named  "$AGENT" "$MANIFEST"           'missing shared arrangement'
require_line near-miss      "$AGENT" "$MANIFEST"           'near[- ]miss'
require_line no-import      "$AGENT" ""                    'test module' 'import'
require_line dispatch-input "$AGENT" 'dispatch contract'   'shared (test )?arrangement'
require_line read-bound     "$AGENT" 'what you may read'   'shared (test )?arrangement'
require_line no-port-read   "$AGENT" 'what you may read'   'double' 'port'
require_line additive-kept  "$AGENT" ""                    'this pass adds tests and never subtracts'

fixture="$TESTDIR/conforming"
mkdir -p "$fixture/agents"
cat >"$fixture/$AGENT" <<'FIXTURE'
---
name: change-test-writer
description: fixture
---
## Your dispatch contract

The dispatch may name the shared test arrangement, read-only.
Unrelated prose keeps this section non-empty.

## What you may read

You may read the dispatched shared arrangement.
A shared double gives the port's signature; never follow it to the port's implementation.
Unrelated prose keeps this section non-empty.

## Arrangement

Never import a name from another test module.

## The pass is additive only

State that this pass adds tests and never subtracts.

## The manifest

Record a **Missing shared arrangement** section.
Each entry records any near-miss and why it would not do.
Unrelated prose keeps this section non-empty.
FIXTURE
assert_file "$fixture/$AGENT" "the conforming fixture was not written"

run_case "$fixture"
