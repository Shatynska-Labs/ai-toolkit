#!/usr/bin/env bash
# Scenario: An older bash.
# Requirement: The tool locates its resources itself and runs where
# project-init runs. Change: one-file-per-backlog-entry (backlog-migration,
# ADDED).
#
# SPECIFIED: under bash 3.2 the tool converts a backlog as it does under a
# newer bash; it declares `#!/usr/bin/env bash` and uses no construct
# unavailable in bash 3.2.
# Two halves:
# - Run half: where a bash 3.2 is found ($BASH32, `bash3.2`, `bash-3.2`, or
#   /bin/bash reporting 3.2), the same backlog is converted under it and under
#   the current bash, and the two docs/backlog/ trees must be identical. No
#   bash 3.2 is installed where this pass was written, so that half was not
#   executed here (recorded in test-plan.md); the case prints nothing about
#   it on success.
# - Static half (DERIVED proxy): the shebang, and a scan of the tool's source
#   for constructs bash 3.2 lacks — associative arrays, case-modifying
#   expansions, mapfile/readarray, `|&`, `&>>`, coproc, namerefs, negative
#   subscripts, `;&`/`;;&`, `${var@op}`. The scan is checked against a
#   fixture carrying each construct, so it cannot pass by reading nothing.
#
# Third situation for the static half (a read of the source); red until task
# 2.1 lands (state 2: the source is absent).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

MIGRATE="$TOOLKIT_ROOT/scripts/backlog-migrate"

# Local arrangement (test-plan.md, Missing shared arrangement: the migrate
# fixture helpers). tests/lib.sh holds no git fixture and no frontmatter
# reader, and a test module imports from no other test module.
#
# require_migrate: the target-absent guard. A BLOCKED case asserts a non-zero
# exit, which a missing script (127) would satisfy vacuously.
require_migrate() {
  [ -f "$MIGRATE" ] && return 0
  echo "FAIL: target absent — $MIGRATE does not exist yet" >&2
  exit 1
}
# new_repo DIR: a git repository at DIR whose docs/backlog.md is stdin,
# committed together with everything already under DIR.
new_repo() {
  local dir="$1"
  mkdir -p "$dir/docs"
  cat > "$dir/docs/backlog.md"
  git -C "$dir" init -q >/dev/null 2>&1 || { echo "FAIL: git init failed in $dir" >&2; exit 1; }
  git -C "$dir" config user.email t@t.com
  git -C "$dir" config user.name t
  git -C "$dir" add -A
  git -C "$dir" commit -q -m fixture >/dev/null || { echo "FAIL: fixture commit failed in $dir" >&2; exit 1; }
}
# fm_value FILE KEY: the value of KEY in FILE's leading frontmatter, or nothing.
fm_value() {
  awk -v key="$2" '
    NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { exit }
    index($0, key ":") == 1 { v = substr($0, length(key) + 2); sub(/^ /, "", v); print v; exit }
  ' "$1"
}
# fm_keys FILE: the keys of FILE's leading frontmatter, one per line.
fm_keys() {
  awk 'NR == 1 { if ($0 != "---") exit; next } $0 == "---" { exit } { k = $0; sub(/:.*/, "", k); print k }' "$1"
}
# fm_body FILE: everything after FILE's leading frontmatter.
fm_body() {
  awk 'NR == 1 && $0 == "---" { infm = 1; next } infm { if ($0 == "---") infm = 0; next } { print }' "$1"
}
# The reader is checked on a specimen first, so a pass cannot come from a
# reader that reads nothing.
check_reader() {
  local s="$TESTDIR/reader-specimen.md"
  printf '%s\n' '---' 'priority: normal' 'waits_on: [a, b]' '---' 'kind: change' 'Body text.' > "$s"
  if [ "$(fm_value "$s" waits_on)" = "[a, b]" ] && [ -z "$(fm_value "$s" kind)" ] \
    && [ "$(fm_keys "$s" | tr '\n' ' ')" = "priority waits_on " ] \
    && [ "$(fm_body "$s" | head -n 1)" = "kind: change" ]; then
    return 0
  fi
  echo "FAIL: discriminator — the local frontmatter reader misreads its specimen" >&2
  exit 1
}
# assert_untouched WORK SUM: docs/backlog.md as it was, and nothing beside it.
assert_untouched() {
  local work="$1" sum="$2" listing
  assert_unchanged "$work/docs/backlog.md" "$sum" "docs/backlog.md is left as it was"
  assert_file_absent "$work/docs/backlog" "no docs/backlog/ is written"
  listing="$(ls -A "$work/docs")"
  if [ "$listing" != "backlog.md" ]; then
    echo "FAIL: docs/ holds more than backlog.md after the run:" >&2
    printf '%s\n' "$listing" >&2
    exit 1
  fi
}

