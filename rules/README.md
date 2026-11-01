# rules/

Memory fragments live at `rules/<rule-name>.md`, flat, directly under this directory.

Rules have no dedicated Claude Code primitive — nothing loads `rules/` automatically the way `skills/` and `agents/` are loaded. That does not mean they are absent from an installed copy: plugin installation copies this repository's entire tree, so these files are present and readable wherever the plugin is installed. Two paths reach a fragment from there:

- **`@` import** — referencing a fragment from a project's `CLAUDE.md` or `AGENTS.md`, for example `@~/projects/shatynska/ai-toolkit/rules/<rule-name>.md`. This requires no tooling and no copying, and the fragment stays a single source of truth rather than being duplicated into the importing project. The import path is machine-local: it resolves only on a machine where this repository is checked out at that path. An import committed to a repository shared with other people resolves only for people with this library at the same path.
- **A shipped tool reading it** — an executable under `scripts/` locates a fragment relative to its own installed location and reads it directly, with no `@` import and no harness involved. `scripts/project-init` does this: it writes each fragment `manifest` lists as a managed block into the `AGENTS.md` the manifest names. `scripts/project-update` reads the same fragments to bring the blocks a project already holds to their current text, and prints from `changelog` what the versions it crossed ask.

Both paths reach any fragment under `rules/`, a binding fragment such as `rules/development-workflow-database.md` included. What a binding fragment lacks until tooling catches up is not a route but a *tool* route: it is imported or copied by hand, where the workflow fragment is written into a managed block.

The workflow comes in two forms. `rules/development-workflow.md`, staging with production reached only by a promotion, is the default. `rules/development-workflow-direct.md`, one deploy by merging, is for a repository with no production or whose job is that every server runs, and is what this repository follows. `rules/manifest` names it as the first record's `alternative`, a project holds one of the two, and `--workflow full|direct` chooses, on `scripts/project-init` when a project starts and on `scripts/project-update` for a block older than the choice or to switch later. The two are complete files, identical outside what states `ship`, which `tests/cases/workflow-fragments-differ-only-in-ship.sh` holds.

## Fragment kind

Every fragment declares its kind in YAML frontmatter:

```yaml
---
kind: standing-constraint    # or: procedural-checklist
version: 1.0.0               # only if the fragment is inlined, now or later: MAJOR.MINOR.PATCH
---
```

A fragment `rules/manifest` names an `alternative` for also carries `alternative_since: MAJOR.MINOR.PATCH`, the first version at which a project chooses between the two.

A **standing constraint** is intended to reach a project's `CLAUDE.md` or `AGENTS.md` and remain in force there, by either path above. A **procedural checklist** describes a one-time procedure, read on demand, and is never inlined into a project's conventions file — inlining it would leave permanent instructions for work already finished. `version` is `MAJOR.MINOR.PATCH` and rises when the fragment's **body** changes — the text a project actually inlines — and not for an edit confined to the frontmatter itself: a patch for wording that changes no obligation, a minor for an obligation added or changed that asks nothing of the project by hand, a major where the project must do something by hand. It names what changed in this fragment, where the plugin's own version names a release. The obligation is owned by `project-bootstrap`'s requirement "The fragment's version increments when its body changes"; `toolkit-structure` fixes the frontmatter's form and defers that condition to it.

## The manifest

`manifest` lists every fragment a shipped tool writes into a project as a managed block, one record per block: its `name`, which is the fragment `<name>.md` and the name in the block's markers, and its `target`, the `AGENTS.md` it is written into. It and `changelog` are the two files here besides this README that are not fragments. It is a delivery list, not an index: no asset is found or loaded through it, and browsing the library never reads it. A fragment's version stays in its own frontmatter, beside the text it versions.

## The changelog

`changelog` holds one record for each fragment version above `1.0.0`, in the manifest's form: `name`, the fragment; `version`; `changed`, one line saying what that version changed; and one `ask` line for each thing a project must do by hand. A major version holds at least one `ask`, and a minor or patch holds none. `1.0.0` is where every fragment started and it asked nothing, so it has no record.

A version rise adds its record in the same edit. `scripts/project-update` prints the records between the version a project held and the one written, beneath that block's line: a minor's `changed`, a major's `changed` and `ask` lines, and nothing for a patch. It reads a block crossing workflow variants, or converted from a shape before `1.0.0`, as held at `1.0.0`. A record says what a version asked, never its text, so this is no history of past texts.
