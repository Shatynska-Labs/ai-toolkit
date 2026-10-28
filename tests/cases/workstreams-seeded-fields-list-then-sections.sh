#!/usr/bin/env bash
# Scenario: The seeded workstream's fields are a list (as revised). Also the
# revised shape statement of "A project without a workstream register
# receives the seeded file": Goal and Done when as paragraphs; Not in scope,
# Open questions and Opened as one list after the steps, no blank line
# between them; Open questions' answer recorded under Decisions; then an
# optional `## Context` and an optional `## Decisions` section, in that order,
# each omitted where it would be empty.
# Requirement: A workstream register is seeded where none exists.
# Change: hold-shared-research-in-a-workstream (project-bootstrap, MODIFIED).
#
# SPECIFIED: Not in scope, Open questions and Opened are consecutive list
# items after the steps, in that order; Not in scope and Open questions give
# an absent value as `none`; no Decisions list item; `## Context` and then
# `## Decisions` after the list; Goal and Done when are paragraphs; Open
# questions' answer is recorded under Decisions; each section is omitted
# where empty.
# DERIVED (placement): the shape is the fenced example; each item is one
# fenced line beginning `- **<label>**` (AGENTS.md: a list item is one line),
# so the three occupy three adjacent lines; "after the steps" is after the
# fenced `**Steps**` line; Goal and Done when are fenced lines beginning
# `**<label>**` with no list marker; a section is a fenced line that is exactly
# `## Context` or `## Decisions`.
# DERIVED (operationalisation of "each absent value"): Opened always has a
# value, so `none` binds Not in scope and Open questions; neither may offer
# `nothing`.
# DERIVED (wording): the Open questions item carries "recorded under
# Decisions" (the requirement's and design.md decision 7's phrase); each
# section's placeholder, up to the next heading or the fence's end, carries
# "omit" (design.md decision 7: "omit the section where there are none").
#
# Executes the tool and reads its output (second situation). The local shape
# check is first run over specimens it must accept and reject. Red at
# authoring on the property "the field list carries no Decisions item"
# (state 1: the tool writes `- **Decisions**` between Open questions and
# Opened, so the three items are not adjacent); goes green as task 1.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

ITEMS=("Not in scope" "Open questions" "Opened")
NONE_ITEMS=("Not in scope" "Open questions")

# Local arrangement (test-plan.md, Missing shared arrangement): line number of
# the first fenced line beginning PREFIX**<label>**, or nothing. Found in
# workstreams-seeded-fields-are-a-list.sh (a test module, so declared here).
fenced_prefixed_line() {
  awk -v want="$2**$3**" '
    /^[[:space:]]*(```|~~~)/ { infence = !infence; next }
    infence && index($0, want) == 1 { print NR; exit }
  ' "$1"
}

# Local arrangement: line number of the first fenced line that is exactly
# TEXT, or nothing.
fenced_exact_line() {
  awk -v want="$2" '
    /^[[:space:]]*(```|~~~)/ { infence = !infence; next }
    infence && $0 == want { print NR; exit }
  ' "$1"
}

