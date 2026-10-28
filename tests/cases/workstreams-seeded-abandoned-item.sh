#!/usr/bin/env bash
# Scenario: A project without a workstream register receives the seeded file
# — the revised abandonment statement ("gains an **Abandoned** item after
# Opened, with the date and the reason"). Bears also on "An abandoned
# workstream is archived, not deleted", whose own text is unchanged and stays
# with workstreams-seeded-abandoned.sh.
# Requirement: A workstream register is seeded where none exists.
# Change: list-the-entry-fields (project-bootstrap, MODIFIED).
#
# SPECIFIED: an abandoned workstream gains an Abandoned item after Opened,
# with the date and the reason.
# DERIVED (placement and wording, design.md decision 2: "the README's
# abandonment paragraph says so"): a line outside the fenced shape carries
# `**Abandoned**`, the word `item`, and `after` followed by `Opened`, with
# `date` and `reason`.
#
# Executes the tool and reads its output (second situation); the extraction
# is checked against specimens first. Red until task 1.2 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Lines outside any fence carrying **Abandoned**.
abandonment() {
  awk '
    /^[[:space:]]*(```|~~~)/ { infence = !infence; next }
    !infence && index($0, "**Abandoned**") { print }
  ' "$1"
}

check() {
  local text
  text="$(abandonment "$1")"
  if [ -z "$text" ]; then
    echo "FAIL: no paragraph outside the shape names **Abandoned**" >&2
    return 1
  fi
  if ! printf '%s\n' "$text" | grep -q -E 'item' \
    || ! printf '%s\n' "$text" | grep -q -E 'after[^.]*Opened' \
    || ! printf '%s\n' "$text" | grep -q -F 'date' \
    || ! printf '%s\n' "$text" | grep -q -F 'reason'; then
    echo "FAIL: the abandonment paragraph does not state an **Abandoned** item after Opened, with the date and the reason" >&2
    printf '%s\n' "$text" >&2
    return 1
  fi
  return 0
}

spec="$TESTDIR/specimen"
mkdir -p "$spec"
printf '%s\n' 'If the goal will not be met, the workstream gains an **Abandoned** item after **Opened**, with the date and the reason.' > "$spec/ok.md"
printf '%s\n' 'If the goal will not be met, add an **Abandoned** line with the date and the reason.' > "$spec/line.md"
printf '%s\n' '```' '- **Abandoned**: item after Opened, date, reason' '```' > "$spec/fenced.md"
check "$spec/ok.md" 2>/dev/null || { echo "FAIL: discriminator — the check rejects a conforming paragraph" >&2; exit 1; }
for bad in line fenced; do
  if check "$spec/$bad.md" 2>/dev/null; then
    echo "FAIL: discriminator — the check accepts the $bad specimen" >&2
    exit 1
  fi
done

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"

r="$work/docs/workstreams/AGENTS.md"
assert_file "$r" "the seeded file this case reads"

check "$r" || exit 1
