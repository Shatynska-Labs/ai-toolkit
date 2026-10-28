#!/usr/bin/env bash
# Scenario: The seeded workstream's fields are a list. Also the revised
# shape statement of "A project without a workstream register receives the
# seeded file": Goal and Done when as paragraphs, the fields after the steps
# as one list, one item per field, with no blank line between them.
# Requirement: A workstream register is seeded where none exists.
# Change: list-the-entry-fields (project-bootstrap, MODIFIED).
#
# SPECIFIED: the workstream shape gives Not in scope, Open questions and
# Opened as consecutive list items after the steps, in that order, each
# absent value as `none`; Goal and Done when stay paragraphs. Decisions left
# the list for a section (hold-shared-research-in-a-workstream).
# DERIVED (placement): the shape is the fenced example; each item is one line
# beginning `- **<label>**` (AGENTS.md: a list item is one line), so the three
# occupy three adjacent lines; "after the steps" is read as after the fenced
# `**Steps**` line; Goal and Done when are fenced lines beginning
# `**<label>**` with no list marker.
# DERIVED (operationalisation of "each absent value"): Opened always has a
# value (when and by what), so the `none` assertion binds the two fields
# that can be empty; neither of the two may still offer `nothing`.
#
# Executes the tool and reads its output (second situation). The local
# parser is checked first against specimens it must accept and reject. Red
# until task 1.2 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

ITEMS=("Not in scope" "Open questions" "Opened")
NONE_ITEMS=("Not in scope" "Open questions")

# Local arrangement (test-plan.md, Missing shared arrangement): line number of
# the first fenced line beginning PREFIX**<label>**, or nothing. tests/lib.sh's
# fenced_line is the near-miss: it fixes the prefix to none, so it cannot
# require the list marker.
fenced_prefixed_line() {
  awk -v want="$2**$3**" '
    /^[[:space:]]*(```|~~~)/ { infence = !infence; next }
    infence && index($0, want) == 1 { print NR; exit }
  ' "$1"
}

check_shape() {
  local file="$1" label n prev="" first="" last="" i line steps
  for label in Goal "Done when"; do
    if [ -z "$(fenced_prefixed_line "$file" "" "$label")" ]; then
      echo "FAIL: the workstream shape does not give **$label** as a paragraph line" >&2
      return 1
    fi
  done
  steps="$(fenced_prefixed_line "$file" "" Steps)"
  if [ -z "$steps" ]; then
    echo "FAIL: the workstream shape carries no **Steps** line to place the list after" >&2
    return 1
  fi
  for label in "${ITEMS[@]}"; do
    n="$(fenced_prefixed_line "$file" "- " "$label")"
    if [ -z "$n" ]; then
      echo "FAIL: the workstream shape carries no list item \`- **$label**\`" >&2
      return 1
    fi
    if [ -n "$prev" ] && [ "$n" -le "$prev" ]; then
      echo "FAIL: \`- **$label**\` (line $n) is out of order (previous item at line $prev)" >&2
      return 1
    fi
    [ -z "$first" ] && first="$n"
    prev="$n"
    last="$n"
  done
  if [ "$first" -le "$steps" ]; then
    echo "FAIL: the field list (line $first) does not come after the steps (line $steps)" >&2
    return 1
  fi
  if [ $((last - first + 1)) -ne ${#ITEMS[@]} ]; then
    echo "FAIL: the ${#ITEMS[@]} field items span lines $first-$last; something stands between them" >&2
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
  for label in "${NONE_ITEMS[@]}"; do
    n="$(fenced_prefixed_line "$file" "- " "$label")"
    line="$(sed -n "${n}p" "$file")"
    # shellcheck disable=SC2016 # backticks are literal markdown
    if ! printf '%s\n' "$line" | grep -q -F -- '`none`'; then
      echo "FAIL: $label does not give its absent value as \`none\`: $line" >&2
      return 1
    fi
    if printf '%s\n' "$line" | grep -q -i -E -- '(^|[^a-z])nothing([^a-z]|$)'; then
      echo "FAIL: $label still offers \`nothing\`: $line" >&2
      return 1
    fi
  done
  return 0
}

# Discriminator for the local parser.
spec="$TESTDIR/specimen"
mkdir -p "$spec"
conforming() {
  # shellcheck disable=SC2016 # backticks are literal markdown in the specimen
  printf '%s\n' '```' '# `name`' '' '**Goal**: g' '' '**Done when**: d' '' '**Steps**:' '' \
    '1. `a` — x' '2. `b` — y' '' \
    '- **Not in scope**: n, or `none`.' '- **Open questions**: q, or `none`.' \
    '- **Opened**: when and by what.' '```'
}
conforming > "$spec/ok.md"
check_shape "$spec/ok.md" 2>/dev/null \
  || { echo "FAIL: discriminator — the shape check rejects a conforming shape" >&2; check_shape "$spec/ok.md"; exit 1; }
# Paragraph fields after the steps, the layout this change retires.
conforming | sed -e 's/^- \*\*/**/' -e 's/^\(\*\*Opened\)/\n\1/' > "$spec/paragraphs.md"
# A blank line inside the list.
conforming | awk '{ print } /^- \*\*Open questions\*\*/ { print "" }' > "$spec/blank.md"
# `nothing` kept as an absent value.
# shellcheck disable=SC2016 # backticks are literal markdown in the sed program
conforming | sed 's/^\(- \*\*Open questions\*\*.*\)`none`/\1`nothing`/' > "$spec/nothing.md"
# Goal turned into a list item.
conforming | sed 's/^\*\*Goal\*\*/- **Goal**/' > "$spec/goal.md"
for bad in paragraphs blank nothing goal; do
  if check_shape "$spec/$bad.md" 2>/dev/null; then
    echo "FAIL: discriminator — the shape check accepts the $bad specimen" >&2
    exit 1
  fi
done

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"

r="$work/docs/workstreams/README.md"
assert_file "$r" "the seeded file this case reads"

check_shape "$r" || exit 1
