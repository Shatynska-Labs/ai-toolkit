#!/usr/bin/env bash
# Scenario: Kind, need and a typed condition
# Requirement: The tool reports the board as JSON
# Change: report-a-tasks-kind-and-wait (task-board, MODIFIED).
#
# SPECIFIED: an entry carrying kind: change, need: must, waits_for: "the head's
# answer" and waits_for_type: [answer] gives kind "change", need "must",
# waits_for "the head's answer" and waits_for_type ["answer"].
# SPECIFIED (the requirement's body, no scenario of its own): parked_until is the
# entry's string; a value is given as the entry writes it, unchecked against the
# README's sets, as priority is; waits_for_type is a list of every type written.
#
# Runs the tool; red until scripts/task-board reports the new fields (task 3.2).
# shellcheck disable=SC1090,SC1091 # $TESTLIB is set by tests/run.sh
source "$TESTLIB"
source "${TESTLIB%/*}/task-board-lib.sh"

# ---- local arrangement (test-plan.md, Missing shared arrangement)
STDOUT="$TESTDIR/stdout"
STDERR="$TESTDIR/stderr"
# board_json [ARG...]: runs the tool from $P with its streams apart; $RC.
board_json() {
  [ -f "$BOARD" ] || die "target absent — $BOARD does not exist yet"
  RC=0
  ( cd "$P" && "$BOARD" "$@" ) > "$STDOUT" 2> "$STDERR" || RC=$?
}
# jv PATH: a value of the document as compact JSON, keys sorted, by python3 or
# else jq. PATH is dotted; key:NAME picks the list element of that name, # is a
# length, @ an object's sorted keys. A key or name that is absent is an error.
jv() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import json, sys
v = json.load(open(sys.argv[1], encoding="utf-8"))
for s in sys.argv[2].split("."):
    k, _, n = s.partition(":")
    if s == "#": v = len(v)
    elif s == "@": v = sorted(v)
    else:
        v = v[k]
        if n: v = next(t for t in v if t["name"] == n)
out = json.dumps(v, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
sys.stdout.buffer.write((out + "\n").encode("utf-8"))' "$STDOUT" "$1"
  else
    jq -cS --arg p "$1" 'reduce ($p | split("."))[] as $s (.;
      if $s == "#" then length elif $s == "@" then keys else
        ($s | split(":")) as [$k, $n]
        | (if has($k) then .[$k] else error("absent: " + $k) end)
        | if $n then (map(select(.name == $n)) | if length > 0 then .[0] else error("no name: " + $n) end) else . end
      end)' "$STDOUT"
  fi
}
require_parser() {
  command -v python3 >/dev/null 2>&1 || command -v jq >/dev/null 2>&1 \
    || die "neither python3 nor jq is present, so the document cannot be parsed"
}
# doc: runs the tool with --json, which must succeed and parse.
doc() {
  require_parser
  board_json --json
  assert_exit 0 "$RC" "stderr: $(cat "$STDERR")"
  jv schema_version > /dev/null || die "standard output is not the document: $(head -c 300 "$STDOUT")"
}
# jis PATH JSON: the value at PATH is exactly JSON.
jis() {
  local got
  got="$(jv "$1")" || die "cannot read $1"
  [ "$got" = "$2" ] || die "$1 is [$got], expected [$2]"
}

# entry_raw NAME [FRONTMATTER_LINE...]: an entry whose frontmatter is exactly
# the lines given, for a kind other than change; task-board-lib.sh's entry
# always writes `kind: change` first.
entry_raw() {
  local n="$1" l; shift
  { echo '---'; for l in "$@"; do printf '%s\n' "$l"; done; echo '---'; echo; echo 'The entry body.'; } \
    > "$P/docs/backlog/$n.md"
}

# ---- the case
project_new
entry an-entry 'need: must' 'waits_for: "the head'"'"'s answer"' 'waits_for_type: [answer]'
entry a-parked 'priority: parked' 'parked_until: "the vendor ships v2"'
entry_raw an-odd 'kind: chore' 'need: maybe' 'waits_for: "a release and a word"' 'waits_for_type: [release, decision]'
save
doc
jis tasks:an-entry.kind '"change"'
jis tasks:an-entry.need '"must"'
jis tasks:an-entry.waits_for '"the head'"'"'s answer"'
jis tasks:an-entry.waits_for_type '["answer"]'
jis tasks:a-parked.parked_until '"the vendor ships v2"'
jis tasks:an-odd.kind '"chore"'
jis tasks:an-odd.need '"maybe"'
jis tasks:an-odd.waits_for_type '["release","decision"]'
