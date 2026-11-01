#!/usr/bin/env bash
# Derived from the requirement below, not from a scenario in its specification;
# it extends to every tool under scripts/ on AGENTS.md's "runnable directly".
# Requirement: The update tool is a standalone executable beside project-init.
# Change: update-managed-block (project-update, ADDED), found at its confirm.
#
# SPECIFIED: a tool under scripts/ is runnable by a human, a shell or any agent.
# DERIVED: read as the tracked mode being 100755 and `<tool> --help` exiting 0
# when invoked by path. The other cases run the tools through `bash`, which a
# mode of 100644 passes.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

tools=$(git -C "$TOOLKIT_ROOT" ls-files -s -- scripts)
if [ -z "$tools" ]; then
  echo "FAIL: no tracked file under scripts/ — the check would pass vacuously" >&2
  exit 1
fi

while read -r mode _ _ path; do
  if [ "$mode" != "100755" ]; then
    echo "FAIL: $path is tracked as $mode, not 100755" >&2
    exit 1
  fi
  "$TOOLKIT_ROOT/$path" --help >/dev/null
  assert_exit 0 $? "$path --help, invoked by path"
done <<<"$tools"
