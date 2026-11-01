#!/usr/bin/env bash
# Scenario: A difference outside ship fails; The test cannot pass vacuously; The fragments as shipped differ only as stated (and, mechanically, A session obligation is stated once).
# Requirement: The two workflows differ only in what states ship
# Change: add-a-direct-workflow-variant (session-workflow, ADDED).
#
# SPECIFIED: compare_fragments takes two paths. Outside `### ship` the bodies are byte-identical except three lines that differ (the paragraph stating work too small to be a change, the paragraph stating what the rules assume, the `ship:` line of the stage list) and one paragraph only the promoting fragment holds, directly after the paragraph stating the derivation of a state. Any other difference fails naming the line; a file with no `### ship` section fails; the shipped pair passes.
# DERIVED: paragraphs are told apart by a word each must hold on both sides: `too small to be a change`, `assum`, a leading `ship:`; the derivation paragraph is the one before the added paragraph and holds `transition`. These selectors are this test's reading, not the specification's wording, so a compliant text missing one is a derived assertion to reconsider. Over the shipped pair each allowance must be used once, since the requirement says the three lines do differ.
#
# Static read (third situation); the comparison is proven over fixtures first, which run and pass today. Red on the shipped pair until tasks 1.1 and 1.2 land (first situation: the direct fragment is absent).
# shellcheck disable=SC1090 # $TESTLIB is set by tests/run.sh at runtime, not statically resolvable
source "$TESTLIB"

