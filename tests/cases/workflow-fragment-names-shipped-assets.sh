#!/usr/bin/env bash
# Scenario: A fragment names only agents and skills the library ships.
#
# Neither the workflow fragment nor the binding fragment may name an
# `ai-toolkit:` agent or skill this library does not ship. A consuming project
# reaches agents and skills only through the installed plugin, so a name with
# no agents/<name>.md or skills/<name>/SKILL.md behind it is a dispatch that
# finds nothing.
#
# The scan reads each fragment's body (the frontmatter is stripped by the
# inlining tool, so the body is what reaches a project), extracts every
# `ai-toolkit:<kebab-name>`, and resolves it against this library's agents/
# and skills/. It is written to return a status rather than exit, so the same
# scan runs over the real bodies and over two fixtures under $TESTDIR:
#
# - one naming an unshipped name, which the scan must report — without it a
#   pattern that never matches passes on the real tree (design.md decision 3);
# - one naming a shipped agent and a shipped skill, which the scan must not
#   report — without it a scan accepting agents alone, or reporting every
#   name, would pass the first fixture (design.md decisions 1 and 3).
#
# Derived, not specified: the name is matched as `ai-toolkit:` followed by
# [a-z0-9][a-z0-9-]* (design.md decision 2). Written by change-test-writer for
# extend-dangling-reference-to-agent-names; see that change's test-plan.md.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

if [ -z "${TOOLKIT_ROOT:-}" ] || [ ! -d "$TOOLKIT_ROOT/agents" ] || [ ! -d "$TOOLKIT_ROOT/skills" ]; then
  echo "FAIL: TOOLKIT_ROOT does not hold agents/ and skills/ — names cannot be resolved" >&2
  exit 1
fi

# Prints each `ai-toolkit:<name>` in the file at $1 that the library does not
# ship, one per line. Returns 1 if any was printed, 0 otherwise.
unshipped_names() {
  local file="$1" name status=0 names
  names="$(grep -o -E 'ai-toolkit:[a-z0-9][a-z0-9-]*' "$file" | sort -u || true)"
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    name="${name#ai-toolkit:}"
    if [ ! -f "$TOOLKIT_ROOT/agents/$name.md" ] && [ ! -f "$TOOLKIT_ROOT/skills/$name/SKILL.md" ]; then
      echo "ai-toolkit:$name"
      status=1
    fi
  done <<< "$names"
  return "$status"
}

# Discriminator 1: an unshipped name is reported.
absent="no-such-agent-for-dangling-scan"
if [ -e "$TOOLKIT_ROOT/agents/$absent.md" ] || [ -e "$TOOLKIT_ROOT/skills/$absent" ]; then
  echo "FAIL: fixture name $absent is shipped by the library — the discriminator would not discriminate" >&2
  exit 1
fi
fixture_absent="$TESTDIR/fixture-unshipped.body"
# shellcheck disable=SC2016 # the backticks are literal markdown in the fixture, not an expansion
printf 'At this gate, dispatch `ai-toolkit:%s` against the change.\n' "$absent" > "$fixture_absent"
if reported="$(unshipped_names "$fixture_absent")"; then
  echo "FAIL: the scan passed a fixture naming ai-toolkit:$absent, which the library does not ship" >&2
  exit 1
fi
case "$reported" in
  *"ai-toolkit:$absent"*) ;;
  *)
    echo "FAIL: the scan failed the unshipped fixture without naming ai-toolkit:$absent (reported: $reported)" >&2
    exit 1
    ;;
esac

# Discriminator 2: a shipped agent and a shipped skill are not reported.
assert_file "$TOOLKIT_ROOT/agents/change-test-writer.md" "fixture agent is shipped"
assert_file "$TOOLKIT_ROOT/skills/testing/SKILL.md" "fixture skill is shipped"
fixture_shipped="$TESTDIR/fixture-shipped.body"
# shellcheck disable=SC2016 # the backticks are literal markdown in the fixture, not an expansion
printf 'Dispatch `ai-toolkit:change-test-writer`, which loads `ai-toolkit:testing`.\n' > "$fixture_shipped"
if ! reported="$(unshipped_names "$fixture_shipped")"; then
  echo "FAIL: the scan reported a shipped agent or skill as unshipped: $reported" >&2
  exit 1
fi

# The real fragments.
failed=0
for base in development-workflow development-workflow-database; do
  fragment="$TOOLKIT_ROOT/rules/$base.md"
  assert_file "$fragment" "publication of the session obligations"

  closing="$(grep -n '^---$' "$fragment" | sed -n '2p' | cut -d: -f1)"
  if [ -z "$closing" ]; then
    echo "FAIL: $fragment has no closing frontmatter delimiter — the body cannot be located" >&2
    exit 1
  fi

  body="$TESTDIR/$base.body"
  tail -n "+$((closing + 1))" "$fragment" > "$body"
  if [ ! -s "$body" ]; then
    echo "FAIL: $fragment has an empty body — the scan would pass vacuously" >&2
    exit 1
  fi

  if ! reported="$(unshipped_names "$body")"; then
    echo "FAIL: $fragment names an ai-toolkit: agent or skill the library does not ship:" >&2
    echo "$reported" >&2
    failed=1
  fi
done

exit "$failed"
