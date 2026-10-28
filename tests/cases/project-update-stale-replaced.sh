#!/usr/bin/env bash
# Scenario: A stale block is brought current.
# Requirement: A stale block nobody edited is replaced, and nothing outside
# its markers changes. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: after the run, a stale untouched block's opening marker carries
# the fragment's version and a hash equal to the digest of the lines between
# the markers, the lines after the notice are the fragment's body byte for
# byte, and the report states both versions.
# DERIVED (operationalisation): every manifest record is stale; the body is
# located as the block's last lines, as many as the fragment's body has
# (after block-marker-version-and-body.sh); the stale text is gone.
#
# Executes the tool. Red until task 1.3 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
work="$TESTDIR/work"
mkdir -p "$work"
seed_all "$work" stale
(cd "$work" && bash "$PROJECT_UPDATE") >"$TESTDIR/report.txt" 2>&1
n=0
while read -r name target; do
  [ -n "$name" ] || continue
  n=$((n + 1))
  f="$work/$target"
  want="$(fversion "$name")"
  [ "$(marker_version "$f" "$name")" = "$want" ] || { echo "FAIL: $name's marker does not carry $want" >&2; cat "$f" >&2; exit 1; }
  hash_ok "$f" "$name" || { echo "FAIL: $name's hash is not the digest of its lines" >&2; exit 1; }
  frag_body "$TOOLKIT_ROOT/rules/$name.md" > "$TESTDIR/$name.expected"
  block_body "$f" "$name" > "$TESTDIR/$name.block"
  bl="$(grep -c '' "$TESTDIR/$name.expected")"
  [ "$bl" -gt 0 ] || { echo "FAIL: the fragment $name has an empty body" >&2; exit 1; }
  tail -n "$bl" "$TESTDIR/$name.block" > "$TESTDIR/$name.actual"
  cmp -s "$TESTDIR/$name.expected" "$TESTDIR/$name.actual" || { echo "FAIL: $name's block does not end with the fragment's body" >&2; exit 1; }
  if grep -q -F "the stale text of $name" "$f"; then echo "FAIL: $name's stale text survives" >&2; exit 1; fi
  expect_line "$TESTDIR/report.txt" "$name" "$(lower_version "$want")" "$want"
done <<< "$(records)"
[ "$n" -gt 0 ] || { echo "FAIL: target absent — the manifest lists no record" >&2; exit 1; }
