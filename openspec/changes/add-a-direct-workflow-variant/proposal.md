## Why

`rules/development-workflow.md` assumes one deploy triggered by merging, while the projects that run a product reach production only by a promotion after staging. `fuperia/commerce-ops` and `shatynska/basis` each restate `ship` by hand to say so, and confirming `update-managed-block` showed the cost: a conversion replaced the stages `commerce-ops` kept inside its block. The operator holds staging and promotion as the ordinary shape, and a repository with no production, or one whose job is that every server runs, as the exception.

## What Changes

- **BREAKING** `rules/development-workflow.md` becomes the promoting workflow and rises to `2.0.0`: `ship` runs `open pr · merge · deploy staging · confirm · promote · deploy production · smoke · archive`, extended with what `commerce-ops`'s `v12` block adds, without what is that project's alone, and "the previous release" means what production runs.
- New fragment `rules/development-workflow-direct.md` at `1.0.0`: today's one-deploy `ship`, for a repository that does not promote. A shipped test holds the two fragments identical outside `ship` and the few lines that state it.
- `rules/manifest` names the second fragment as the first record's alternative. A project holds one of the two, by marker.
- `scripts/project-init` takes `--workflow full|direct`, default `full`.
- `scripts/project-update` takes `--workflow full|direct`. It keeps the variant a marker names, and blocks where a block that predates the variants would be replaced, until told which it wants, so no project gains promotion rules silently.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `project-bootstrap`: the manifest gains a record's alternative, and `project-init` chooses a variant.
- `project-update`: the tool classifies a block under either variant, takes the choice, and blocks where one is owed.
- `session-workflow`: the workflow fragment is published in two forms, and `ship`, its assumptions and its stage vocabulary are stated per form.

## Impact

- `rules/development-workflow.md`, `rules/development-workflow-direct.md`, `rules/manifest`, `rules/README.md`.
- `scripts/project-init`, `scripts/project-update`, `skills/project-init/SKILL.md`, `AGENTS.md`, `tests/`.
- Every adopting project: the next update is a choice. `fuperia/commerce-ops` and `shatynska/basis` take `full`, then `basis` trims its `## Deployment`. `fuperia/infrastructure`, `shatynska/infrastructure` and `infrastructure-template` take `direct`. This repository holds no block and follows the direct fragment.
- `keep-projects-on-the-current-workflow`: its Done when reads the update tool in `commerce-ops`, which stays on `v12` until this ships. This change is no step of it, since that workstream leaves out what the rules say.
- `add-session-workflow-tooling` also needs a workflow variant; this change's alternative is a different mechanism from its second block in one target, and neither prevents the other.
