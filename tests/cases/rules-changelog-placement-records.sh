#!/usr/bin/env bash
# No delta scenario: design.md decision 8.
# Change: match-backlog-entries-to-a-workstream.
#
# SPECIFIED (design, not a spec): `rules/changelog` takes one record per fragment,
# none with an `ask`: backlog 1.1.0, workstreams 2.1.0, development-workflow 2.1.0
# and development-workflow-direct 1.1.0.
# DERIVED (operationalisation): the records rather than the fragments' `version`
# keys are read, because a record stands after a later rise and a pinned `version`
# does not: that pin is what makes the [full-version] assertion of
# manifest-alternative-and-versions.sh obsolete here.
#
# Static read (third situation); the check runs over fixtures first. Red at
# authoring on [record] (state 1 on real content); goes green as task 1.4 lands.
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement: changelog_records).
# changelog_records FILE: one line "<name> <version> <asks>" per record.
changelog_records() {
  awk '
    function flush() { if (n != "" || v != "") print n " " v " " a + 0; n = ""; v = ""; a = 0 }
    /^---[[:space:]]*$/ { flush(); next }
    /^name:/ { n = $0; sub(/^name:[[:space:]]*/, "", n); sub(/[[:space:]]*$/, "", n) }
    /^version:/ { v = $0; sub(/^version:[[:space:]]*/, "", v); sub(/[[:space:]]*$/, "", v) }
    /^ask:/ { a++ }
    END { flush() }
  ' "$1"
}

check() {  # CHANGELOG
  local recs pair
  [ -f "$1" ] || { echo "UNREADABLE: $1 is absent" >&2; return 2; }
  recs="$(changelog_records "$1")"
  for pair in 'backlog 1.1.0' 'workstreams 2.1.0' 'development-workflow 2.1.0' 'development-workflow-direct 1.1.0'; do
    if ! printf '%s\n' "$recs" | grep -q -E "^$pair [0-9]+\$"; then
      echo "[record] rules/changelog holds no record of $pair" >&2
      return 1
    fi
    if ! printf '%s\n' "$recs" | grep -q -x -F "$pair 0"; then
      echo "[no-ask] the record of $pair carries an ask" >&2
      return 1
    fi
  done
}

record() { printf 'name: %s\nversion: %s\nchanged: a thing\n' "$1" "$2"; }
fixture="$TESTDIR/changelog"
{
  record backlog 1.1.0; printf -- '---\n'
  record workstreams 2.1.0; printf -- '---\n'
  record development-workflow 2.1.0; printf -- '---\n'
  record development-workflow-direct 1.1.0
} > "$fixture"
out="$(check "$fixture" 2>&1)" || { echo "FAIL: discriminator — the check rejected the conforming fixture: $out" >&2; exit 1; }

expect() {  # TAG FILE
  local st
  out="$(check "$2" 2>&1)"; st=$?
  [ "$st" -eq 1 ] && case "$out" in *"[$1]"*) return 0 ;; esac
  echo "FAIL: discriminator — expected [$1], status $st: $out" >&2
  exit 1
}
grep -v -E '^version: 1[.]1[.]0$' "$fixture" > "$fixture.no-record"
expect record "$fixture.no-record"
sed 's/^name: workstreams$/name: workstreams\nask: edit something by hand/' "$fixture" > "$fixture.ask"
expect no-ask "$fixture.ask"

check "$TOOLKIT_ROOT/rules/changelog" || exit 1
