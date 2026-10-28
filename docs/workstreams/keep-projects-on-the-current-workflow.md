# `keep-projects-on-the-current-workflow`

**Goal**: an adopting project can see what the toolkit currently ships into it, and bring itself up to date with one command per project rather than being synced by hand. That covers both channels the toolkit reaches a project through: the files `scripts/project-init` seeds, and the installed plugin's skills and agents.

**Done when**: after a toolkit change to any shipped file, running the update tool in commerce-ops reports that file stale and brings it current, reports a file the project edited without overwriting it, and lists the manual steps that version asks for; and `/plugin update` there installs the release that change shipped in.

**Steps**:

1. `list-what-a-project-receives` — every rule the toolkit puts in a project becomes a fragment in `rules/` written as a managed block: the workflow into `AGENTS.md`, the backlog and workstream rules into `docs/backlog/AGENTS.md` and `docs/workstreams/AGENTS.md`, each beside a `CLAUDE.md` importing it; a manifest, `rules/manifest`, lists every block and its target, each fragment carries a semantic version, each block's opening marker carries its version and the hash of the body written, and the plugin and every block start at `1.0.0`.
2. `update-managed-block` — the update tool: reports each manifest item as current, stale or edited, replaces a stale one nobody edited, reports an edited one with its difference and never overwrites it, and converts a legacy `README.md` or `vN` block once, a directory's README in the same run that brings the root block to `1.0.0`; a separate executable from `project-init`, one project per run.
3. `record-what-each-version-asks` — a changelog of what each version changed and what a project must still do by hand, which the update tool prints between the project's version and the current one.
4. `add-session-workflow-tooling` — the database binding fragment as one more managed block in the manifest.
5. `raise-the-plugin-version-on-release` — the plugin's version rises with every release, so `/plugin update` reaches an installed copy.

- **Not in scope**: running updates across projects automatically, on a schedule or in CI; committing in a project on its behalf, since the tool edits the working tree and the project commits what it wrote; what the rules themselves say.
- **Opened**: 2026-10-28, by the operator, with the plan of `list-what-a-project-receives`.

## Context

**Two channels, neither with an update path.** The plugin carries skills, agents and rules, and an installed copy is cached by the version in `.claude-plugin/plugin.json`, which has stayed `0.2.0` since August, so `/plugin update` finds nothing new and a copy is refreshed only by reinstalling. `scripts/project-init` seeds a managed block in `AGENTS.md` and the READMEs of `docs/backlog/` and `docs/workstreams/`, and by its own requirement never rewrites any of them once present. The managed block carries a version (`v12`); the READMEs carry none, so no tool can tell an older copy from one a project edited. `openspec/changes/update-managed-block` proposed the updater for the block alone in September and stopped at three open questions.

**The adopting projects on 2026-10-28.** Every one is the operator's own.

| project | block | backlog README | workstreams README |
|---|---|---|---|
| fuperia/commerce-ops | v12 | the seeded text | differs |
| fuperia/infrastructure | v12 | the seeded text | differs |
| shatynska/basis | v12 | the seeded text | differs |
| shatynska/infrastructure | v12 | the seeded text | differs since `hold-shared-research-in-a-workstream` |
| infrastructure-template | v10 | the single file `docs/backlog.md` | absent |

**How Claude Code loads directory instructions** (Claude Code 2.1.312, from its memory documentation). A `CLAUDE.md` in a subdirectory loads once Claude reads, writes or edits a file in that subdirectory. `AGENTS.md` is read natively from 2.1.277, but by default only where no `CLAUDE.md`, `.claude/CLAUDE.md` or `CLAUDE.local.md` exists in the working directory or above it; a subdirectory's `AGENTS.md` then loads when a file there is opened with the Read tool and the subdirectory has no `CLAUDE.md` of its own. Every adopting project has a root `CLAUDE.md` importing `AGENTS.md`, so a directory's `AGENTS.md` alone would not load there by default. A `CLAUDE.md` containing `@AGENTS.md` loads it under every setting and is never read twice. HTML comments in a `CLAUDE.md` are stripped before the model reads it, so the managed block's markers are read by tools only. The seeded READMEs are read today only where the fragment or the `backlog` skill sends a session to them.

## Decisions

**1. Both channels** (operator, 2026-10-28). A project whose seeded files are current but whose `backlog` skill is months old is not on the current workflow, so the plugin's version is a step of this workstream, not a separate entry.

**2. Semantic versions, with a meaning for each part** (operator, 2026-10-28). A patch changes wording and no obligation, and the update tool replaces it silently. A minor adds or changes an obligation that needs no edit in the project, and the tool replaces it and prints its changelog entry. A major asks the project to do something by hand, and the tool replaces it and lists those steps. A major always carries manual steps and a minor or patch never does, so the tool decides from the version alone.

**3. Everything starts at `1.0.0`** (operator, 2026-10-28). Every adopting repository is the operator's own, so the plugin and every shipped file start at `1.0.0` together, as of the release `list-what-a-project-receives` merges in; the fragment's `version: 12` ends there. The plugin's version names the release, and each fragment's version names what changed in that fragment. A legacy `vN` marker is read as older than `1.0.0`, so the update tool brings those blocks to `1.0.0` without reconciling them by hand.

**4. Every rule reaches a project as a managed block** (operator, 2026-10-28). The backlog and workstream rules move from seeded `README.md` files to blocks in each directory's `AGENTS.md`, with a `CLAUDE.md` importing it, since a root `CLAUDE.md` keeps a directory's `AGENTS.md` from loading on its own. Their texts move from `scripts/seed/` into `rules/`. A project may add its own text outside the markers, never inside. The move is part of `1.0.0` rather than a later major, so the update tool has one kind of item and converts a legacy README once. A block's opening marker carries its version and the hash of the body as written, so an edit is a body whose hash differs from its marker's, with no record file in the project and no history of past versions in the toolkit.

**5. A directory's README is converted with the root block** (`list-what-a-project-receives`, 2026-10-28). The root block at `1.0.0` sends sessions to `docs/backlog/AGENTS.md` and `docs/workstreams/AGENTS.md`, so the update tool converts a directory's legacy `README.md` in the run that brings the root block to `1.0.0`, never leaving a project with the new root block beside an old README.
