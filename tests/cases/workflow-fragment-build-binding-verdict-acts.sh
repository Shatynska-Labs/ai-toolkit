#!/usr/bin/env bash
# change-code-review scenario (mechanical half only): A session receives a
# verdict.
#
# The requirement fixes one sentence of `rules/development-workflow.md`: the
# Claude Code binding of `build`'s review gate states the act for each of the
# four verdicts — on `FIX REQUIRED`, fix and re-review where the fixes were
# substantial; on `CONDITIONALLY APPROVED`, apply the `[MINOR]` fixes and
# continue; on `APPROVED`, continue; on `REJECTED`, stop and raise it. The
# verdicts are tokens and the acts are short fixed phrases, so this half is
# mechanical.
#
# The binding is located structurally: the `_Claude Code binding:_`
# paragraph(s) inside the `### build` section. `plan`'s binding already
# carries all four verdicts with their acts, so a whole-file scan would pass
# today; the first fixture below is that shape. DERIVED: the section heading
# and the binding marker are the fragment's present structure, which the
# requirement does not fix — it states "nothing about the fragment's shape".
#
# Each act is read from the text between its verdict and the next verdict
# token, so an act stated against the wrong verdict does not satisfy it. That
# reading assumes the four are stated one after another, as `plan`'s binding
# states them; it is DERIVED, and so are the lexical proxies for each act —
# "fix", "review" or "dispatch", "substantial"; "[MINOR]", "continue";
# "continue"; "stop", "raise". The verdict tokens themselves are SPECIFIED.
#
# Not asserted: that a session does what the binding says, and the
# three-round bound, which the fragment states in role prose this case does
# not read.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

FRAGMENT_REL="rules/development-workflow.md"

build_binding() {
  awk '
    /^### / { inbuild = ($0 == "### build"); binding = 0; next }
    !inbuild { next }
    /^_Claude Code binding:_/ { binding = 1 }
    /^[[:space:]]*$/ { binding = 0 }
    binding { printf "%s ", $0 }
  ' "$1"
}

# The text after the first occurrence of verdict $2 in $1, up to the next
# verdict token.
clause_after() {
  awk -v text="$1" -v tok="$2" 'BEGIN {
    i = index(text, tok); if (i == 0) exit 1
    rest = substr(text, i + length(tok))
    n = split("`APPROVED`|`CONDITIONALLY APPROVED`|`FIX REQUIRED`|`REJECTED`", v, "|")
    cut = length(rest) + 1
    for (k = 1; k <= n; k++) { j = index(rest, v[k]); if (j > 0 && j < cut) cut = j }
    print substr(rest, 1, cut - 1)
  }'
}

has() { printf '%s\n' "$1" | grep -qiF -- "$2"; }

check() {
  local root="$1"
  local file="$root/$FRAGMENT_REL"
  local binding clause verdict problems=""

  if [ ! -s "$file" ]; then
    echo "FAIL: $file is absent or empty — the scans below would pass vacuously" >&2
    return 2
  fi

  binding="$(build_binding "$file")"
  # Vacuity guard: the binding this requirement governs names the reviewer it
  # dispatches. An extraction that does not find it found the wrong text.
  if ! has "$binding" "change-code-reviewer"; then
    echo "FAIL: $file: no Claude Code binding naming change-code-reviewer in the '### build' section — the scans below would pass vacuously" >&2
    return 2
  fi

  # shellcheck disable=SC2016 # the backticks are literal markdown, not a command substitution
  for verdict in '`FIX REQUIRED`' '`CONDITIONALLY APPROVED`' '`APPROVED`' '`REJECTED`'; do
    if ! clause="$(clause_after "$binding" "$verdict")"; then
      problems="$problems
  build's binding does not state the verdict $verdict"
      continue
    fi
    case "$verdict" in
      *FIX*)
        { has "$clause" "fix" && { has "$clause" "review" || has "$clause" "dispatch"; } && has "$clause" "substantial"; } ||
          problems="$problems
  build's binding does not state the act for $verdict: fix, and re-review where the fixes were substantial" ;;
      *CONDITIONALLY*)
        { has "$clause" "[MINOR]" && has "$clause" "continue"; } ||
          problems="$problems
  build's binding does not state the act for $verdict: apply the [MINOR] fixes and continue" ;;
      *REJECTED*)
        { has "$clause" "stop" && has "$clause" "raise"; } ||
          problems="$problems
  build's binding does not state the act for $verdict: stop and raise it" ;;
      *)
        has "$clause" "continue" ||
          problems="$problems
  build's binding does not state the act for $verdict: continue" ;;
    esac
  done

  if [ -n "$problems" ]; then
    echo "FAIL: $file$problems" >&2
    return 1
  fi
  return 0
}

check "$TOOLKIT_ROOT" || exit 1

# A static read, so the check is run over material this test supplies.
#
# Fixture one: the four verdicts and their acts stated in `plan`'s binding
# only, `build`'s binding naming the reviewer and nothing else — the shape a
# whole-file scan accepts.
plan_only="$TESTDIR/plan-only"
mkdir -p "$plan_only/rules"
cat >"$plan_only/$FRAGMENT_REL" <<'FIXTURE'
### plan

_Claude Code binding:_ dispatch `ai-toolkit:change-plan-reviewer`. On `FIX REQUIRED` fix and re-dispatch where the fixes were substantial; on `CONDITIONALLY APPROVED` apply the `[MINOR]` fixes and continue; on `APPROVED` continue; on `REJECTED` stop and raise it.

### build

_Claude Code binding:_ run `ai-toolkit:change-code-reviewer` over the change's committed diff.

### ship
FIXTURE

# Fixture two: `build`'s binding names all four verdicts, but `REJECTED`
# carries the fix-and-re-review act — the shape a token-only scan accepts.
wrong_act="$TESTDIR/wrong-act"
mkdir -p "$wrong_act/rules"
cat >"$wrong_act/$FRAGMENT_REL" <<'FIXTURE'
### build

_Claude Code binding:_ run `ai-toolkit:change-code-reviewer` over the change's committed diff. On `FIX REQUIRED` fix and re-review where the fixes were substantial; on `CONDITIONALLY APPROVED` apply the `[MINOR]` fixes and continue; on `APPROVED` continue; on `REJECTED` fix the code and re-review.

### ship
FIXTURE

discriminate() {
  local root="$1" expected="$2" what="$3" reason status
  assert_file "$root/$FRAGMENT_REL" "the falsifying fixture was not written"
  reason="$(check "$root" 2>&1)"
  status=$?
  if [ "$status" -eq 2 ]; then
    echo "FAIL: $what: the fixture's binding could not be read; the discriminator would pass without discriminating" >&2
    printf '%s\n' "$reason" >&2
    exit 1
  fi
  if [ "$status" -eq 0 ]; then
    echo "FAIL: the check passed over $what" >&2
    exit 1
  fi
  case "$reason" in
    *"$expected"*) ;;
    *)
      echo "FAIL: $what was rejected, but not for: $expected" >&2
      printf '%s\n' "$reason" >&2
      exit 1 ;;
  esac
}

# shellcheck disable=SC2016 # the backticks are literal markdown, not a command substitution
discriminate "$plan_only" 'does not state the verdict `REJECTED`' \
  "a fragment whose verdict acts are in plan's binding only"
# shellcheck disable=SC2016 # the backticks are literal markdown, not a command substitution
discriminate "$wrong_act" 'does not state the act for `REJECTED`' \
  "a build binding stating the wrong act for REJECTED"
