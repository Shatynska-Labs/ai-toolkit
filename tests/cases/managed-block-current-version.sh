#!/usr/bin/env bash
# Scenarios: A project's adopted version is readable;
# Existing specification tooling is skipped, not reinitialized (mirrored for
# the conventions-file concern).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

work="$TESTDIR/work"
mkdir -p "$work"
cd "$work" || exit 1
version="$(fragment_version)" || exit 1

# The marker is printed separately so the fixture body keeps a quoted
# heredoc: an unquoted one would subject every line to parameter, command
# and backslash expansion to interpolate one value.
inner="$(cat <<'BLOCK'
<!-- Generated. Do not edit inside this block — it is replaced on update.
     Project-specific conventions belong outside the markers. -->
placeholder existing content at the current version
BLOCK
)"
hash="$(printf '%s\n' "$inner" | sha256sum | cut -d' ' -f1)"
{
  printf '<!-- ai-toolkit:development-workflow %s sha256:%s -->\n' "$version" "$hash"
  printf '%s\n' "$inner"
  cat <<'BLOCK'
<!-- /ai-toolkit:development-workflow -->
BLOCK
} > AGENTS.md
sum_before="$(md5sum AGENTS.md | awk '{print $1}')"

report="$TESTDIR/report.txt"
bash "$PROJECT_INIT" >"$report" 2>&1
status=$?

assert_exit 0 "$status"
assert_unchanged "$work/AGENTS.md" "$sum_before" "current-version block is not rewritten"
assert_contains "$report" "conventions file: block already present" "reported as already present, not appended again"

count="$(grep -c '<!-- ai-toolkit:development-workflow' "$work/AGENTS.md")"
if [ "$count" != "1" ]; then
  echo "FAIL: expected exactly one marker, found $count — block must not be duplicated" >&2
  exit 1
fi
assert_contains "$report" "(version $version, matches)" "the current version is reported as matching"
