#!/usr/bin/env bash
# hand-missing-test-arrangement-to-apply, change-test-authoring scenario
# (mechanical half only): The fragment names what implementation does with
# missing arrangement.
#
# rules/test-plan.md is what an implementer reads before implementing. The
# requirement obliges it to name the manifest's **Missing shared arrangement**
# section and to state that each item is promoted into the shared
# arrangement or kept with a recorded reason:
#   [section-named]  SPECIFIED  the section's name
#   [promoted]       SPECIFIED  promotion into the shared arrangement
#   [kept]           SPECIFIED  a keep, with its reason
# Matching on one line is a DERIVED reading of the one-paragraph-per-line
# convention; the body is read, since the frontmatter carries no rule.
#
# Not asserted: that the disposition is written against the entry, and the
# version bump 2 -> 3 (design decision 8, not a scenario). Verified by reading.
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

FRAGMENT="rules/test-plan.md"

require_line section-named "$FRAGMENT" @body 'missing shared arrangement'
require_line promoted      "$FRAGMENT" @body 'promot' 'shared (test )?arrangement'
require_line kept          "$FRAGMENT" @body 'kept|keep' 'reason'

fixture="$TESTDIR/conforming"
mkdir -p "$fixture/rules"
cat >"$fixture/$FRAGMENT" <<'FIXTURE'
---
kind: standing-constraint
version: 3
---
Read the change's test-plan.md before implementing.
Its **Missing shared arrangement** section lists local declarations.
Each is promoted into the shared arrangement in the same change.
Or it is kept local, with a recorded reason, written against its entry.
FIXTURE
assert_file "$fixture/$FRAGMENT" "the conforming fixture was not written"

run_case "$fixture"
