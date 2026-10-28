#!/usr/bin/env bash
# Scenario: The plugin carries a semantic version.
# Requirement: Repository is an installable plugin.
# Change: list-what-a-project-receives (toolkit-structure, MODIFIED).
#
# SPECIFIED: .claude-plugin/plugin.json's `version` has the form
# MAJOR.MINOR.PATCH and is not below 1.0.0.
# DERIVED (operationalisation): the value of the first `"version"` key,
# read with sed, there being no JSON parser this suite may rely on.
#
# Static read (third situation); the reader and check run over fixtures
# first. Red until task 3.5 lands (state 1: the version is 0.2.0).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

check_plugin() {
  local v
  [ -f "$1" ] || { echo "ABSENT: $1" >&2; return 2; }
  v="$(sed -n -E 's/.*"version"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' "$1" | head -n 1)"
  printf '%s\n' "$v" | grep -q -E '^[0-9]+[.][0-9]+[.][0-9]+$' || { echo "[semver] version '$v' is not MAJOR.MINOR.PATCH" >&2; return 1; }
  [ "${v%%.*}" -ge 1 ] || { echo "[at-least-1] version '$v' is below 1.0.0" >&2; return 1; }
  return 0
}
fx() { printf '{\n  "name": "ai-toolkit",\n  "version": "%s"\n}\n' "$1" > "$TESTDIR/plugin-$2.json"; }
fx 1.0.0 ok; fx 1.4.2 later; fx 0.2.0 zero; fx 1.0 short
for good in ok later; do
  check_plugin "$TESTDIR/plugin-$good.json" || { echo "FAIL: discriminator — the $good version is rejected" >&2; exit 1; }
done
for bad in zero short; do
  if check_plugin "$TESTDIR/plugin-$bad.json" 2>/dev/null; then echo "FAIL: discriminator — the $bad version is accepted" >&2; exit 1; fi
done
check_plugin "$TOOLKIT_ROOT/.claude-plugin/plugin.json" || exit 1
