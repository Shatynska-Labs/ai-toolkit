#!/usr/bin/env bash
# Scenario: The seeded entry's fields are a list. Also the statement the
# MODIFIED requirement adds to "A project without a backlog receives the
# seeded file" ("the fields follow the entry's prose as one list, one item per
# field, in that order, with no blank line between them"), and the field order
# "The seeded entry shape carries the structured fields" relies on.
# Requirement: A backlog is seeded where none exists.
# Change: list-the-entry-fields (project-bootstrap, MODIFIED).
#
# SPECIFIED: the entry shape gives its fields as list items, `- **Priority**`
# to `- **Re-checked**`, one item per field, in the requirement's order
# (Priority, Kind, Waits on, Design with, Workstream, Recorded by,
# Re-checked), with no blank line between them.
# DERIVED (placement, design.md decision 2): the entry shape is the fenced
# example; each item is one line beginning `- **<label>**` (AGENTS.md: a list
# item is one line); "consecutive" is read as the seven items occupying seven
# adjacent lines with nothing else between them.
# DERIVED (design.md decision 2): the list follows the entry's prose — the
# nearest non-blank line above the first item is prose, not a heading, a
# fence or another list item.
#
# Executes the tool and reads its output (second situation). The local
# parser is checked first against specimens it must accept and reject, so a
# pass cannot come from a check that reads nothing. Red until task 1.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

LABELS=("Priority" "Kind" "Waits on" "Design with" "Workstream" "Recorded by" "Re-checked")

# Local arrangement (test-plan.md, Missing shared arrangement): line number of
# the first fenced line beginning `- **<label>**`, or nothing. tests/lib.sh's
# fenced_line is the near-miss: it matches `**<label>**` only, without the
# list marker this scenario requires.
fenced_item_line() {
  awk -v label="$2" '
    /^[[:space:]]*(```|~~~)/ { infence = !infence; next }
    infence && index($0, "- **" label "**") == 1 { print NR; exit }
  ' "$1"
}

# check_list FILE: 0 where the fields are the specified list, 1 otherwise
# (the reason on stderr).
check_list() {
  local file="$1" label n prev="" first="" last="" i line above
  for label in "${LABELS[@]}"; do
    n="$(fenced_item_line "$file" "$label")"
    if [ -z "$n" ]; then
      echo "FAIL: the entry shape carries no list item \`- **$label**\`" >&2
      return 1
    fi
    if [ -n "$prev" ] && [ "$n" -le "$prev" ]; then
      echo "FAIL: \`- **$label**\` (line $n) is out of the requirement's order (previous item at line $prev)" >&2
      return 1
    fi
    [ -z "$first" ] && first="$n"
    prev="$n"
    last="$n"
  done
  if [ $((last - first + 1)) -ne ${#LABELS[@]} ]; then
    echo "FAIL: the seven field items span lines $first-$last; something stands between them (a blank line or other text)" >&2
    sed -n "${first},${last}p" "$file" >&2
    return 1
  fi
  for ((i = first; i <= last; i++)); do
    line="$(sed -n "${i}p" "$file")"
    case "$line" in
      "- **"*) ;;
      *) echo "FAIL: line $i between the field items is not a field item: $line" >&2; return 1 ;;
    esac
  done
  above="$(awk -v f="$first" 'NR < f && $0 !~ /^[[:space:]]*$/ { l = $0 } NR >= f { exit } END { print l }' "$file")"
  case "$above" in
    "#"* | '```'* | '~~~'* | "- "* | "")
      echo "FAIL: the field list does not follow the entry's prose; the line above it is: $above" >&2
      return 1 ;;
  esac
  return 0
}

# Discriminator for the local parser.
spec="$TESTDIR/specimen"
mkdir -p "$spec"
conforming() {
  # shellcheck disable=SC2016 # backticks are literal markdown in the specimen
  printf '%s\n' '```' '## `change-name`' '' 'What the change is and why.' '' \
    '- **Priority**: p' '- **Kind**: k' '- **Waits on**: w' '- **Design with**: d' \
    '- **Workstream**: s' '- **Recorded by**: r' '- **Re-checked**: c' '```'
}
conforming > "$spec/ok.md"
check_list "$spec/ok.md" 2>/dev/null \
  || { echo "FAIL: discriminator — the list check rejects a conforming entry shape" >&2; check_list "$spec/ok.md"; exit 1; }
# Paragraph fields, the layout this change retires.
# shellcheck disable=SC2016 # backticks are literal markdown in the specimen
printf '%s\n' '```' '## `change-name`' '' 'What the change is and why.' '' \
  '**Priority**: p' '' '**Kind**: k' '' '**Waits on**: w' '' '**Design with**: d' '' \
  '**Workstream**: s' '' '**Recorded by**: r' '' '**Re-checked**: c' '```' > "$spec/paragraphs.md"
# A blank line inside the list.
conforming | awk '{ print } /^- \*\*Kind\*\*/ { print "" }' > "$spec/blank.md"
# Two items swapped.
conforming | awk '/^- \*\*Kind\*\*/ { k = $0; next } { print } /^- \*\*Waits on\*\*/ { print k }' > "$spec/order.md"
# The list directly under the heading, with no prose.
conforming | awk '!/^What the change/' | awk 'NR == 3 && /^$/ { next } { print }' > "$spec/noprose.md"
for bad in paragraphs blank order noprose; do
  if check_list "$spec/$bad.md" 2>/dev/null; then
    echo "FAIL: discriminator — the list check accepts the $bad specimen" >&2
    exit 1
  fi
done

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"

backlog="$work/docs/backlog.md"
assert_file "$backlog" "the seeded file this case reads"

check_list "$backlog" || exit 1
