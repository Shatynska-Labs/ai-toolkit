#!/usr/bin/env bash
# change-code-review scenarios (mechanical half only): Only minor findings;
# The plan cannot achieve its goal; A critical finding; A clean review.
#
# Each scenario names one verdict as its outcome — `CONDITIONALLY APPROVED`,
# `REJECTED`, `FIX REQUIRED`, `APPROVED` — and the requirement fixes the set
# as closed: a performed review concludes with exactly one of the four. A
# reviewer whose contract does not state a verdict cannot conclude in it, so
# what a case can reach is that `agents/change-code-reviewer.md` itself states
# all four.
#
# `review-verdict-vocabulary.sh` already asserts that *some* agent carries the
# set, which `change-plan-reviewer` satisfies on its own. That is why this
# case reads the code reviewer's file by name rather than the directory: the
# fixture below puts the set in the plan reviewer and leaves the code reviewer
# without the standalone clean-review verdict, which a directory-wide scan
# would accept.
#
# Not asserted: which verdict a given set of findings yields, that `REJECTED`
# stays orthogonal to the severity mapping, and that a blocked review carries
# no verdict. Those are a review's reasoning, and there is no program here to
# run a review against.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

AGENT_REL="agents/change-code-reviewer.md"

check() {
  local root="$1"
  local file="$root/$AGENT_REL"
  local verdict problems=""

  if [ ! -s "$file" ]; then
    echo "FAIL: $file is absent or empty — the scans below would pass vacuously" >&2
    return 2
  fi

  # Backticked, because `APPROVED` unquoted is a substring of
  # `CONDITIONALLY APPROVED`: a reviewer that dropped the clean-review verdict
  # would otherwise still pass. DERIVED: the backtick form is the form
  # `change-plan-reviewer` and the delta spec both use, not one the spec fixes.
  # shellcheck disable=SC2016 # the backticks are literal markdown, not a command substitution
  for verdict in '`APPROVED`' '`CONDITIONALLY APPROVED`' '`FIX REQUIRED`' '`REJECTED`'; do
    if ! grep -q -F -- "$verdict" "$file"; then
      problems="$problems
  the code reviewer does not state the verdict $verdict"
    fi
  done

  if [ -n "$problems" ]; then
    echo "FAIL: $file$problems" >&2
    return 1
  fi
  return 0
}

check "$TOOLKIT_ROOT" || exit 1

# A static read, so the check is run over material this test supplies: the
# whole set published by the plan reviewer, and the code reviewer stating
# every verdict but the standalone `APPROVED`.
fixture="$TESTDIR/falsifying"
mkdir -p "$fixture/agents"
cat >"$fixture/agents/change-plan-reviewer.md" <<'FIXTURE'
Conclude with one of `APPROVED`, `CONDITIONALLY APPROVED`, `FIX REQUIRED` or `REJECTED`.
FIXTURE
cat >"$fixture/$AGENT_REL" <<'FIXTURE'
Conclude with one of `CONDITIONALLY APPROVED`, `FIX REQUIRED` or `REJECTED`. A clean review is APPROVED.
FIXTURE
assert_file "$fixture/$AGENT_REL" "the falsifying fixture was not written"

fixture_reason="$(check "$fixture" 2>&1)"
fixture_status=$?
if [ "$fixture_status" -eq 2 ]; then
  echo "FAIL: the fixture could not be read; the discriminator would pass without discriminating" >&2
  exit 1
fi
if [ "$fixture_status" -eq 0 ]; then
  echo "FAIL: the check passed over a code reviewer that does not state \`APPROVED\`" >&2
  exit 1
fi
# shellcheck disable=SC2016 # the backticks are literal markdown, not a command substitution
case "$fixture_reason" in
  *'does not state the verdict `APPROVED`'*) ;;
  *)
    echo "FAIL: the fixture was rejected, but not for the missing \`APPROVED\`:" >&2
    printf '%s\n' "$fixture_reason" >&2
    exit 1 ;;
esac