# Local arrangement: prints "yes" where a line after line N, up to the next
# heading or fence marker, contains "omit".
section_omits() {
  awk -v n="$2" '
    NR <= n { next }
    /^[[:space:]]*(```|~~~)/ || /^#/ { exit }
    index(tolower($0), "omit") { print "yes"; exit }
  ' "$1"
}

check_shape() {
  local file="$1" label n prev="" first="" last="" i line steps ctx dec
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
    echo "FAIL: the three field items span lines $first-$last; something stands between them" >&2
    sed -n "${first},${last}p" "$file" >&2
    return 1
  fi
  if [ -n "$(fenced_prefixed_line "$file" "- " Decisions)" ]; then
    echo "FAIL: the workstream shape still gives a \`- **Decisions**\` list item" >&2
    return 1
  fi
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
  line="$(sed -n "$(fenced_prefixed_line "$file" "- " "Open questions")p" "$file")"
  if ! printf '%s\n' "$line" | grep -q -F -- 'recorded under Decisions'; then
    echo "FAIL: Open questions does not record an answer under Decisions: $line" >&2
    return 1
  fi
  ctx="$(fenced_exact_line "$file" "## Context")"
  dec="$(fenced_exact_line "$file" "## Decisions")"
  if [ -z "$ctx" ] || [ -z "$dec" ]; then
    echo "FAIL: the workstream shape lacks a \`## Context\` or \`## Decisions\` section" >&2
    return 1
  fi
  if [ "$ctx" -le "$last" ] || [ "$dec" -le "$ctx" ]; then
    echo "FAIL: the sections are not after the list in the order Context, Decisions (list ends line $last, Context $ctx, Decisions $dec)" >&2
    return 1
  fi
  for i in "$ctx" "$dec"; do
    if [ -z "$(section_omits "$file" "$i")" ]; then
      echo "FAIL: the section at line $i does not say it is omitted where empty" >&2
      return 1
    fi
  done
  for ((i = first; i <= last; i++)); do
    line="$(sed -n "${i}p" "$file")"
    case "$line" in
      "- **"*) ;;
      *) echo "FAIL: line $i between the field items is not a field item: $line" >&2; return 1 ;;
    esac
  done
  return 0
}

# Discriminator for the local check.
spec="$TESTDIR/specimen"
mkdir -p "$spec"
conforming() {
  # shellcheck disable=SC2016 # backticks are literal markdown in the specimen
  printf '%s\n' '```' '# `name`' '' '**Goal**: g' '' '**Done when**: d' '' '**Steps**:' '' \
    '1. `a` — x' '2. `b` — y' '' \
    '- **Not in scope**: n, or `none`.' \
    '- **Open questions**: q, each deleted once answered with the answer recorded under Decisions, or `none`.' \
    '- **Opened**: when and by what.' '' \
    '## Context' '' 'Research; omit the section where there are none.' '' \
    '## Decisions' '' '**1. A decision.** Why; omit the section where there are none.' '```'
}
conforming > "$spec/ok.md"
check_shape "$spec/ok.md" 2>/dev/null \
  || { echo "FAIL: discriminator — the shape check rejects a conforming shape" >&2; check_shape "$spec/ok.md"; exit 1; }
# The list this change retires: a Decisions item between Open questions and Opened.
conforming | awk '/^- \*\*Opened\*\*/ { print "- **Decisions**: where they are recorded, or `none`." } { print }' > "$spec/decisions-item.md"
# A Decisions item placed elsewhere in the fence, the three items still adjacent.
conforming | awk '/^## Context$/ { print "- **Decisions**: d."; print "" } { print }' > "$spec/decisions-elsewhere.md"
# Sections in the wrong order.
conforming | sed -e 's/^## Context$/## TMP/' -e 's/^## Decisions$/## Context/' -e 's/^## TMP$/## Decisions/' > "$spec/order.md"
# A section missing.
conforming | sed 's/^## Context$/## Background/' > "$spec/no-context.md"
# Open questions' answer recorded elsewhere.
conforming | sed 's/recorded under Decisions/recorded where its decisions are/' > "$spec/answer.md"
# A section not marked optional.
conforming | sed 's/^\*\*1\. A decision\.\*\* Why; omit the section where there are none\./**1. A decision.** Why./' > "$spec/not-optional.md"
# A blank line inside the list.
conforming | awk '{ print } /^- \*\*Open questions\*\*/ { print "" }' > "$spec/blank.md"
for bad in decisions-item decisions-elsewhere order no-context answer not-optional blank; do
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

r="$work/docs/workstreams/AGENTS.md"
assert_file "$r" "the seeded file this case reads"

check_shape "$r" || exit 1
