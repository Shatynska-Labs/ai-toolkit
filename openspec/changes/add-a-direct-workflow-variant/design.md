## Context

`rules/manifest` lists blocks by name, and `scripts/project-init` and `scripts/project-update` each read a fragment `rules/<name>.md` per record. Markers are matched by the prefix `<!-- ai-toolkit:<name> `, with its trailing space, so `development-workflow-direct` cannot be read as `development-workflow`. `ship` is about 4 KB of the fragment's 18 KB. 121 test cases mention the workflow; 20 mention its stages.

`commerce-ops` keeps its two-deploy `ship` inside its `v12` block, and `basis` keeps its in `## Deployment`, outside the block. Their texts agree on the stages and differ in state names and in who may trigger a promotion.

## Goals / Non-Goals

**Goals:**

- A new project gets staging and promotion without asking.
- A repository with no production can say so and keep the one-deploy `ship`.
- No project changes workflow unless told to.
- The two workflows cannot drift apart outside `ship`.

**Non-Goals:**

- More than two variants, or a general variant mechanism.
- `add-session-workflow-tooling`'s second block in one target.
- Running the update in any project: that is this change's `confirm`.
- Changing what a project's own `## Deployment` says, other than `basis` trimming what becomes redundant, in its own pull request.

## Decisions

**1. Two complete fragment files held identical by a test.** The backlog entry proposed one shared text with a `ship` section per variant. Assembling that at run time needs the same logic in both bash tools, and leaves a fragment that an `@` import cannot read whole, while `AGENTS.md` rules out a build step. Two files with a test give the same guarantee, that nothing outside `ship` drifts, with no tool change for reading a fragment. Rejected: an overlay of the direct `ship` over the full text, which keeps one source but makes the direct fragment unreadable on its own. The cost is that a change to shared text is typed twice and raises two versions, and the test makes forgetting one a failure. The operator chose this on 2026-11-01, over the shared text they had first confirmed, once the cost of assembling it was known.

**2. The full fragment keeps the name `development-workflow`.** The default keeps the name every project and test already uses, and the exception gets the new one. The block's text changes under the same marker, so the 121 cases keep reading the default.

**3. `alternative` in the manifest, `alternative_since` in the frontmatter.** The manifest says what a project receives, and the specification keeps versions out of it, so the version where the choice begins lives in the fragment beside the text it versions.

**4. A block that would be replaced blocks the run until `--workflow` is given.** `2.0.0` is a major: the project must do something by hand, which is say which workflow it wants. Replacing a `1.0.0` block would hand `infrastructure` promotion rules. The check keys on the state `stale` or `legacy block`, not on the version: an `edited` or `malformed` block is never replaced, so it needs no choice to stay safe, keeps `SUCCESS` with `Attention:`, and is not blocked again on every run. A new `Attention` state for an owed choice was the alternative, but it would leave a project updating its directory blocks beside an undecided root block. The check comes before every write and every git precondition, so the report asks one question at a time; a project with a dirty file answers it, then meets that precondition.

**5. `--workflow` on `project-update` also switches later.** Without it a switch means editing a marker by hand, which breaks nothing only if the hash is recomputed by hand too. The switch uses the replacement that exists: only a `stale` or `current` block, and every byte outside it kept. An `ahead` block is left, as everywhere.

**6. The full `ship` is the current fragment's, extended with `commerce-ops`'s additions.** The base is today's text, since `v12` predates the pull-request binding and the `AGENTS.md` paths. Taken from `v12`: the two-deploy stages, confirming on staging, promote and smoke, the `promote` waiver, and the deploy command forbidden against either host, not production alone. The confirmation waiver stays directly under `confirm`, where "that gate" reads correctly. Dropped as that project's alone: the `promote.yml` paragraph on `publish-prompts`, and `gh workflow run`, stated as asking the forge to run a job. Kept: a session proposes a promotion and does not trigger it silently, the wording `commerce-ops` uses; `basis`'s stricter "never trigger a promotion" stays in its own conventions, outside the block. State names are `commerce-ops`'s: `ship:deploying-staging` / `ship:deployed-staging`, `ship:deploying-production` / `ship:deployed-production`, `ship:promoting` / `ship:promoted`, `ship:smoking` / `ship:smoked`. Added from `commerce-ops`'s `## Schema migrations` and `## Deployment`: production lags the trunk, and "the previous release" means what production runs, both inside `### ship`. Outside it the fragments differ in three lines and one added paragraph on states, which is exactly what the test allows.

**7. Version.** `development-workflow` rises to `2.0.0` and `development-workflow-direct` starts at `1.0.0`, since each fragment's version names what changed in that fragment. The plugin's version does not rise here: `raise-the-plugin-version-on-release` owns that.

**8. `session-workflow` owns both forms.** It already says a project of another shape is served by a publication of its own, owned alongside the others, so the direct fragment takes that place. Its requirements are amended to name the form rather than restated.

**9. This repository follows the direct fragment.** It holds no block and has no production. `AGENTS.md` says so.

## Risks / Trade-offs

- [A project with its `ship` inside the block converts to the toolkit's text] → `full` replaces `commerce-ops`'s `v12` text with its generalised form, which loses the `publish-prompts` paragraph. `confirm` moves that paragraph into its `## Deployment and configuration`, committed before the run.
- [The blocked run surprises someone running the update on a schedule] → Out of scope by the workstream, which runs nothing automatically.
- [Existing cases pin one-deploy wording, or drive a workflow block below `2.0.0` with no flag] → Those reading a sentence that moved change only what they read. Those driving an old block gain `--workflow full`, or move their fixture to another record, with their assertions unchanged. The obsolete list in `test-plan.md` names each.
- [`basis`'s `## Deployment` says the block assumes one deploy] → Stale after `full`, harmless, and trimmed in its own pull request at `confirm`.

## Migration Plan

After this merges, `confirm` runs in `fuperia/commerce-ops` (after moving `publish-prompts` out of the block and committing that) and `shatynska/basis` with `--workflow full`, and in `fuperia/infrastructure`, `shatynska/infrastructure` and `infrastructure-template` with `--workflow direct`, each on its own branch from a fresh trunk, reviewing each diff with the operator. Rollback is reverting this change's commits; a project reverts its own pull request.
