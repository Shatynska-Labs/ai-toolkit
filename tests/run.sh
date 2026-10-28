#!/usr/bin/env bash
# Discovers and runs every case in tests/cases/*.sh, each in its own
# isolated temporary directory. Exits non-zero if any case fails.
#
# Usage: run.sh [CASE...]
# Each CASE names one case by its file name, with or without .sh; given any,
# only those run. An unknown name counts as a failure.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

export TOOLKIT_ROOT
export TESTLIB="$SCRIPT_DIR/lib.sh"
export PROJECT_INIT="$TOOLKIT_ROOT/scripts/project-init"

pass=0
fail=0

case_files=()
if [ "$#" -gt 0 ]; then
  for arg in "$@"; do
    case_files+=("$SCRIPT_DIR/cases/$(basename "$arg" .sh).sh")
  done
else
  for case_file in "$SCRIPT_DIR"/cases/*.sh; do
    [ -e "$case_file" ] && case_files+=("$case_file")
  done
fi

for case_file in ${case_files[@]+"${case_files[@]}"}; do
  name="$(basename "$case_file" .sh)"

  if [ ! -f "$case_file" ]; then
    echo "FAIL  $name"
    echo "        no such case: tests/cases/$name.sh"
    fail=$((fail + 1))
    continue
  fi

  tmpdir="$(mktemp -d)"
  export TESTDIR="$tmpdir"

  # A case's failure is its result, not the runner's: capture its status
  # without letting errexit end the run.
  status=0
  output="$(bash "$case_file" 2>&1)" || status=$?

  if [ "$status" -eq 0 ]; then
    echo "ok    $name"
    pass=$((pass + 1))
  else
    echo "FAIL  $name"
    # shellcheck disable=SC2001 # per-line ^-anchored prefixing across a
    # multi-line string; ${var//search/replace} does not replace this cleanly.
    echo "$output" | sed 's/^/        /'
    fail=$((fail + 1))
  fi

  rm -rf "$tmpdir"
done

echo ""
echo "$pass passed, $fail failed"

if [ "$fail" -gt 0 ]; then
  exit 1
fi
exit 0
