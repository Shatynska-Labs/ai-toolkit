#!/usr/bin/env bash
# Scenario: Both tools agree on whether a block is present.
# Requirement: A stale block nobody edited is replaced, and nothing outside
# its markers changes. Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: where a target holds a line beginning `<!-- ai-toolkit:<name> `
# in any of the forms the classification names, well-formed or not,
# project-init reports the block present exactly where project-update
# reports a state other than absent.
# DERIVED (forms): on the backlog target — hashed current, `v12`, `1.0` with
# a hash, `1.0.0` without one, a bare prefix, and two controls a reader
# without the trailing space would misread: no marker, and
# `<!-- ai-toolkit:backlog-old 1.0.0 -->`. Each fixture is a committed
# repository, so a v12 block is converted rather than blocked.
# DERIVED (token): project-init's present is its backlog line stating
# `already present` (tests/README.md's report contract); project-update's
# absent is its backlog line stating `absent`.
#
# Executes both tools. Red until tasks 1.2 and 2.1 land (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
require_update "$PROJECT_UPDATE"
hex="$(printf 'x\n' | sha256_of)"
i=0
check() {  # MARKER-OR-EMPTY
  i=$((i + 1))
  local base="$TESTDIR/base-$i" t pi pu
  t="$(target_of backlog)"
  mkdir -p "$(dirname "$base/$t")"
  if [ -n "$1" ]; then
    printf '%s\nsome rules\n<!-- /ai-toolkit:backlog -->\n' "$1" > "$base/$t"
  else
    printf '# Our backlog notes\n' > "$base/$t"
  fi
  git_fixture "$base"
  cp -R "$base" "$TESTDIR/init-$i"
  cp -R "$base" "$TESTDIR/upd-$i"
  (cd "$TESTDIR/init-$i" && bash "$PROJECT_INIT") >"$TESTDIR/init-$i.txt" 2>&1
  (cd "$TESTDIR/upd-$i" && bash "$PROJECT_UPDATE") >"$TESTDIR/upd-$i.txt" 2>&1
  pi=absent; rline "$TESTDIR/init-$i.txt" backlog | grep -q -i -F 'already present' && pi=present
  pu=absent
  [ -n "$(rline "$TESTDIR/upd-$i.txt" backlog)" ] || { echo "FAIL: project-update reports no backlog line for: ${1:-no marker}" >&2; cat "$TESTDIR/upd-$i.txt" >&2; exit 1; }
  rline "$TESTDIR/upd-$i.txt" backlog | grep -q -i -w 'absent' || pu=present
  [ "$pi" = "$pu" ] || { echo "FAIL: for '${1:-no marker}', project-init says $pi and project-update says $pu" >&2; exit 1; }
}
work0="$TESTDIR/hashed"
mkdir -p "$work0"
put_block "$work0" backlog "$(fversion backlog)" "current text"
check "$(head -n 1 "$work0/$(target_of backlog)")"
check "<!-- ai-toolkit:backlog v12 -->"
check "<!-- ai-toolkit:backlog 1.0 sha256:$hex -->"
check "<!-- ai-toolkit:backlog 1.0.0 -->"
check "<!-- ai-toolkit:backlog "
check ""
check "<!-- ai-toolkit:backlog-old 1.0.0 -->"
