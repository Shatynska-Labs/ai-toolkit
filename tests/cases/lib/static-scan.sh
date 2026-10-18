#!/usr/bin/env bash
# Shared machinery for the backlog-skill-* cases. Not a case itself: run.sh
# runs tests/cases/*.sh only, so a file under tests/cases/lib/ is sourced, never
# run. Written by change-test-writer for add-backlog-skill; see that change's
# test-plan.md (unresolved question Q2) for why it sits here and not in
# tests/lib.sh.
#
# A case declares scans, then runs them twice: over a fixture tree it writes
# (scan_discriminate), and over $TOOLKIT_ROOT (scan_check).
#
#   scan MODE REL WHERE TAG REGEX [SPECIMEN]
#     MODE      require | forbid
#     REL       path relative to the root being checked
#     WHERE     ""            the whole file
#               @description  the frontmatter `description:` value
#               <word>        the section under the first heading naming <word>
#                             (any level, up to the next heading of the same
#                             or a higher level; fenced code is not a heading)
#     TAG       short name printed as [TAG] in the problem the scan reports
#     REGEX     lowercase ERE, matched against the lowercased text; written to
#               be portable between grep -E and awk (no \b, no \s)
#     SPECIMEN  forbid scans only: a line the discriminator inserts to trip it
#
# scan_check ROOT returns 0 (every scan holds), 1 (a scan failed; each failure
# printed as [TAG] on stderr) or 2 (a scanned file or section is absent or
# empty, so the scans cannot be read — the target-absent state).
#
# scan_discriminate FIXTURE_ROOT requires the fixture to pass, then builds one
# mutant per scan — a require scan's matches blanked out, a forbid scan's
# specimen inserted — and requires each mutant to be rejected with status 1
# and that scan's own [TAG]. Every scan is therefore shown to be able to fail
# on the property it names, not merely the case as a whole.

SCAN_MODE=()
SCAN_REL=()
SCAN_WHERE=()
SCAN_TAG=()
SCAN_RE=()
SCAN_SPECIMEN=()

scan() {
  SCAN_MODE+=("$1")
  SCAN_REL+=("$2")
  SCAN_WHERE+=("$3")
  SCAN_TAG+=("$4")
  SCAN_RE+=("$5")
  SCAN_SPECIMEN+=("${6:-}")
}

