#!/usr/bin/env bash
# Scenario: The replacement is project-init's block.
# Requirement: A stale block nobody edited is replaced, and nothing outside
# its markers changes. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: the lines from the replaced block's opening to its closing marker
# equal those project-init writes from the same fragment into a new project,
# for every fragment the manifest lists and for a fragment whose body contains
# a `---` line and ends without a newline, both with sha256sum available and
# with only shasum.
# DERIVED (fixture): the edge fragment is the copy's backlog.md with those two
# properties appended; "only shasum" is a PATH of links to every command but
# sha256sum (both tools run under it).
#
# Executes both tools. Red until task 1.3 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
command -v shasum >/dev/null 2>&1 || { echo "FAIL: fixture — no shasum on this host; the shasum-only half cannot run" >&2; exit 1; }
edge="$TESTDIR/edge"
toolkit_copy "$edge"
printf '\n---\n\nThe last line, with no newline.' >> "$edge/rules/backlog.md"
bin="$TESTDIR/bin"
mkdir -p "$bin"
IFS=: read -r -a dirs <<< "$PATH"
for d in "${dirs[@]}"; do
  [ -d "$d" ] || continue
  for c in "$d"/*; do
    n="${c##*/}"
    [ "$n" = sha256sum ] && continue
    [ -x "$c" ] && [ ! -e "$bin/$n" ] && ln -s "$c" "$bin/$n"
  done
done
PATH="$bin" command -v sha256sum >/dev/null 2>&1 && { echo "FAIL: fixture — sha256sum is still reachable" >&2; exit 1; }

compare() {  # LABEL ROOT PATHVALUE
  local label="$1" root="$2" p="$3" init="$TESTDIR/init-$1" upd="$TESTDIR/upd-$1" name target n=0
  mkdir -p "$init" "$upd"
  (cd "$init" && PATH="$p" bash "$root/scripts/project-init") >"$TESTDIR/init-$label.txt" 2>&1
  assert_exit 0 "$?" "fixture — project-init ($label)"
  seed_all "$upd" stale "$root"
  (cd "$upd" && PATH="$p" bash "$root/scripts/project-update") >"$TESTDIR/upd-$label.txt" 2>&1
  while read -r name target; do
    [ -n "$name" ] || continue
    n=$((n + 1))
    block_lines "$init/$target" "$name" > "$TESTDIR/$label-$name.init"
    block_lines "$upd/$target" "$name" > "$TESTDIR/$label-$name.upd"
    [ -s "$TESTDIR/$label-$name.init" ] || { echo "FAIL: fixture — project-init wrote no $name block ($label)" >&2; exit 1; }
    cmp -s "$TESTDIR/$label-$name.init" "$TESTDIR/$label-$name.upd" || {
      echo "FAIL: $label: the $name block project-update wrote differs from project-init's" >&2
      diff "$TESTDIR/$label-$name.init" "$TESTDIR/$label-$name.upd" | head -n 20 >&2
      exit 1
    }
  done <<< "$(records "$root")"
  [ "$n" -gt 0 ] || { echo "FAIL: target absent — the manifest lists no record" >&2; exit 1; }
}
compare sha256sum "$TOOLKIT_ROOT" "$PATH"
compare edge-sha256sum "$edge" "$PATH"
compare shasum "$TOOLKIT_ROOT" "$bin"
compare edge-shasum "$edge" "$bin"