# Local arrangement (test-plan.md, Missing shared arrangement: the static
# readers). frag_body FILE: everything after the frontmatter's closing line.
frag_body() {
  awk 'NR == 1 && $0 == "---" { f = 1; next } f == 1 && $0 == "---" { f = 2; next } f == 2 { print }' "$1"
}
# frag_key FILE KEY: KEY's value in FILE's leading frontmatter, or nothing.
frag_key() {
  awk -v k="$2" '
    NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { exit }
    index($0, k ":") == 1 { v = substr($0, length(k) + 2); sub(/^[[:space:]]*/, "", v); sub(/[[:space:]]*$/, "", v); print v; exit }
  ' "$1" 2>/dev/null
}
# split_ship FILE ship|rest: the body's `### ship` section, heading included,
# or everything else. The section ends at the next heading of level three or
# higher outside a fence.
split_ship() {
  frag_body "$1" | awk -v mode="$2" '
    /^(```|~~~)/ { fence = !fence }
    !fence && /^##?#? / { in_ship = ($0 == "### ship") }
    (mode == "ship") == (in_ship == 1) { print }
  '
}
# shellcheck disable=SC2034 # each case reads the fragments it needs
FRAGMENT_FULL="$TOOLKIT_ROOT/rules/development-workflow.md"
# shellcheck disable=SC2034 # each case reads the fragments it needs
FRAGMENT_DIRECT="$TOOLKIT_ROOT/rules/development-workflow-direct.md"
# need TAG REGEX...: a scan; one line of what is scanned must match every
# REGEX, an extended expression matched without regard to case.
SCANS=()
need() { local IFS=$'\t'; SCANS+=("$*"); }
# scan_lines TEXTFILE: 0 where every scan holds; each failure prints [TAG].
scan_lines() {
  local spec tag re lines bad=0
  local -a parts
  for spec in "${SCANS[@]}"; do
    IFS=$'\t' read -r -a parts <<< "$spec"
    tag="${parts[0]}"
    lines="$(cat "$1")"
    for re in "${parts[@]:1}"; do
      lines="$(printf '%s\n' "$lines" | grep -i -E -- "$re")"
    done
    [ -n "$lines" ] || { echo "[$tag] no line states this" >&2; bad=1; }
  done
  return "$bad"
}
# discriminate_scans FIXTURE: the fixture passes, and each scan fails with its
# own tag once the lines its first expression selects are removed.
discriminate_scans() {
  local fixture="$1" spec tag out st
  local -a parts
  out="$(scan_lines "$fixture" 2>&1)" || { echo "FAIL: discriminator — the conforming fixture fails: $out" >&2; exit 1; }
  for spec in "${SCANS[@]}"; do
    IFS=$'\t' read -r -a parts <<< "$spec"
    tag="${parts[0]}"
    grep -v -i -E -- "${parts[1]}" "$fixture" > "$fixture.mutant"
    out="$(scan_lines "$fixture.mutant" 2>&1)"; st=$?
    [ "$st" -eq 1 ] && case "$out" in *"[$tag]"*) continue ;; esac
    echo "FAIL: discriminator — removing what [$tag] reads did not fail it (status $st): $out" >&2
    exit 1
  done
}
# compare_fragments FULL DIRECT: task 1.4's comparison. Sets SEEN to the
# allowances used. Returns 1 with a [tag] and the line on any other difference.
SEEN=""
seen_once() {  # ALLOWANCE LINE
  case " $SEEN " in
    *" $1 "*) echo "[outside-ship] a second $1 difference: $2" >&2; return 1 ;;
  esac
  SEEN="$SEEN $1"
}
compare_fragments() {
  local full="$1" direct="$2" t="$TESTDIR/cmp" hunk l r r1 r2 a b p prior i
  SEEN=""
  mkdir -p "$t"
  [ -n "$(split_ship "$full" ship)" ] || { echo "[no-ship] $full has no ### ship section" >&2; return 1; }
  [ -n "$(split_ship "$direct" ship)" ] || { echo "[no-ship] $direct has no ### ship section" >&2; return 1; }
  split_ship "$full" rest > "$t/full"
  split_ship "$direct" rest > "$t/direct"
  while IFS= read -r hunk; do
    case "$hunk" in
      *c*)
        l="${hunk%c*}"; r="${hunk#*c}"
        case "$l$r" in *,*) echo "[outside-ship] more than one line differs at $hunk: $(sed -n "${r%%,*}p" "$t/full")" >&2; return 1 ;; esac
        a="$(sed -n "${r}p" "$t/full")"; b="$(sed -n "${l}p" "$t/direct")"
        if [[ "$a" == ship:* && "$b" == ship:* ]]; then seen_once ship "$a" || return 1
        elif [[ "$a" == *"too small to be a change"* && "$b" == *"too small to be a change"* ]]; then seen_once small "$a" || return 1
        elif printf '%s\n' "$a" | grep -q -i assum && printf '%s\n' "$b" | grep -q -i assum; then seen_once assume "$a" || return 1
        else echo "[outside-ship] line differs: $a" >&2; return 1
        fi
        ;;
      *a*)
        r="${hunk#*a}"; r1="${r%%,*}"; r2="${r##*,}"
        [ "$((r2 - r1))" -eq 1 ] || { echo "[outside-ship] lines only the promoting fragment holds at $hunk: $(sed -n "${r1}p" "$t/full")" >&2; return 1; }
        a="$(sed -n "${r1}p" "$t/full")"; b="$(sed -n "${r2}p" "$t/full")"
        if [ -z "$a" ] && [ -n "$b" ]; then p="$b"; i="$r2"
        elif [ -n "$a" ] && [ -z "$b" ]; then p="$a"; i="$r1"
        else echo "[outside-ship] not one paragraph at $hunk: $a" >&2; return 1
        fi
        prior="$(head -n $((i - 1)) "$t/full" | grep -v '^$' | tail -n 1)"
        printf '%s\n' "$prior" | grep -q -i transition || { echo "[outside-ship] the added paragraph does not follow the derivation: $p" >&2; return 1; }
        seen_once added "$p" || return 1
        ;;
      *)
        echo "[outside-ship] line only the direct fragment holds: $(sed -n "${hunk%%d*}p" "$t/direct" | grep -v '^$' | head -n 1)" >&2
        return 1
        ;;
    esac
  done < <(diff "$t/direct" "$t/full" | grep -E '^[0-9]+(,[0-9]+)?[acd][0-9]+(,[0-9]+)?$')
  return 0
}
expect() {  # pass|TEXT FULL DIRECT: TEXT must be in the failure's message.
  local out st
  out="$(compare_fragments "$2" "$3" 2>&1)"; st=$?
  if [ "$1" = pass ]; then [ "$st" -eq 0 ] && return 0
  else [ "$st" -eq 1 ] && case "$out" in *"$1"*) return 0 ;; esac
  fi
  echo "FAIL: discriminator — expected $1, status $st: $out" >&2
  exit 1
}
fx="$TESTDIR/fx"
mkdir -p "$fx"
cat > "$fx/full" <<'FIXTURE'
---
kind: standing-constraint
version: 2.0.0
alternative_since: 2.0.0
---
# Workflow

Work too small to be a change skips plan, and reaches production by merging and a promotion.

These rules assume a remote and a staging deploy triggered by merging.

```
plan:   explore
ship:   open pr · merge · deploy staging · confirm · promote · deploy production · smoke · archive
```

A state is the transition with -ing while it runs.

The two deploy transitions name their host.

The family prefix is always written.

### build

Apply, then verify.

### ship

Merge, deploy staging, confirm, promote.

## Afterwards

Tear down.
FIXTURE
cat > "$fx/direct" <<'FIXTURE'
---
kind: standing-constraint
version: 1.0.0
---
# Workflow

Work too small to be a change skips plan, and reaches production by merging.

These rules assume a remote and that merging to the trunk deploys.

```
plan:   explore
ship:   open pr · merge · deploy · confirm · archive
```

A state is the transition with -ing while it runs.

The family prefix is always written.

### build

Apply, then verify.

### ship

Merge, deploy, confirm.

## Afterwards

Tear down.
FIXTURE
expect pass "$fx/full" "$fx/direct"
compare_fragments "$fx/full" "$fx/direct" || exit 1
for allowance in ship small assume added; do
  case " $SEEN " in *" $allowance "*) ;; *) echo "FAIL: discriminator — the fixture did not use $allowance: $SEEN" >&2; exit 1 ;; esac
done

# A difference outside ship fails, naming the line.
sed 's/^Apply, then verify\.$/Apply, then check it twice./' "$fx/full" > "$fx/build"
expect 'Apply, then check it twice.' "$fx/build" "$fx/direct"
# The test cannot pass vacuously, on either side.
sed 's/^### ship$/### delivery/' "$fx/full" > "$fx/noship-full"
expect '[no-ship]' "$fx/noship-full" "$fx/direct"
sed 's/^### ship$/### delivery/' "$fx/direct" > "$fx/noship-direct"
expect '[no-ship]' "$fx/full" "$fx/noship-direct"
# A difference inside ship is no difference.
sed 's/^Merge, deploy, confirm\.$/Merge, then deploy./' "$fx/direct" > "$fx/inship"
expect pass "$fx/full" "$fx/inship"
# Each allowance is used once and only where stated.
sed 's/^Tear down\.$/These rules assume a teardown./' "$fx/full" > "$fx/assume2-full"
sed 's/^Tear down\.$/These rules assume a remote teardown./' "$fx/direct" > "$fx/assume2-direct"
expect 'a second assume difference' "$fx/assume2-full" "$fx/assume2-direct"
# A paragraph only the promoting fragment holds, anywhere else, fails.
awk '/^The two deploy transitions name their host/ { skip = 1; next } skip { skip = 0; next } { print }' "$fx/full" | sed 's/^Apply, then verify\.$/&\n\nThe two deploy transitions name their host./' > "$fx/misplaced"
expect 'does not follow the derivation' "$fx/misplaced" "$fx/direct"
# A second added paragraph fails, as does a line only the direct form holds.
sed 's/^Tear down\.$/Tear down.\n\nOne more paragraph./' "$fx/full" > "$fx/extra"
expect 'One more paragraph.' "$fx/extra" "$fx/direct"
sed 's/^Tear down\.$/Tear down.\n\nOnly in direct./' "$fx/direct" > "$fx/direct-extra"
expect 'Only in direct.' "$fx/full" "$fx/direct-extra"
# A multi-line rewrite outside ship fails.
sed 's/^Tear down\.$/Tear it down.\nAnd sweep./' "$fx/full" > "$fx/block"
expect '[outside-ship]' "$fx/block" "$fx/direct"

[ -f "$FRAGMENT_DIRECT" ] || { echo "FAIL: target absent — rules/development-workflow-direct.md does not exist yet" >&2; exit 1; }
compare_fragments "$FRAGMENT_FULL" "$FRAGMENT_DIRECT" || { echo "FAIL: the shipped fragments differ outside what the requirement allows" >&2; exit 1; }
for allowance in ship small assume added; do
  case " $SEEN " in *" $allowance "*) ;; *) echo "FAIL: the shipped fragments do not differ by $allowance, which the requirement states they do" >&2; exit 1 ;; esac
done