# The section under the first heading naming a word, fenced code skipped.
scan_heading_section() {
  awk -v w="$2" '
    /^[[:space:]]*(```|~~~)/ { infence = !infence; if (f) print; next }
    !infence && /^#+[[:space:]]/ {
      match($0, /^#+/); lvl = RLENGTH
      if (f && lvl <= start) exit
      if (!f) {
        h = tolower($0)
        if (h ~ ("(^|[^a-z-])" w "([^a-z-]|$)")) { f = 1; start = lvl; next }
      }
    }
    f { print }
  ' "$1"
}

# The frontmatter `description:` value, folded or not, up to the next key.
scan_description() {
  awk '
    NR == 1 && /^---[[:space:]]*$/ { infm = 1; next }
    infm && /^---[[:space:]]*$/ { exit }
    infm && /^description:/ { d = 1; print; next }
    infm && d && /^[A-Za-z_][A-Za-z0-9_-]*:/ { d = 0 }
    infm && d { print }
  ' "$1"
}

scan_text() {
  local file="$1/$2" where="$3"
  [ -f "$file" ] || return 2
  case "$where" in
    "") cat "$file" ;;
    @description) scan_description "$file" ;;
    *) scan_heading_section "$file" "$where" ;;
  esac
}

scan_check() {
  local root="$1" problems="" i text lower where hits
  for i in "${!SCAN_TAG[@]}"; do
    where="${SCAN_WHERE[$i]}"
    text="$(scan_text "$root" "${SCAN_REL[$i]}" "$where")"
    if [ -z "$text" ]; then
      echo "UNREADABLE [${SCAN_TAG[$i]}]: $root/${SCAN_REL[$i]}${where:+ (where: $where)} is absent or empty; the scans cannot be read" >&2
      return 2
    fi
    lower="$(printf '%s\n' "$text" | tr '[:upper:]' '[:lower:]')"
    hits="$(printf '%s\n' "$lower" | grep -E -- "${SCAN_RE[$i]}")"
    if [ "${SCAN_MODE[$i]}" = require ] && [ -z "$hits" ]; then
      problems="$problems
  [${SCAN_TAG[$i]}] ${SCAN_REL[$i]}${where:+ ($where)} states nothing matching /${SCAN_RE[$i]}/"
    elif [ "${SCAN_MODE[$i]}" = forbid ] && [ -n "$hits" ]; then
      problems="$problems
  [${SCAN_TAG[$i]}] ${SCAN_REL[$i]}${where:+ ($where)} states what it must not: $(printf '%s' "$hits" | head -n 3)"
    fi
  done
  if [ -n "$problems" ]; then
    echo "FAIL: under $root$problems" >&2
    return 1
  fi
  return 0
}

# Mutates one file of a copied fixture tree for scan i.
scan_mutate() {
  local file="$1" i="$2" tmp="$1.tmp"
  if [ "${SCAN_MODE[$i]}" = require ]; then
    # Blank every match outside headings and frontmatter delimiters, so the
    # region still exists and the scan reports a problem rather than absence.
    awk -v re="${SCAN_RE[$i]}" '
      /^#/ || /^---[[:space:]]*$/ { print; next }
      { l = tolower($0); gsub(re, "redacted", l); print l }
    ' "$file" > "$tmp"
  else
    case "${SCAN_WHERE[$i]}" in
      ""|@description)
        { cat "$file"; printf '%s\n' "${SCAN_SPECIMEN[$i]}"; } > "$tmp" ;;
      *)
        awk -v w="${SCAN_WHERE[$i]}" -v s="${SCAN_SPECIMEN[$i]}" '
          { print }
          !done && /^#+[[:space:]]/ && tolower($0) ~ ("(^|[^a-z-])" w "([^a-z-]|$)") { print ""; print s; done = 1 }
        ' "$file" > "$tmp" ;;
    esac
  fi
  mv "$tmp" "$file"
}

scan_discriminate() {
  local fixture="$1" i mutant out status
  out="$(scan_check "$fixture" 2>&1)"
  status=$?
  if [ "$status" -ne 0 ]; then
    echo "FAIL: discriminator — the check rejected the conforming fixture (status $status)" >&2
    printf '%s\n' "$out" >&2
    return 1
  fi
  for i in "${!SCAN_TAG[@]}"; do
    mutant="$fixture.mutant-$i"
    rm -rf "$mutant"
    cp -R "$fixture" "$mutant"
    scan_mutate "$mutant/${SCAN_REL[$i]}" "$i"
    out="$(scan_check "$mutant" 2>&1)"
    status=$?
    if [ "$status" -ne 1 ]; then
      echo "FAIL: discriminator — mutant for [${SCAN_TAG[$i]}] returned status $status, not 1" >&2
      printf '%s\n' "$out" >&2
      return 1
    fi
    case "$out" in
      *"[${SCAN_TAG[$i]}]"*) ;;
      *)
        echo "FAIL: discriminator — mutant for [${SCAN_TAG[$i]}] was rejected, but not by that scan" >&2
        printf '%s\n' "$out" >&2
        return 1 ;;
    esac
  done
  return 0
}

# Runs the discriminator, then the check over $TOOLKIT_ROOT; exits the case.
scan_run() {
  local fixture="$1" status
  scan_discriminate "$fixture" || exit 1
  scan_check "$TOOLKIT_ROOT"
  status=$?
  if [ "$status" -eq 2 ]; then
    echo "FAIL: target absent — what this case reads does not exist yet" >&2
    exit 1
  fi
  [ "$status" -eq 0 ] || exit 1
  exit 0
}
