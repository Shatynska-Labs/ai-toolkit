#!/usr/bin/env bash
# Shared machinery for cases that read one paragraph of a markdown file.
# Not a case itself: run.sh runs tests/cases/*.sh only, so a file under
# tests/cases/lib/ is sourced, never run. Written by change-test-writer for
# fold-small-work-in; see that change's test-plan.md (unresolved question Q2).
#
# This repository writes prose one paragraph per line (AGENTS.md), so a
# paragraph is a line. A case selects the paragraph it reads by one or more
# selectors, every one of which must match the line, then declares scans that
# must hold on the selected lines. static-scan.sh reads a file or a section
# under a heading; this reads a paragraph, which is the unit the workflow
# fragment's rules are written in.
#
#   line_select REGEX            a selector; every selector must match
#   line_scan MODE TAG REGEX [SPECIMEN]
#     MODE      require   some selected line matches REGEX
#               forbid    no selected line matches REGEX
#     TAG       short name printed as [TAG] in the problem the scan reports
#     REGEX     lowercase ERE, matched against the lowercased line; portable
#               between grep -E and awk (no \b, no \s)
#     SPECIMEN  forbid scans only: text the discriminator appends to the
#               first selected line to trip it
#
# line_check FILE returns 0 (every scan holds), 1 (a scan failed; each printed
# as [TAG] on stderr) or 2 (the file is absent or no line matches every
# selector — the target-absent state).
#
# line_discriminate FIXTURE_FILE requires the fixture to pass, then builds one
# mutant per scan — a require scan's matches on the selected lines blanked
# out, a forbid scan's specimen appended to the first selected line — and
# requires each mutant to be rejected with status 1 and that scan's own
# [TAG]. A require regex overlapping a selector would make its mutant
# unselectable (status 2), so the discriminator rejects that too.

LS_SELECT=()
LS_MODE=()
LS_TAG=()
LS_RE=()
LS_SPECIMEN=()

line_select() { LS_SELECT+=("$1"); }

line_scan() {
  LS_MODE+=("$1")
  LS_TAG+=("$2")
  LS_RE+=("$3")
  LS_SPECIMEN+=("${4:-}")
}

# Prints the lowercased lines matching every selector.
line_selected() {
  local sel
  sel="$(IFS=$'\034'; printf '%s' "${LS_SELECT[*]}")"
  awk -v sel="$sel" '
    BEGIN { n = split(sel, s, "\034") }
    {
      l = tolower($0); ok = 1
      for (i = 1; i <= n; i++) if (s[i] != "" && l !~ s[i]) { ok = 0; break }
      if (ok) print l
    }
  ' "$1"
}

line_check() {
  local file="$1" text i hits problems=""
  if [ ! -f "$file" ]; then
    echo "UNREADABLE: $file is absent; the scans cannot be read" >&2
    return 2
  fi
  text="$(line_selected "$file")"
  if [ -z "$text" ]; then
    echo "UNREADABLE: $file has no paragraph matching every selector (${LS_SELECT[*]}); the scans cannot be read" >&2
    return 2
  fi
  for i in "${!LS_TAG[@]}"; do
    hits="$(printf '%s\n' "$text" | grep -E -- "${LS_RE[$i]}")"
    if [ "${LS_MODE[$i]}" = require ] && [ -z "$hits" ]; then
      problems="$problems
  [${LS_TAG[$i]}] the selected paragraph states nothing matching /${LS_RE[$i]}/"
    elif [ "${LS_MODE[$i]}" = forbid ] && [ -n "$hits" ]; then
      problems="$problems
  [${LS_TAG[$i]}] the selected paragraph states what it must not (/${LS_RE[$i]}/)"
    fi
  done
  if [ -n "$problems" ]; then
    echo "FAIL: $file$problems" >&2
    return 1
  fi
  return 0
}

# Writes the mutant of FILE for scan i to OUT.
line_mutate() {
  local file="$1" i="$2" out="$3" sel
  sel="$(IFS=$'\034'; printf '%s' "${LS_SELECT[*]}")"
  awk -v sel="$sel" -v mode="${LS_MODE[$i]}" -v re="${LS_RE[$i]}" -v sp="${LS_SPECIMEN[$i]}" '
    BEGIN { n = split(sel, s, "\034") }
    {
      l = tolower($0); ok = 1
      for (k = 1; k <= n; k++) if (s[k] != "" && l !~ s[k]) { ok = 0; break }
      if (!ok) { print; next }
      if (mode == "require") { gsub(re, "redacted", l); print l }
      else if (!done) { print $0 " " sp; done = 1 }
      else print
    }
  ' "$file" > "$out"
}

line_discriminate() {
  local fixture="$1" i mutant out status
  out="$(line_check "$fixture" 2>&1)"
  status=$?
  if [ "$status" -ne 0 ]; then
    echo "FAIL: discriminator — the check rejected the conforming fixture (status $status)" >&2
    printf '%s\n' "$out" >&2
    return 1
  fi
  for i in "${!LS_TAG[@]}"; do
    mutant="$fixture.mutant-$i"
    line_mutate "$fixture" "$i" "$mutant"
    out="$(line_check "$mutant" 2>&1)"
    status=$?
    if [ "$status" -ne 1 ]; then
      echo "FAIL: discriminator — mutant for [${LS_TAG[$i]}] returned status $status, not 1" >&2
      printf '%s\n' "$out" >&2
      return 1
    fi
    case "$out" in
      *"[${LS_TAG[$i]}]"*) ;;
      *)
        echo "FAIL: discriminator — mutant for [${LS_TAG[$i]}] was rejected, but not by that scan" >&2
        printf '%s\n' "$out" >&2
        return 1 ;;
    esac
  done
  return 0
}

# Runs the discriminator, then the check over $TOOLKIT_ROOT/REL; exits the case.
line_run() {
  local fixture="$1" rel="$2" status
  line_discriminate "$fixture" || exit 1
  line_check "$TOOLKIT_ROOT/$rel"
  status=$?
  if [ "$status" -eq 2 ]; then
    echo "FAIL: target absent — the paragraph this case reads does not exist yet" >&2
    exit 1
  fi
  [ "$status" -eq 0 ] || exit 1
  exit 0
}