# The patterns, one per construct; matched with grep -E on lines with the
# leading comment stripped.
PATTERNS=(
  'declare[[:space:]]+-[a-zA-Z]*A|local[[:space:]]+-[a-zA-Z]*A|typeset[[:space:]]+-[a-zA-Z]*A'
  '\$\{[A-Za-z_][A-Za-z0-9_]*(\[[^]]*\])?(,,?|\^\^?)[^}]*\}'
  '(^|[^A-Za-z_])(mapfile|readarray)([^A-Za-z_]|$)'
  '\|&'
  '&>>'
  '(^|[^A-Za-z_])coproc([^A-Za-z_]|$)'
  '(declare|local|typeset)[[:space:]]+-[a-zA-Z]*n'
  '\$\{[A-Za-z_][A-Za-z0-9_]*\[-[0-9]+\]\}'
  ';;&|;&'
  '\$\{[A-Za-z_][A-Za-z0-9_]*@[QEPAKa]\}'
)
# shellcheck disable=SC2016 # each specimen is literal source text, not an expansion
SPECIMENS=(
  'declare -A seen'
  'lower=${name,,}'
  'mapfile -t lines < file'
  'cmd |& tee log'
  'echo x &>> log'
  'coproc worker { cat; }'
  'local -n ref=name'
  'last=${items[-1]}'
  '  a) echo a ;;&'
  'echo ${name@Q}'
)

bash4_hits() {
  local file="$1" i out=""
  for i in "${!PATTERNS[@]}"; do
    if sed -e 's/^[[:space:]]*#.*$//' "$file" | grep -q -E -- "${PATTERNS[$i]}"; then
      out="$out [$i]"
    fi
  done
  printf '%s' "$out"
}

# Discriminator.
clean="$TESTDIR/clean.sh"
# shellcheck disable=SC2016 # backticks and $ are literal text in a pattern or fixture
printf '%s\n' '#!/usr/bin/env bash' 'set -euo pipefail' 'names=(a b)' 'for n in "${names[@]}"; do echo "$n"; done' '# declare -A in a comment is not code' > "$clean"
[ -z "$(bash4_hits "$clean")" ] || { echo "FAIL: discriminator — the scan rejects bash 3.2 code: $(bash4_hits "$clean")" >&2; exit 1; }
for i in "${!SPECIMENS[@]}"; do
  printf '%s\n' '#!/usr/bin/env bash' "${SPECIMENS[$i]}" > "$TESTDIR/specimen-$i.sh"
  case "$(bash4_hits "$TESTDIR/specimen-$i.sh")" in
    *"[$i]"*) ;;
    *) echo "FAIL: discriminator — the scan misses: ${SPECIMENS[$i]}" >&2; exit 1 ;;
  esac
done

require_migrate
[ "$(head -n 1 "$MIGRATE")" = '#!/usr/bin/env bash' ] || { echo "FAIL: the tool does not declare #!/usr/bin/env bash" >&2; exit 1; }
hits="$(bash4_hits "$MIGRATE")"
if [ -n "$hits" ]; then
  echo "FAIL: the tool uses constructs bash 3.2 lacks:" >&2
  for i in $hits; do i="${i#[}"; i="${i%]}"; echo "  /${PATTERNS[$i]}/" >&2; done
  exit 1
fi

# Run half, where a bash 3.2 is available.
old=""
for candidate in "${BASH32:-}" bash3.2 bash-3.2 /bin/bash; do
  [ -n "$candidate" ] || continue
  command -v "$candidate" >/dev/null 2>&1 || continue
  # shellcheck disable=SC2016 # the version is expanded by the candidate shell, not this one
  case "$("$candidate" -c 'echo "${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"' 2>/dev/null)" in
    3.2) old="$candidate"; break ;;
  esac
done
[ -n "$old" ] || exit 0

for shell in new old; do
  work="$TESTDIR/work-$shell"
  new_repo "$work" <<'BACKLOG'
# Backlog

## `alpha-change`

What alpha is and why.

- **Priority**: parked until a second brand is onboarded
- **Kind**: change, because it owes a delta.
- **Waits on**: nothing
- **Must not undo**: the pinned name
BACKLOG
done
(cd "$TESTDIR/work-new" && bash "$MIGRATE") >"$TESTDIR/report-new.txt" 2>&1
assert_exit 0 "$?" "the conversion under the current bash"
(cd "$TESTDIR/work-old" && "$old" "$MIGRATE") >"$TESTDIR/report-old.txt" 2>&1
assert_exit 0 "$?" "the conversion under bash 3.2"
diff -r "$TESTDIR/work-new/docs/backlog" "$TESTDIR/work-old/docs/backlog" >&2 \
  || { echo "FAIL: bash 3.2 converts the backlog differently" >&2; exit 1; }
