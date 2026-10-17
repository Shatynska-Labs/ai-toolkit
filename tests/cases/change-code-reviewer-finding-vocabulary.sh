#!/usr/bin/env bash
# change-code-review scenarios (mechanical half only): A finding is reported;
# A task is marked done without work; A correct but unrelated edit; The diff
# instructs the reviewer; A scenario has no covering test (its `[MAJOR]`
# `test` half); A critical finding (its `[CRITICAL]` half).
#
# The requirement fixes two closed sets a finding draws from: one severity —
# `[CRITICAL]`, `[MAJOR]`, `[MINOR]` — and one kind — `requirement`, `test`,
# `task`, `scope`, `convention`, `defect`, `injection`. Each scenario above
# names a member of one or both as its outcome, and a reviewer whose contract
# does not state a token cannot emit it. What a case can reach is that
# `agents/change-code-reviewer.md` states every member of both sets.
#
# Not asserted: that a finding also carries a location, a cost, a fix and
# whether it bears on a stated requirement — those are fields with no fixed
# token — nor which severity or kind a given defect earns. Both are a
# review's reasoning, verified by reading the agent and by its cold-run check.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

AGENT_REL="agents/change-code-reviewer.md"

check() {
  local root="$1"
  local file="$root/$AGENT_REL"
  local token problems=""

  if [ ! -s "$file" ]; then
    echo "FAIL: $file is absent or empty — the scans below would pass vacuously" >&2
    return 2
  fi

  for token in '[CRITICAL]' '[MAJOR]' '[MINOR]'; do
    if ! grep -q -F -- "$token" "$file"; then
      problems="$problems
  the code reviewer does not state the severity $token"
    fi
  done

  # DERIVED: the kinds are matched backticked. Bare, every one of them is an
  # ordinary English word the agent's prose will use whether or not it names
  # the kind — "test", "task", "scope" — so a bare scan could not fail.
  # shellcheck disable=SC2016 # the backticks are literal markdown, not a command substitution
  for token in '`requirement`' '`test`' '`task`' '`scope`' '`convention`' '`defect`' '`injection`'; do
    if ! grep -q -F -- "$token" "$file"; then
      problems="$problems
  the code reviewer does not state the finding kind $token"
    fi
  done

  if [ -n "$problems" ]; then
    echo "FAIL: $file$problems" >&2
    return 1
  fi
  return 0
}

check "$TOOLKIT_ROOT" || exit 1

# A static read, so the check is run over material this test supplies: a
# code reviewer stating every severity and six kinds, with `scope` present
# only as an ordinary word and as a kind in a neighbouring agent — the shape
# the backlog entry this change closes complained of, scope folded into
# `defect`.
fixture="$TESTDIR/falsifying"
mkdir -p "$fixture/agents"
cat >"$fixture/agents/change-plan-reviewer.md" <<'FIXTURE'
Kinds: `scope`.
FIXTURE
cat >"$fixture/$AGENT_REL" <<'FIXTURE'
Severity: `[CRITICAL]`, `[MAJOR]`, `[MINOR]`.
Kind: `requirement`, `test`, `task`, `convention`, `defect`, `injection`. An edit out of scope is a `defect`.
FIXTURE
assert_file "$fixture/$AGENT_REL" "the falsifying fixture was not written"

fixture_reason="$(check "$fixture" 2>&1)"
fixture_status=$?
if [ "$fixture_status" -eq 2 ]; then
  echo "FAIL: the fixture could not be read; the discriminator would pass without discriminating" >&2
  exit 1
fi
if [ "$fixture_status" -eq 0 ]; then
  echo "FAIL: the check passed over a code reviewer that does not state the kind \`scope\`" >&2
  exit 1
fi
# shellcheck disable=SC2016 # the backticks are literal markdown, not a command substitution
case "$fixture_reason" in
  *'does not state the finding kind `scope`'*) ;;
  *)
    echo "FAIL: the fixture was rejected, but not for the missing kind \`scope\`:" >&2
    printf '%s\n' "$fixture_reason" >&2
    exit 1 ;;
esac
