#!/usr/bin/env bash
# change-code-review scenarios (mechanical half only): A scenario has no
# covering test; A scenario is uncovered with a reason that holds; A change
# uses a stated exemption.
#
# The traceability requirement fixes two closed sets of markers: the
# implementation status of a requirement or scenario — `[Implemented]`,
# `[Partially Implemented]`, `[Not Implemented]`, `[Contradicted]` — and a
# scenario's test coverage — a named test, `[Uncovered — reason]`,
# `[Exempt — reason]` or `[Untested]`. Each scenario above names one or two
# of them as its outcome. What a case can reach is that
# `agents/change-code-reviewer.md` states every marker.
#
# The two reason-bearing markers are matched on their opening, `[Uncovered —`
# and `[Exempt —`, so that `[Uncovered — reason]` and `[Uncovered — <reason>]`
# both satisfy it. The em dash is the spec's own. A bare `[Exempt]` does not
# satisfy it: the reason is part of the marker, and the spec distinguishes an
# exemption that holds from one that does not by it.
#
# Not asserted: which marker a scenario earns, that an `[Uncovered — reason]`
# or `[Exempt — reason]` scenario raises a finding only where its reason fails,
# and that a test mapped to a scenario it does not assert is `[Untested]`.
# Those are a review's reasoning, and there is no program here to run one.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

AGENT_REL="agents/change-code-reviewer.md"

check() {
  local root="$1"
  local file="$root/$AGENT_REL"
  local marker problems=""

  if [ ! -s "$file" ]; then
    echo "FAIL: $file is absent or empty — the scans below would pass vacuously" >&2
    return 2
  fi

  # The brackets keep `[Implemented]` from matching inside `[Not Implemented]`
  # or `[Partially Implemented]`.
  for marker in '[Implemented]' '[Partially Implemented]' '[Not Implemented]' '[Contradicted]' \
                '[Untested]' '[Uncovered —' '[Exempt —'; do
    if ! grep -q -F -- "$marker" "$file"; then
      problems="$problems
  the code reviewer does not state the marker $marker"
    fi
  done

  if [ -n "$problems" ]; then
    echo "FAIL: $file$problems" >&2
    return 1
  fi
  return 0
}

check "$TOOLKIT_ROOT" || exit 1

# A static read, so the check is run over material this test supplies: every
# marker present, the exemption one without its reason — the mislabelling the
# design rejects, an exempt scenario indistinguishable from one whose
# exemption was never checked.
fixture="$TESTDIR/falsifying"
mkdir -p "$fixture/agents"
cat >"$fixture/$AGENT_REL" <<'FIXTURE'
Mark each `[Implemented]`, `[Partially Implemented]`, `[Not Implemented]` or `[Contradicted]`.
Coverage: the test, `[Uncovered — reason]`, `[Exempt]`, or `[Untested]`.
FIXTURE
assert_file "$fixture/$AGENT_REL" "the falsifying fixture was not written"

fixture_reason="$(check "$fixture" 2>&1)"
fixture_status=$?
if [ "$fixture_status" -eq 2 ]; then
  echo "FAIL: the fixture could not be read; the discriminator would pass without discriminating" >&2
  exit 1
fi
if [ "$fixture_status" -eq 0 ]; then
  echo "FAIL: the check passed over a code reviewer whose exemption marker carries no reason" >&2
  exit 1
fi
case "$fixture_reason" in
  *'does not state the marker [Exempt —'*) ;;
  *)
    echo "FAIL: the fixture was rejected, but not for the reasonless exemption marker:" >&2
    printf '%s\n' "$fixture_reason" >&2
    exit 1 ;;
esac
