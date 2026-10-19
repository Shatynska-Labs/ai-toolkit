#!/usr/bin/env bash
# hand-missing-test-arrangement-to-apply, change-code-review scenarios
# (mechanical half only): An item is neither promoted nor kept; The diff
# imports from another test module; The conventions name no test-path glob;
# The conventions are silent on the shared arrangement; An untraced review
# still checks imports.
#
# Each outcome is a review's reasoning, verified by create-agent's cold-run
# check (tasks 3.3, 5.2). What a case can reach is that the contract in
# agents/change-code-reviewer.md states the audit, its severity and its place
# in the report:
#   [audit-section]           SPECIFIED  the report carries "the arrangement audit"
#   [audit-order]             SPECIFIED  in the report, the arrangement audit
#                                        comes after the task audit
#   [missing-not-applicable]  SPECIFIED  the missing-arrangement part can be
#                                        marked not applicable
#   [test-module-import]      SPECIFIED  a line names the **test module** term
#                                        and import
#   [import-not-run]          SPECIFIED  the import check can be reported not run
#   [major-arrangement]       SPECIFIED  Severity places the arrangement entry
#   [major-import]            SPECIFIED  Severity places the added import
#
# Section anchors ("Severity", "Your report") are DERIVED: the headings tasks
# 3.1-3.2 name. Matching on one line, where the spec sets no single sentence,
# is a DERIVED reading of the one-paragraph-per-line convention. That the two
# Severity scans are read as [MAJOR] rather than any severity is not
# asserted: the section's layout is not fixed by the spec.
#
# Not asserted: that a kept entry raises nothing, that a promotion with no
# recorded shared arrangement is a finding, that "silent" is told from
# "states none", and which findings a fixture diff yields. Those are review
# reasoning; verified by the cold-run check.
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

AGENT="agents/change-code-reviewer.md"
REPORT='^#+ +your report'
SEVERITY='^#+ +severity'

require_line audit-section          "$AGENT" ""          'arrangement audit'
require_line missing-not-applicable "$AGENT" ""          'arrangement' 'not applicable'
require_line test-module-import     "$AGENT" ""          'test module' 'import'
require_line import-not-run         "$AGENT" ""          'import' 'not run'
require_line major-arrangement      "$AGENT" "$SEVERITY" 'arrangement'
require_line major-import           "$AGENT" "$SEVERITY" 'import'

# [audit-order]: in the report section, the first line naming the task audit
# precedes the first line naming the arrangement audit. Status as check().
check_order() {
  local file="$1/$AGENT" text task arr
  text="$(region_of "$file" "$REPORT" 2>/dev/null)"
  if [ -z "$text" ]; then
    echo "UNREADABLE [audit-order]: $file has no report section" >&2
    return 2
  fi
  task="$(printf '%s\n' "$text" | grep -n -i -E -- 'task audit' | head -n1 | cut -d: -f1)"
  arr="$(printf '%s\n' "$text" | grep -n -i -E -- 'arrangement audit' | head -n1 | cut -d: -f1)"
  if [ -z "$task" ] || [ -z "$arr" ] || [ "$arr" -le "$task" ]; then
    echo "FAIL: [audit-order] $file: the report does not place the arrangement audit after the task audit" >&2
    return 1
  fi
  return 0
}

write_fixture() {
  mkdir -p "$1/agents"
  cat >"$1/$AGENT" <<'FIXTURE'
---
name: change-code-reviewer
description: fixture
---
## What you check

Read the **Missing shared arrangement** section; with no change, the missing-arrangement part is not applicable.
Check the diff adds no import of a name from one test module into another.
Where the conventions are silent on the shared arrangement, report the import check not run.

## Severity

- `[MAJOR]` — a missing-arrangement entry neither promoted nor kept.
- `[MAJOR]` — an import added from one test module into another.
- `[MINOR]` — naming.

## Your report

1. Task audit.
2. Arrangement audit.
3. Findings.
FIXTURE
  assert_file "$1/$AGENT" "the fixture was not written"
}

fixture="$TESTDIR/conforming"
write_fixture "$fixture"

# The order scan's own discriminator: the conforming fixture passes, and the
# same fixture with the two audits swapped is rejected on that scan.
check_order "$fixture" || { echo "FAIL: discriminator — the order scan rejected the conforming fixture" >&2; exit 1; }
swapped="$TESTDIR/swapped"
write_fixture "$swapped"
sed -i -e 's/^1\. Task audit\.$/1. Arrangement audit./' -e '0,/^2\. Arrangement audit\.$/s//2. Task audit./' "$swapped/$AGENT"
assert_contains "$swapped/$AGENT" "1. Arrangement audit." "the swapped fixture was not written"
out="$(check_order "$swapped" 2>&1)"
status=$?
if [ "$status" -ne 1 ]; then
  echo "FAIL: discriminator — the order scan returned status $status over the swapped fixture, not 1" >&2
  printf '%s\n' "$out" >&2
  exit 1
fi

check_order "$TOOLKIT_ROOT"
order_status=$?
run_case "$fixture"
[ "$order_status" -eq 0 ] || exit 1
