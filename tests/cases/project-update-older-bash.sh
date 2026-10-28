#!/usr/bin/env bash
# Scenario: An older bash.
# Requirement: The update tool is a standalone executable beside project-init.
# Change: update-managed-block (project-update, ADDED).
#
# SPECIFIED: under bash 3.2 the tool classifies and replaces blocks as it does
# under a newer bash.
# Two halves, after backlog-migrate-older-bash.sh (its scan is declared here
# again, since a test module imports from no other):
# - Run half: where a bash 3.2 is found ($BASH32, `bash3.2`, `bash-3.2`, or
#   /bin/bash reporting 3.2), the same project — current, stale and edited
#   blocks — is updated under it and under the current bash; the trees and the
#   reports past the target line must be identical. No bash 3.2 is installed
#   where this pass was written, so that half was not executed here
#   (test-plan.md).
# - Static half (DERIVED proxy): the `#!/usr/bin/env bash` shebang, and a scan
#   of the source for constructs bash 3.2 lacks, checked first against a
#   fixture carrying each construct (the fixture-driven discriminator).
#
# Third situation for the static half. Red until task 1.1 lands (state 2).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"
# shellcheck source=tests/cases/lib/managed-block.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/managed-block.sh"
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
clean="$TESTDIR/clean.sh"
# shellcheck disable=SC2016 # literal fixture text
printf '%s\n' '#!/usr/bin/env bash' 'set -euo pipefail' 'names=(a b)' 'for n in "${names[@]}"; do echo "$n"; done' '# declare -A in a comment is not code' > "$clean"
[ -z "$(bash4_hits "$clean")" ] || { echo "FAIL: discriminator — the scan rejects bash 3.2 code" >&2; exit 1; }
for i in "${!SPECIMENS[@]}"; do
  printf '%s\n' '#!/usr/bin/env bash' "${SPECIMENS[$i]}" > "$TESTDIR/specimen-$i.sh"
  case "$(bash4_hits "$TESTDIR/specimen-$i.sh")" in
    *"[$i]"*) ;;
    *) echo "FAIL: discriminator — the scan misses: ${SPECIMENS[$i]}" >&2; exit 1 ;;
  esac
done

require_update "$PROJECT_UPDATE"
[ "$(head -n 1 "$PROJECT_UPDATE")" = '#!/usr/bin/env bash' ] || { echo "FAIL: the tool does not declare #!/usr/bin/env bash" >&2; exit 1; }
hits="$(bash4_hits "$PROJECT_UPDATE")"
if [ -n "$hits" ]; then
  echo "FAIL: the tool uses constructs bash 3.2 lacks:" >&2
  for i in $hits; do i="${i#[}"; i="${i%]}"; echo "  /${PATTERNS[$i]}/" >&2; done
  exit 1
fi

old=""
for candidate in "${BASH32:-}" bash3.2 bash-3.2 /bin/bash; do
  [ -n "$candidate" ] || continue
  command -v "$candidate" >/dev/null 2>&1 || continue
  # shellcheck disable=SC2016 # expanded by the candidate shell
  case "$("$candidate" -c 'echo "${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"' 2>/dev/null)" in
    3.2) old="$candidate"; break ;;
  esac
done
[ -n "$old" ] || exit 0

for shell in new old; do
  w="$TESTDIR/work-$shell"
  mkdir -p "$w"
  seed_all "$w" stale
  edit_inside "$w/$(target_of backlog)" backlog "a line the project changed"
done
(cd "$TESTDIR/work-new" && bash "$PROJECT_UPDATE") >"$TESTDIR/report-new.txt" 2>&1
s_new=$?
(cd "$TESTDIR/work-old" && "$old" "$PROJECT_UPDATE") >"$TESTDIR/report-old.txt" 2>&1
s_old=$?
assert_exit "$s_new" "$s_old" "the exit code under bash 3.2"
[ "$(tree_sum "$TESTDIR/work-new")" = "$(tree_sum "$TESTDIR/work-old")" ] || { echo "FAIL: bash 3.2 leaves a different tree" >&2; exit 1; }
diff <(tail -n +2 "$TESTDIR/report-new.txt") <(tail -n +2 "$TESTDIR/report-old.txt") >&2 || { echo "FAIL: bash 3.2 reports differently" >&2; exit 1; }
