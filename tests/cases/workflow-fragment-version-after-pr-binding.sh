#!/usr/bin/env bash
# DERIVED, not traced to a delta-spec scenario: design.md decision 9 and task
# 2.3 — the binding line is body text, so by "The fragment's version
# increments when its body changes" its version goes from 12 to 13.
# Change: describe-commits-and-pull-requests. Written by change-test-writer;
# see that change's test-plan.md.
#
# Asserted as "at least 13" rather than the literal, so a later increment does
# not fail this case for a reason unrelated to it (tests/lib.sh's
# fragment_version note).
#
# Static read (third situation). Red at authoring (state 1 on real content:
# the version is 12). Discriminated over two decoy toolkit roots: one at 12,
# which the check must reject, and one at 13, which it must accept.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# 0 the root's fragment is at version 13 or later; 1 otherwise.
at_least_13() {
  local version
  version="$(fragment_version "$1")" || return 1
  case "$version" in
    ''|*[!0-9]*) echo "FAIL: the fragment's version is not a number: $version" >&2; return 1 ;;
  esac
  [ "$version" -ge 13 ]
}

for v in 12 13; do
  mkdir -p "$TESTDIR/decoy-$v/rules"
  printf -- '---\nkind: standing-constraint\nversion: %s\n---\nBody.\n' "$v" > "$TESTDIR/decoy-$v/rules/development-workflow.md"
done
if at_least_13 "$TESTDIR/decoy-12" 2>/dev/null; then
  echo "FAIL: discriminator — a fragment at version 12 was accepted" >&2
  exit 1
fi
if ! at_least_13 "$TESTDIR/decoy-13"; then
  echo "FAIL: discriminator — a fragment at version 13 was rejected" >&2
  exit 1
fi

if ! at_least_13 "$TOOLKIT_ROOT"; then
  echo "FAIL: the fragment's version is below 13; the body carrying the open pr binding is version 13 or later" >&2
  exit 1
fi
