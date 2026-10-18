#!/usr/bin/env bash
# change-code-review scenario (mechanical half only, DERIVED): A one-line fix
# is obvious.
#
# The scenario's outcome is that the reviewer reports the fix and leaves the
# file unchanged; its requirement says the reviewer SHALL NOT edit, create or
# delete a file as a reviewer. The spec fixes no tool grant. `design.md` does:
# the drafted frontmatter grants `Skill, Bash, Read, Grep, Glob`, and its
# Risks section accepts that `Bash` leaves the boundary to the prompt. What a
# case can reach is that the grant adds no file-editing tool on top — a
# reviewer granted `Edit` would make the obvious one-line fix the easiest act
# available. This assertion traces to the design, not the spec, and is
# labelled DERIVED for that reason.
#
# Not asserted: that the reviewer does not write through `Bash`, restores a
# seeded violation, or leaves untracked output in place. Those are conduct,
# and the grant does not reach them.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

AGENT_REL="agents/change-code-reviewer.md"

# Prints the frontmatter's `tools` value, inline or as a YAML block list, one
# line per entry or one comma-separated line.
tools_of() {
  awk '
    NR == 1 && $0 == "---" { fm = 1; next }
    fm && $0 == "---"      { exit }
    !fm                    { exit }
    /^tools:/ { sub(/^tools:[[:space:]]*/, ""); if ($0 != "") print; list = 1; next }
    list && /^[[:space:]]+-[[:space:]]*/ { sub(/^[[:space:]]+-[[:space:]]*/, ""); print; next }
    { list = 0 }
  ' "$1"
}

check() {
  local root="$1"
  local file="$root/$AGENT_REL"
  local tools granted

  if [ ! -s "$file" ]; then
    echo "FAIL: $file is absent or empty — the scans below would pass vacuously" >&2
    return 2
  fi

  tools="$(tools_of "$file")"
  # Vacuity guard: the design's grant includes `Bash`, so an extraction that
  # does not find it found nothing, and the scan below would pass on it.
  if ! printf '%s\n' "$tools" | grep -qw -- 'Bash'; then
    echo "FAIL: $file: no frontmatter tools grant naming Bash was found — the scan below would pass vacuously" >&2
    return 2
  fi

  granted="$(printf '%s\n' "$tools" | grep -owE -- 'Write|Edit|MultiEdit|NotebookEdit' | sort -u | tr '\n' ' ')"
  if [ -n "$granted" ]; then
    echo "FAIL: $file
  the code reviewer is granted a file-editing tool: $granted" >&2
    return 1
  fi
  return 0
}

check "$TOOLKIT_ROOT" || exit 1

# A static read, so the check is run over material this test supplies: the
# design's grant with `Edit` added, written as a block list so the inline
# form is not the only one the extraction is shown to read.
fixture="$TESTDIR/falsifying"
mkdir -p "$fixture/agents"
cat >"$fixture/$AGENT_REL" <<'FIXTURE'
---
name: change-code-reviewer
tools:
  - Skill
  - Bash
  - Read
  - Edit
  - Grep
  - Glob
---
Report findings; never apply them.
FIXTURE
assert_file "$fixture/$AGENT_REL" "the falsifying fixture was not written"

fixture_reason="$(check "$fixture" 2>&1)"
fixture_status=$?
if [ "$fixture_status" -eq 2 ]; then
  echo "FAIL: the fixture's grant could not be read; the discriminator would pass without discriminating" >&2
  printf '%s\n' "$fixture_reason" >&2
  exit 1
fi
if [ "$fixture_status" -eq 0 ]; then
  echo "FAIL: the check passed over a code reviewer granted Edit" >&2
  exit 1
fi
case "$fixture_reason" in
  *'granted a file-editing tool: Edit'*) ;;
  *)
    echo "FAIL: the fixture was rejected, but not for the Edit grant:" >&2
    printf '%s\n' "$fixture_reason" >&2
    exit 1 ;;
esac
