#!/usr/bin/env bash
# DERIVED, not traced to a delta-spec scenario: design.md decision 9 and task
# 3.1 — the fragment's body changes, so by "The fragment's version increments
# when its body changes" its version goes from 11 to 12.
# Change: one-file-per-backlog-entry.
#
# Asserted as "at least 12" rather than the literal, so a later increment does
# not fail this case for a reason unrelated to it (tests/lib.sh's
# fragment_version note).
#
# Static read; red until task 3.1 lands (state 1: the version is 11).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

version="$(fragment_version)" || exit 1
case "$version" in
  ''|*[!0-9]*) echo "FAIL: the fragment's version is not a number: $version" >&2; exit 1 ;;
esac
if [ "$version" -lt 12 ]; then
  echo "FAIL: the fragment's version is $version; the body naming docs/backlog/ is version 12 or later" >&2
  exit 1
fi
