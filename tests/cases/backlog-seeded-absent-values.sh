#!/usr/bin/env bash
# Scenario: An absent value reads as its field.
# Requirement: A backlog is seeded where none exists.
# Change: list-the-entry-fields (project-bootstrap, MODIFIED).
#
# SPECIFIED: the entry shape gives Waits on's absent value as `nothing`, and
# Design with's and Workstream's as `none`.
# DERIVED (placement, design.md decision 2): each field's definition is the
# fenced line beginning `**<label>**`, with or without a leading list marker
# `- ` (the layout is backlog-seeded-fields-are-a-list.sh's to assert, not
# this case's).
# DERIVED (operationalisation): the absent value is the backticked token;
# Design with and Workstream must not offer the word `nothing` at all, so a
# definition carrying both words fails.
#
# Executes the tool and reads its output (second situation). Red until task
# 1.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement): the first
# fenced line beginning `**<label>**` or `- **<label>**`. tests/lib.sh's
# fenced_line is the near-miss: it returns a line number, not the line. Kept local:
# AGENTS.md records no shared test arrangement (test-plan.md).
fenced_field() {
  awk -v label="$2" '
    /^[[:space:]]*(```|~~~)/ { infence = !infence; next }
    infence { l = $0; sub(/^- /, "", l); if (index(l, "**" label "**") == 1) { print; exit } }
  ' "$1"
}

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
bash "$PROJECT_INIT" >"$TESTDIR/report.txt" 2>&1
assert_exit 0 "$?"

backlog="$work/docs/backlog.md"
assert_file "$backlog" "the seeded file this case reads"

nothing_re='(^|[^a-z])nothing([^a-z]|$)'

waits="$(fenced_field "$backlog" "Waits on")"
if [ -z "$waits" ]; then
  echo "FAIL: the seeded entry shape carries no Waits on field" >&2
  exit 1
fi
# shellcheck disable=SC2016 # backticks are literal markdown
if ! printf '%s\n' "$waits" | grep -q -F -- '`nothing`'; then
  echo "FAIL: Waits on does not give its absent value as \`nothing\`" >&2
  printf '%s\n' "$waits" >&2
  exit 1
fi

for label in "Design with" "Workstream"; do
  def="$(fenced_field "$backlog" "$label")"
  if [ -z "$def" ]; then
    echo "FAIL: the seeded entry shape carries no $label field" >&2
    exit 1
  fi
  # shellcheck disable=SC2016 # backticks are literal markdown
  if ! printf '%s\n' "$def" | grep -q -F -- '`none`'; then
    echo "FAIL: $label does not give its absent value as \`none\`" >&2
    printf '%s\n' "$def" >&2
    exit 1
  fi
  if printf '%s\n' "$def" | grep -q -i -E -- "$nothing_re"; then
    echo "FAIL: $label still offers \`nothing\` as a value" >&2
    printf '%s\n' "$def" >&2
    exit 1
  fi
done
