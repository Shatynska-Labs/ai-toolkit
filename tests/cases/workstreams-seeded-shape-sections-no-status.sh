#!/usr/bin/env bash
# Scenario: The seeded register carries no status field (as revised).
# Requirement: A workstream register is seeded where none exists.
# Change: hold-shared-research-in-a-workstream (project-bootstrap, MODIFIED).
#
# SPECIFIED: the workstream shape names Goal, Done when, Steps, Not in scope,
# Open questions and Opened, and the Context and Decisions sections, and names
# no field or section recording a step's status.
# DERIVED (placement): the shape is the fenced example (design.md decision 7);
# each field a fenced line carrying `**<label>**`, each section a fenced line
# that is exactly `## Context` or `## Decisions`.
# DERIVED (operationalisation of "no field or section recording a step's
# status"): no fenced line, headings included, carries `status`, `progress`,
# `in flight`, a `- [ ]`/`- [x]` checkbox, or a `done:` marker — the scan of
# workstreams-seeded-no-status-field.sh, widened to sections by reading every
# fenced line. A status field or section worded otherwise is not reached;
# verified by reading.
#
# Executes the tool and reads its output (second situation). The local shape
# check is first run over specimens it must accept and reject. Red at
# authoring on the property "the shape names the Context and Decisions
# sections" (state 1: the tool writes a `**Decisions**` item and no sections);
# goes green as task 1.1 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement): every line
# inside fenced code, fence markers dropped.
fenced_text() {
  awk '/^[[:space:]]*(```|~~~)/ { infence = !infence; next } infence { print }' "$1"
}

check_shape() {
  local shape label
  shape="$(fenced_text "$1")"
  if [ -z "$shape" ]; then
    echo "FAIL: the file carries no fenced workstream shape; the scans would assert nothing" >&2
    return 1
  fi
  for label in "Goal" "Done when" "Steps" "Not in scope" "Open questions" "Opened"; do
    if ! printf '%s\n' "$shape" | grep -q -F -- "**$label**"; then
      echo "FAIL: the workstream shape does not name **$label**" >&2
      return 1
    fi
  done
  for label in "Context" "Decisions"; do
    if ! printf '%s\n' "$shape" | grep -q -x -F -- "## $label"; then
      echo "FAIL: the workstream shape carries no \`## $label\` section" >&2
      return 1
    fi
  done
  if printf '%s\n' "$shape" | grep -n -i -E 'status|progress|in flight|- \[[ xX]\]|(^|[^a-z])done:' >&2; then
    echo "FAIL: the workstream shape names a field or section recording a step's status" >&2
    return 1
  fi
  return 0
}

# Discriminator for the local check.
spec="$TESTDIR/specimen"
mkdir -p "$spec"
conforming() {
  # shellcheck disable=SC2016 # backticks are literal markdown in the specimen
  printf '%s\n' 'Prose naming status outside the fence.' '```' '# `name`' '' '**Goal**: g' '' \
    '**Done when**: d' '' '**Steps**:' '' '1. `a` — x' '' \
    '- **Not in scope**: `none`.' '- **Open questions**: `none`.' '- **Opened**: when.' '' \
    '## Context' '' 'Research; omit where none.' '' '## Decisions' '' '**1. A decision.** Why.' '```'
}
conforming > "$spec/ok.md"
check_shape "$spec/ok.md" 2>/dev/null \
  || { echo "FAIL: discriminator — the shape check rejects a conforming shape" >&2; check_shape "$spec/ok.md"; exit 1; }
conforming | sed 's/^## Context$/## Background/' > "$spec/no-context.md"
conforming | sed 's/^## Decisions$/- **Decisions**: d./' > "$spec/decisions-item.md"
conforming | sed 's/^## Context$/## Step status/' | sed 's/^## Decisions$/## Context\n\n## Decisions/' > "$spec/status-section.md"
conforming | sed 's/^\(- \*\*Opened\*\*.*\)$/\1\n- **Progress**: none./' > "$spec/progress-item.md"
for bad in no-context decisions-item status-section progress-item; do
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
