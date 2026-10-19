#!/usr/bin/env bash
# hand-missing-test-arrangement-to-apply, project-foundation scenarios
# (mechanical half only): The shared arrangement is reached even when nobody
# raises it; The items reach AGENTS.md; A decision absorbed into a shared
# section stays visible.
#
# Both checklists — rules/project-foundation.md and
# skills/project-foundation/SKILL.md — carry the Testing Strategy items the
# requirement names, and say they reach AGENTS.md:
#   [*-test-command]  SPECIFIED  the test command item
#   [*-glob]          SPECIFIED  the test-path glob item
#   [*-shared]        SPECIFIED  the shared test arrangement item
#   [*-none]          SPECIFIED  that item's answer may be "none" — on the same
#                                line is a DERIVED reading of one-line-per-item
#   [*-agents-md]     SPECIFIED  the items are written into AGENTS.md
# Read from the lines after the first mention of "testing strategy" (DERIVED
# anchor). The section name is the spec's; how each file lays it out is not
# known to this case's author, who did not read either file, so the region
# runs to the end of the file rather than to the section's end. That is
# weaker than a section scope — an item stated in a later section would pass
# — and is recorded as such in the change's test-plan.md.
#
# Not asserted: that the item is proposed with reasoning when nobody raises
# it, and that the two checklists match line for line. Verified by reading.
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

RULE="rules/project-foundation.md"
SKILL="skills/project-foundation/SKILL.md"
TS='@after:testing strategy'

for pair in "rule:$RULE" "skill:$SKILL"; do
  who="${pair%%:*}"
  rel="${pair#*:}"
  require_line "$who-test-command" "$rel" "$TS" 'test command'
  require_line "$who-glob"         "$rel" "$TS" 'test-path glob'
  require_line "$who-shared"       "$rel" "$TS" 'shared test arrangement'
  require_line "$who-none"         "$rel" "$TS" 'shared test arrangement' 'none'
  require_line "$who-agents-md"    "$rel" "$TS" 'agents[.]md'
done

fixture="$TESTDIR/conforming"
for rel in "$RULE" "$SKILL"; do
  mkdir -p "$fixture/$(dirname -- "$rel")"
  cat >"$fixture/$rel" <<'FIXTURE'
---
description: fixture
---
## Architecture

Unrelated.

## Testing Strategy

- Test command — how the suite runs.
- Test-path glob — where tests may be written.
- Shared test arrangement — a path, or none.

All three are written into AGENTS.md's testing-strategy section.

## Development Tooling

Unrelated.
FIXTURE
  assert_file "$fixture/$rel" "the conforming fixture was not written"
done

run_case "$fixture"
