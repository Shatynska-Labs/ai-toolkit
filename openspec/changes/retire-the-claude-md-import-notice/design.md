## Context

See `proposal.md`. The report line is printed from one branch in `scripts/project-init`, which sets `import_needed` wherever `CLAUDE.md` lacks `@AGENTS.md`, whether or not the file exists. The requirement it implements was written against the observation recorded in `add-project-workflow`'s `design.md` (2026-08-17).

The new observation, 2026-10-18, Claude Code 2.1.302, scratch git repositories with no conventions file in any parent directory, each `AGENTS.md` instructing that "say hello" be answered with a marker string, run with `claude -p "say hello"`:

| Arrangement | Result |
|---|---|
| `AGENTS.md` only | marker returned |
| `AGENTS.md` and `CLAUDE.md` holding `@AGENTS.md` | marker returned |
| `AGENTS.md` and `CLAUDE.md` with other content, no import | ordinary greeting |
| the same rule in `NOTES.md` only (control) | ordinary greeting |
| `AGENTS.md` only, marker changed between runs | the new marker |

Added after plan review round 1, which asked for the arrangements the first set excluded:

| Arrangement | Result |
|---|---|
| target is a nested repository with `AGENTS.md` only; enclosing repository has `CLAUDE.md` without the import | ordinary greeting |
| as above, enclosing directory is no repository | ordinary greeting |
| target has `.claude/CLAUDE.md`, no root `CLAUDE.md` | ordinary greeting |
| target has `CLAUDE.local.md`, no `CLAUDE.md` | ordinary greeting |
| a directory above the target has `.claude/CLAUDE.md` | ordinary greeting |
| a directory above the target has `CLAUDE.local.md` | ordinary greeting |
| target under `$HOME`, whose only candidate is `~/.claude/CLAUDE.md` | marker returned |
| the nested and `.claude/CLAUDE.md` cases with `@AGENTS.md` added to the target's `CLAUDE.md` | marker returned |

The changelog agrees: 2.1.277, "in a project with no CLAUDE.md, Claude Code reads AGENTS.md instead; change it under 'Project instructions' in `/config`"; 2.1.281, the same on Amazon Bedrock, Google Vertex AI, Microsoft Foundry, LLM gateways and telemetry-disabled sessions.

## Goals / Non-Goals

**Goals:** the report states the import as needed exactly where it is, and the absent-`CLAUDE.md` case stays announced for older versions.

**Non-Goals:**

- Writing or creating `CLAUDE.md`. The original backlog entry proposed that, and its premise is gone. The requirement that the tool writes nothing into it is unchanged.
- Detecting the installed Claude Code version or its `/config` "Project instructions" setting. The script is deterministic and harness-neutral, and the note states the condition rather than probing it.
- Re-verifying Codex or Antigravity, which stay unverified as before.
- Detecting an import placed in the target's `CLAUDE.local.md` or `.claude/CLAUDE.md`. Only the target's `CLAUDE.md` is read for `@AGENTS.md`, so such a project still gets the import line, an unneeded instruction in a rare arrangement, which errs towards stating more rather than leaving rules inert unannounced.

## Decisions

**1. Split on whether a shadowing file exists, searched as the harness searches.** The fallback is off wherever Claude Code finds a project instructions file for the target: `CLAUDE.md`, `CLAUDE.local.md` or `.claude/CLAUDE.md`, in the target or any directory above it, `~/.claude/CLAUDE.md` excepted because that is the user's own and was observed not to shadow. The script checks those three names in the target and each ancestor up to `/`, skipping `$HOME/.claude/CLAUDE.md`. That is a filesystem read, deterministic, and probes neither the version nor `/config`. The existing check (`@AGENTS.md` appears in the target's `CLAUDE.md`) stays as the test for "imports it". *Alternative: check the target's `CLAUDE.md` only*, the first draft. Rejected by plan review and by observation: a target nested in a directory with its own `CLAUDE.md` would get the note while its rules are inert.

**2. A note, not silence, where `CLAUDE.md` is absent.** Dropping the line entirely would be simplest. But a session on a version before 2.1.277, or on Bedrock or Vertex before 2.1.281, would then get inert rules with nothing said, which is the silent divergence the requirement exists to prevent. The note is one line, so it costs nothing on a current version. Proposed wording: `Note: Claude Code reads AGENTS.md without a CLAUDE.md from version 2.1.277 (2.1.281 on Bedrock, Vertex AI, Foundry, gateways and telemetry-disabled sessions), unless its "Project instructions" setting says otherwise; on an earlier version, add @AGENTS.md to a CLAUDE.md.` It doesn't begin with `Import needed:`, so nothing that greps for that line reads it as the instruction.

**2a. The import line names the target's own `CLAUDE.md`.** Where the shadowing file is above the target, the only `CLAUDE.md` an operator can see is that directory's, and an import there resolves to its `AGENTS.md`. Proposed wording: ``Import needed: add `@AGENTS.md` to this project's own CLAUDE.md (create it if absent) for the rules to take effect``. The prefix and the `@AGENTS.md` token stay, so `import-line-reported.sh` and any grep still match.

**3. The observation is recorded in the spec with its date and version.** The requirement already says to establish the behaviour by observation. Keeping both dated observations makes the next change in Claude Code's behaviour visible as a third entry, rather than an overwrite of the reasoning.

**4. No fragment change, so no version bump.** Only the script's report and the spec change.

## Risks / Trade-offs

- [The operator has switched "Project instructions" in `/config` so `AGENTS.md` isn't read] → not detected, by Non-Goal 2; the note names the setting, so the condition is stated rather than covered.
- [A future Claude Code changes the behaviour again] → Decision 3: the spec carries dated observations, and the requirement obliges establishing it again.
- [The test environment has a shadowing file above `$TESTDIR`, such as `TMPDIR` inside a checkout] → a case asserting the note would fail while the script is right. The affected cases check that no shadowing file exists above `$TESTDIR` and fail with that reason, and `tests/README.md` records the assumption.
- [Existing tests grep for `Import needed:` in the absent case] → `empty-directory-new-project.sh` is listed as obsolete by test derivation, and implementation updates its one assertion to the note.

## Plan review

Round 1: `FIX REQUIRED`. One `[MAJOR — design]`: the split rested on the target's `CLAUDE.md` alone, while the observation behind it had excluded files above the target, an arrangement the spec supports as a new project. Answered by observation (Context, second table) and by Decision 1's shadowing-file search. Three `[MINOR]`: `tests/README.md` untasked (task 2.3 added), the note omitting telemetry-disabled sessions, and a false claim that the note covered the `/config` setting (both fixed in Decision 2 and Risks).

Round 2: `CONDITIONALLY APPROVED`, five `[MINOR]`, applied without a further round — the spec's account of where the import fix was observed narrowed to what was observed; the test environment's own ancestors guarded; the import line reworded to name the target's own `CLAUDE.md` (Decision 2a); an import in a non-root file named as a Non-Goal rather than claimed not to load; the report form updated before the script, and `tests/coverage.md` tasked.

## Code review

Round 1: `CONDITIONALLY APPROVED`, two `[MINOR]`, applied — the ancestor walk now covers the physical path as well as the given one, so a symlinked target cannot hide a shadowing file, and `HOME` is normalised so a trailing slash does not make the user's own `~/.claude/CLAUDE.md` shadow. Both reproduced before and after the fix.
