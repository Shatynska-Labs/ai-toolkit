# Test plan: add-a-direct-workflow-variant

Written by `change-test-writer` before implementation. This file is not an artifact the OpenSpec schema knows about: it does not appear among `openspec instructions apply`'s context files and must be read on purpose.

Run any case by name: `bash tests/run.sh <case>`. The names below are file names in `tests/cases/` without `.sh`.

## Baseline

Full suite, taken before any test was written, in this worktree at `7dfbed7`: `bash tests/run.sh`, 364 passed, 0 failed.

After this pass: the same 364 pass and the 42 new cases fail, 406 in all. None of the 42 passed on its first run. 35 fail on an absent target, and 7 fail on real content, as the table below records.

## Accounting

103 scenarios in the delta specs, 103 accounted for: 93 covered by at least one named test, 10 recorded as uncovered. 32 belong to `ADDED` requirements and 71 to `MODIFIED`. Of the 71, 4 changed text and 67 are byte-identical to `openspec/specs`, compared mechanically.

A byte-identical scenario states no behavior this change introduces, so it is covered by the case that already names it, and no duplicate was written. Each `MODIFIED` requirement's new behavior is covered by a new case. Where the case that covers a byte-identical scenario needs revising under task 3.3, the table marks it `(3.3)`: it is red, or passes for the wrong reason, until that revision lands.

No delta is `REMOVED` or `RENAMED`.

## Scenarios and their tests

### project-bootstrap, ADDED: A project chooses its workflow when it is initialized

| Scenario | Tests |
| --- | --- |
| A new project gets the promoting workflow | project-init-workflow-default-full |
| Direct is asked for | project-init-workflow-direct |
| A missing alternative blocks | project-init-alternative-missing-blocks |
| An unknown value blocks | project-init-workflow-unknown-blocks |
| A project holding one never receives the other | project-init-holding-direct-never-receives-full |
| A direct block is compared with its own fragment | project-init-direct-compared-with-own-fragment |
| A contrary choice is reported, not applied | project-init-contrary-choice-reported |

### project-bootstrap, MODIFIED: A project receives exactly the blocks the manifest lists

| Scenario | Tests |
| --- | --- |
| The manifest lists the three blocks | manifest-alternative-and-versions; manifest-lists-three-blocks (3.3, assertion: see O1) |
| Every listed fragment exists with a kind and a semantic version | manifest-alternative-and-versions; manifest-fragments-kind-semver |
| A new project receives exactly the listed blocks | project-init-workflow-default-full; project-init-workflow-direct; manifest-new-project-exactly-listed-blocks |
| A record added to the manifest is written without a change to the tool | manifest-added-record-written |
| A link at a target is not written through | manifest-target-link-not-written-through |

### project-update, ADDED: A block is read under either variant

| Scenario | Tests |
| --- | --- |
| A stale direct block stays direct | project-update-direct-stale-stays-direct |
| A current direct block is current | project-update-direct-current |
| Both variants in one target | project-update-both-variants-malformed |

### project-update, ADDED: A project states its workflow where its block predates the choice

| Scenario | Tests |
| --- | --- |
| An old block blocks until chosen | project-update-choice-old-block-blocks |
| A legacy block blocks until chosen | project-update-choice-legacy-blocks |
| The choice is asked before a git precondition | project-update-choice-before-git-precondition |
| Full is chosen | project-update-choice-full |
| Direct is chosen for an old block | project-update-choice-direct-old-block |
| A legacy block is converted to the chosen variant | project-update-choice-legacy-converted-direct |
| A project already chosen is not asked again | project-update-choice-not-asked-again |
| A later switch | project-update-choice-later-switch |
| An edited block is not switched | project-update-choice-edited-not-switched |
| An edited old block owes no choice | project-update-choice-edited-old-no-choice |
| A block ahead is not downgraded | project-update-choice-ahead-not-downgraded |
| A choice for an absent block is carried to project-init | project-update-choice-absent-names-project-init |
| A missing alternative blocks | project-update-alternative-missing-blocks |
| An unknown value blocks | project-update-workflow-unknown-blocks |

### project-update, MODIFIED: The update tool is a standalone executable beside project-init

| Scenario | Tests |
| --- | --- |
| Help describes the tool and changes nothing | project-update-help; project-update-help-names-workflow |
| The target is stated before any change | project-update-target-line (3.3) |
| An unusable target blocks | project-update-unusable-target-blocks (3.3) |
| Fragments come from the copy the tool belongs to | project-update-self-location (3.3) |
| An older bash | project-update-older-bash (3.3) |

### project-update, MODIFIED: Each block the manifest lists is classified from the project alone

| Scenario | Tests |
| --- | --- |
| An untouched block at the fragment's version is current | project-update-current-untouched |
| An edit at the current version is reported as an edit | project-update-edited-at-current |
| Versions compare by number, not by text | project-update-version-numeric (3.3) |
| A block ahead of the toolkit | project-update-ahead |
| Two blocks of one name are malformed | project-update-malformed-two-markers |
| A marker in neither form is malformed | project-update-malformed-marker-form |
| An opening marker without a closing one is malformed | project-update-malformed-no-closing |

### project-update, MODIFIED: Every run ends in one of three outcomes, and the exit code agrees

| Scenario | Tests |
| --- | --- |
| A missing fragment blocks | project-update-fragment-missing-blocks (3.3) |
| An edited block still succeeds, and is named | project-update-attention-edited |
| Several records to attend to are named in manifest order | project-update-attention-order |
| A fragment without a semantic version blocks | project-update-fragment-invalid-blocks (3.3) |
| No hash command blocks | project-update-hash-command-absent-blocks (3.3) |
| A failed write reports what was written | project-update-write-failure-reports-written (3.3) |
| Nothing to attend to | project-update-no-attention |

### project-update, MODIFIED: A stale block nobody edited is replaced, and nothing outside its markers changes

| Scenario | Tests |
| --- | --- |
| A stale block is brought current | project-update-stale-replaced (3.3) |
| Project text around the block survives | project-update-stale-surrounding-text (3.3) |
| The replacement is project-init's block | project-update-replacement-equals-project-init (3.3) |
| Both tools agree on whether a block is present | project-update-presence-agrees-with-project-init |
| A second run changes nothing | project-update-second-run (3.3) |
| The file's mode is kept | project-update-mode-kept (3.3) |
| A root AGENTS.md link is written through (changed) | project-update-root-link-workflow-full; project-update-root-link-written-through (3.3) |

### project-update, MODIFIED: The shapes before 1.0.0 are converted only where git holds the original

| Scenario | Tests |
| --- | --- |
| A v12 workflow block is converted (changed) | project-update-legacy-v12-converted-workflow-full; project-update-legacy-v12-converted (3.3) |
| A backlog README is converted | project-update-legacy-readme-backlog-converted |
| An uncommitted legacy file blocks the whole run | project-update-legacy-uncommitted-blocks (3.3) |
| An untracked legacy README blocks | project-update-legacy-untracked-blocks |
| Legacy items outside a repository block | project-update-legacy-no-repository-blocks (3.3) |
| A project with no legacy item needs no repository | project-update-no-legacy-no-repository |
| A staged change to a legacy file blocks | project-update-legacy-staged-blocks (3.3) |
| A repository with no commit blocks a conversion | project-update-legacy-no-commit-blocks (3.3) |
| A root link resolving outside the working tree blocks | project-update-legacy-root-link-outside-blocks (3.3) |
| A chain of links resolving outside the working tree blocks | project-update-legacy-root-link-chain-blocks (3.3) |
| A root link resolving to a modified file blocks | project-update-legacy-root-link-modified-blocks (3.3) |
| A README is converted into an existing AGENTS.md | project-update-legacy-readme-into-existing-agents |
| A README beside a CLAUDE.md of the project's own | project-update-legacy-readme-beside-own-claude |
| A README the run cannot reach blocks a conversion | project-update-legacy-unreachable-readme-blocks (3.3) |
| A failed write during a conversion keeps the README | project-update-legacy-readme-write-failure (3.3) |

### session-workflow, ADDED: The default workflow reaches production by promotion

| Scenario | Tests |
| --- | --- |
| Merging does not reach production | workflow-full-ship-stages |
| A change confirmed and never promoted is not archived | workflow-full-unpromoted-not-archived |
| The previous release is what production runs | workflow-full-previous-release |
| No project's name reaches the fragment | workflow-full-no-project-names |

### session-workflow, ADDED: The two workflows differ only in what states ship

| Scenario | Tests |
| --- | --- |
| A difference outside ship fails | workflow-fragments-differ-only-in-ship |
| The test cannot pass vacuously | workflow-fragments-differ-only-in-ship |
| The direct workflow reaches production by merging | workflow-direct-ship-stages |
| The fragments as shipped differ only as stated | workflow-fragments-differ-only-in-ship |

### session-workflow, MODIFIED: The session obligations are published in the workflow fragment and one binding fragment

| Scenario | Tests |
| --- | --- |
| A session obligation is stated once (changed) | workflow-fragments-differ-only-in-ship (the mechanical half: nothing outside `ship` can differ); workflow-fragment-publication-set |
| A reader of a project's conventions finds no dangling reference | workflow-fragments-no-dangling-either-form; workflow-fragment-no-dangling-reference |
| A fragment names only agents and skills the library ships | workflow-fragments-no-dangling-either-form; workflow-fragment-names-shipped-assets |
| A project without a deploy is not served by a conditional | workflow-fragments-route-and-assumptions; workflow-fragment-states-assumptions |
| A second publication does not arrive unowned | UNCOVERED, U1 |
| An editor learns every owner of the fragment's content from this capability | session-workflow-publication-names-third-owner |

### session-workflow, MODIFIED: A change's stage is named from a fixed vocabulary

| Scenario | Tests |
| --- | --- |
| A commit made while applying is not blocked by tests written to fail | workflow-fragment-commit-bypass |
| A resuming session names the stage without interpreting prose | workflow-fragment-stage-vocabulary; workflow-fragment-stage-names-are-current; workflow-full-deploy-states; workflow-full-ship-stages; workflow-direct-ship-stages |
| Writing tests and running tests are not one word | workflow-fragment-stage-vocabulary |
| The vocabulary is not enumerated beside the rule that generates it | workflow-fragment-stage-names-are-current |
| An imprecise stage is not treated as a defect worth an artifact | workflow-fragment-no-mandated-ledger |

### session-workflow, MODIFIED: A change is delivered through at least two pull requests, the last carrying its record

| Scenario | Tests |
| --- | --- |
| Delivery does not begin against unverified work | UNCOVERED, U2 |
| The code-review loop does not run unbounded | UNCOVERED, U2 |
| A merge and its deploy are confirmed rather than assumed | UNCOVERED, U2 |
| A healthy deploy is not confirmation the change worked | workflow-fragment-confirmation-waiver |
| A change with no observable effect reaches its record | workflow-fragment-confirmation-waiver |
| The record follows the confirmed effect | UNCOVERED, U2 |
| A remedial cycle adds a pull request rather than reusing one | UNCOVERED, U2 |
| A failed deploy does not produce a record | UNCOVERED, U2 |
| Production is not reached from a local machine (changed) | workflow-full-promotion-obligations; workflow-fragments-local-deploy-bounded; workflow-fragment-deploy-is-only-path |
| A deployed change that does not do what it was for | UNCOVERED, U2 |
| The wrong change reaches its record rather than stalling | workflow-fragment-confirmation-waiver |

### session-workflow, MODIFIED: A production-confirmation waiver is recorded

| Scenario | Tests |
| --- | --- |
| A waived change carries the reason to the trunk | workflow-fragment-confirmation-waiver |
| A verdict is not recorded, and the commit stands for it | UNCOVERED, U2 |
| A confirmation nobody recorded is simply asked again | UNCOVERED, U2 |

### Tests covering requirement text with no scenario of its own

- `project-init-both-variants-names-both`: where both markers are present, the tool writes neither and reports both names.
- `project-init-help-names-workflow`: `project-init --help` documents the flag.
- `project-update-help-names-workflow`: `project-update --help` documents the flag.
- `project-update-direct-edited-diff`: an edited block's difference is taken against the fragment of the variant it holds.
- `workflow-full-promotion-obligations`: the requirement's list of what the promoting fragment states.
- `workflow-full-deploy-states`: the promoting form's four deploy state names.

## Uncovered scenarios

- **U1**, *A second publication does not arrive unowned*: states who owns a publication, which is a property of the specification and not of anything a case can run. Verified by reading. The direct form is that publication, and the delta's requirement names it.
- **U2**, the nine scenarios marked so above: each states how a session conducts itself. Each is byte-identical to the current specification, and no token scan separates the obligation from a mention of it. The existing suite carries no case for them either. The promoting form's text is reached by `workflow-full-promotion-obligations` where the change altered it, and `workflow-fragments-differ-only-in-ship` holds the direct form's text to the promoting form's outside `ship`. Verified by reading at review.

Tasks with no scenario, so no test here: 2.4 (`skills/project-init/SKILL.md`), 3.1 (`AGENTS.md`, `rules/README.md`), 3.2 (`tests/README.md`), 3.4 (`tests/coverage.md`).

## Assertion classification

Each new case states this in its header as well. Unlisted assertions in a case are its arrangement.

| Test | Specified | Derived | State at authoring |
| --- | --- | --- | --- |
| `manifest-alternative-and-versions` | rules/manifest's first three records are development-workflow, backlog and workstreams; the first carries `alternative: development-workflow-direct`; alternative adds no record, so no record is named development-workflow-direct; no record carries a version. rules/development-workflow-direct.md carries a kind and version 1.0.0; rules/development-workflow.md carries version 2.0.0 and alternative_since: 2.0.0. | records are read by the `---` separators in the file; `name`, `target` and `alternative` are the only keys. | state 1, red on real content |
| `project-init-alternative-missing-blocks` | a manifest naming an alternative whose fragment the copy lacks, or which lacks a kind or a MAJOR.MINOR.PATCH version, is BLOCKED and nothing is written, with or without --workflow. | each flag value is run; nothing written is read as an empty target. | state 2, target absent; assertions not yet exercised |
| `project-init-both-variants-names-both` | where both markers are present the tool writes neither and reports both names. | 'reports both names' is read on the root's conventions file line. | state 2, target absent; assertions not yet exercised |
| `project-init-contrary-choice-reported` | --workflow full in a project holding a development-workflow-direct block leaves it unchanged and names `scripts/project-update --workflow`; the requirement states the same of either contrary value. | a value naming the variant already held earns no such sentence: the requirement conditions it on naming the other one. | state 2, target absent; assertions not yet exercised |
| `project-init-direct-compared-with-own-fragment` | a project holding development-workflow-direct at that fragment's version reads as matching, the report names development-workflow-direct and does not say to bring it current; the version is compared against the fragment of the variant held, so a lower one is told to come current against that fragment. | tokens from tests/README.md's report contract: `block already present`, `matches`, `bring it current`. | state 2, target absent; assertions not yet exercised |
| `project-init-help-names-workflow` | project-init documents --workflow <full/direct> in --help. | read as the flag and both values appearing in the output. | state 2, target absent; assertions not yet exercised |
| `project-init-holding-direct-never-receives-full` | project-init in a project whose AGENTS.md holds a development-workflow-direct block writes no development-workflow block and leaves the existing block unchanged. | 'unchanged' is read as the whole file byte for byte. | state 2, target absent; assertions not yet exercised |
| `project-init-workflow-default-full` | with no --workflow, in a new project, AGENTS.md holds a development-workflow block with the text of rules/development-workflow.md and no development-workflow-direct block. | the text is read as the marker's version, a matching hash and the fragment's body closing the block. | state 2, target absent; assertions not yet exercised |
| `project-init-workflow-direct` | --workflow direct in a new project: AGENTS.md holds a development-workflow-direct block with that fragment's text and no development-workflow block. | as project-init-workflow-default-full. | state 2, target absent; assertions not yet exercised |
| `project-init-workflow-unknown-blocks` | --workflow staged is BLOCKED, the report names full and direct, and nothing is written. | the names are read as whole words of the Reason line. | state 2, target absent; assertions not yet exercised |
| `project-update-alternative-missing-blocks` | a manifest naming an alternative whose fragment is missing, or alternative_since absent or not MAJOR.MINOR.PATCH where alternative is present: BLOCKED and the project is unchanged. The outcomes requirement counts the alternative's fragment as listed, so its kind and version are held as well. | the project is seeded current, so nothing else in it could block. | state 2, target absent; assertions not yet exercised |
| `project-update-both-variants-malformed` | a target holding both blocks is `malformed` under the record's name and neither changes. | read with and without --workflow, since `malformed` blocks are left whichever is selected. | state 2, target absent; assertions not yet exercised |
| `project-update-choice-absent-names-project-init` | --workflow direct with no workflow block: nothing is written for that record and its line names `scripts/project-init --workflow direct`. | the root AGENTS.md does not exist in the fixture, so 'nothing written' is its staying absent. | state 2, target absent; assertions not yet exercised |
| `project-update-choice-ahead-not-downgraded` | --workflow direct, an unedited development-workflow newer than the toolkit's: reported as ahead and left unchanged. | 'newer' is one major above the fragment. | state 2, target absent; assertions not yet exercised |
| `project-update-choice-before-git-precondition` | no --workflow, v12 with an uncommitted change to AGENTS.md: BLOCKED, the report names --workflow full and --workflow direct and does not name the git precondition. | 'does not name the precondition' is read without pinning its wording: the report equals, past its Target: line, the report of an identical project with AGENTS.md committed, which meets the precondition. | state 2, target absent; assertions not yet exercised |
| `project-update-choice-direct-old-block` | --workflow direct, an unedited development-workflow at 1.0.0: the file holds one block, under development-workflow-direct, with that fragment's text, every byte outside it is unchanged, and its line names both variants. | 'its line' is read as the first report line whose record is either variant, the tool's choice of which name opens it being unstated. | state 2, target absent; assertions not yet exercised |
| `project-update-choice-edited-not-switched` | --workflow direct, an edited development-workflow block: reported as edited and left unchanged. | the block is at the fragment's version, the state a switch would otherwise take. | state 2, target absent; assertions not yet exercised |
| `project-update-choice-edited-old-no-choice` | no --workflow, development-workflow at 1.0.0 edited, the backlog block stale: SUCCESS, Attention: names development-workflow, and the backlog block is replaced. | workstreams is seeded current, so the Attention: line is read whole. | state 2, target absent; assertions not yet exercised |
| `project-update-choice-full` | --workflow full, an unedited development-workflow at 1.0.0: the block is the current rules/development-workflow.md text and the rest of the run proceeds. | 'the rest of the run' is read as a stale backlog block replaced in the same run and SUCCESS. | state 2, target absent; assertions not yet exercised |
| `project-update-choice-later-switch` | --workflow full, an unedited, current development-workflow-direct block: the file holds one block, under development-workflow, and its line names both variants. | the block is read as the full fragment's text, and project text outside it as unchanged, per the requirement's 'replaced in the same way'. | state 2, target absent; assertions not yet exercised |
| `project-update-choice-legacy-blocks` | no --workflow, development-workflow v12: BLOCKED and no file changes. | the fixture is committed and clean, so the block cannot come from a git precondition. | state 2, target absent; assertions not yet exercised |
| `project-update-choice-legacy-converted-direct` | --workflow direct, v12 with the git preconditions met: the block is converted under development-workflow-direct and its line states it was not checked for edits. | the conversion crosses variants, so the line also names both, as the requirement states of every crossing. | state 2, target absent; assertions not yet exercised |
| `project-update-choice-not-asked-again` | no --workflow with development-workflow at or above 2.0.0, or development-workflow-direct at any version: the run proceeds as usual. | 'at or above' is read through alternative_since itself, by a copy whose fragment is one minor past it holding a block stale at it; 'as usual' is read as SUCCESS, the block replaced, and the report not naming --workflow. | state 2, target absent; assertions not yet exercised |
| `project-update-choice-old-block-blocks` | no --workflow, development-workflow at 1.0.0: BLOCKED, the report names --workflow full and --workflow direct, and no file changes, including a stale backlog block. | workstreams is seeded current; what each flag does is not asserted (test-plan.md, deliberately untested). | state 2, target absent; assertions not yet exercised |
| `project-update-direct-current` | an unedited direct block at that fragment's version reads `current` under the name development-workflow-direct and nothing is written. | none. | state 2, target absent; assertions not yet exercised |
| `project-update-direct-edited-diff` | an `edited` direct block's difference is taken against the fragment of the variant it holds, and the report line and Attention: use the alternative's name. | the `ship:` line that session-workflow fixes for each form tells the two fragments apart in the indented diff. | state 2, target absent; assertions not yet exercised |
| `project-update-direct-stale-stays-direct` | an unedited direct block below that fragment's version is replaced with the current rules/development-workflow-direct.md text under that marker, and no development-workflow block appears. The report line uses the alternative's name. | no --workflow is given, as the requirement's 'Without --workflow, a run SHALL NOT turn one variant into the other'. | state 2, target absent; assertions not yet exercised |
| `project-update-help-names-workflow` | the tool accepts --workflow <full/direct> and documents its flags in --help. | read as the flag and both values appearing in the output. | state 2, target absent; assertions not yet exercised |
| `project-update-legacy-v12-converted-workflow-full` | `project-update --workflow full` where a committed, unmodified AGENTS.md holds a v12 block with project text below it: the block is replaced by the current workflow block, the project text is unchanged, and the report states it was converted from v12, not checked for edits, and to be reviewed with `git diff`. | tokens as project-update-legacy-v12-converted.sh, whose scenario this revises. | state 2, target absent; assertions not yet exercised |
| `project-update-root-link-workflow-full` | `project-update --workflow full` where the root's AGENTS.md is a symbolic link to a file holding a stale workflow block: the link is still a link to the same file, and that file holds the current block. | as project-update-root-link-written-through.sh, whose scenario this revises. | state 2, target absent; assertions not yet exercised |
| `project-update-workflow-unknown-blocks` | --workflow staged is BLOCKED, the report names full and direct, and nothing is written. | a stale backlog block is what a run would have written; the names are read as whole words of the Reason line. | state 2, target absent; assertions not yet exercised |
| `workflow-direct-ship-stages` | in rules/development-workflow-direct.md the stages are `open pr · merge · deploy · confirm · archive`, `promote` appears nowhere in them, and a change reaches production by merging. | 'in them' is read as the stage line and the `### ship` section, not the whole body: text shared with the promoting form may use the word. | fixture discriminators exercised and passing; real read state 2 |
| `workflow-fragments-differ-only-in-ship` | compare_fragments takes two paths. Outside `### ship` the bodies are byte-identical except three lines that differ (the paragraph stating work too small to be a change, the paragraph stating what the rules assume, the `ship:` line of the stage list) and one paragraph only the promoting fragment holds, directly after the paragraph stating the derivation of a state. Any other difference fails naming the line; a file with no `### ship` section fails; the shipped pair passes. | paragraphs are told apart by a word each must hold on both sides: `too small to be a change`, `assum`, a leading `ship:`; the derivation paragraph is the one before the added paragraph and holds `transition`. These selectors are this test's reading, not the specification's wording, so a compliant text missing one is a derived assertion to reconsider. Over the shipped pair each allowance must be used once, since the requirement says the three lines do differ. | fixture half exercised and passing; shipped half state 2 |
| `workflow-fragments-local-deploy-bounded` | both forms state that the command that deploys is never run locally against production, and local credentials are for reading. | the co-occurrence workflow-fragment-deploy-is-only-path.sh reads, applied to the direct form it does not read. | fixture discriminators exercised and passing; real read state 2 |
| `workflow-fragments-no-dangling-either-form` | neither form's body names a `rules/` path, a sibling fragment file or an import, and every `ai-toolkit:<name>` it names is an agent or skill the library ships. | the file names and imports are those workflow-fragment-no-dangling-reference.sh scans, with development-workflow-direct.md added. | fixture discriminators exercised and passing; real read state 2 |
| `workflow-fragments-route-and-assumptions` | work too small to be a change does not skip `ship`, whose route is merging in the direct form, merging and a promotion in the promoting form; the promoting form assumes a staging deploy triggered by merging and a production deploy triggered deliberately, the direct form that merging to the trunk deploys. | each is a co-occurrence on one line, the two paragraphs being the ones the comparison allows to differ. | state 1, red on real content |
| `workflow-full-deploy-states` | the promoting form's two deploy transitions derive ship:deploying-staging / ship:deployed-staging and ship:deploying-production / ship:deployed-production, so neither derives from `deploy` alone; the direct form's stage line reads `ship:   open pr · merge · deploy · confirm · archive`. | the four names are read from the promoting body, design decision 6 and the one added paragraph naming them. The fragment's ban on enumerating every state is not touched: these are the names the rule does not generate from a bare `deploy`. | state 1, red on real content |
| `workflow-full-no-project-names` | neither promote.yml nor publish-prompts appears in rules/development-workflow.md. | `commerce-ops` and `gh workflow run` are forbidden as well: the requirement bars naming any file, job or service of one project, and design decision 6 drops the second by name. | fixture discriminators exercised and passing; real read state 2 |
| `workflow-full-previous-release` | the fragment names the release production runs, not the trunk's last merge, as what a change must stay compatible with; design decision 6 places it inside `### ship`. | a co-occurrence of release, production and trunk on one line of the section. | state 1, red on real content |
| `workflow-full-promotion-obligations` | each obligation the requirement lists, within `### ship`: a merge reaches staging and nothing else; a person triggers a promotion, a session proposes it and never triggers it silently; the deploy command is never run locally against either host; confirm happens on staging and does not establish production; production's gate is the smoke check, not a second confirm; a failed smoke leaves production on the promoted image and re-enters at build's review gate, promoting the previous commit being the operator's remedy; production behind the trunk is the pipeline working, not drift; `ship:confirmed` means confirmed on staging. | each scan is a co-occurrence on one line; the tokens are the requirement's own nouns and fix no sentence. | state 1, red on real content |
| `workflow-full-ship-stages` | the `ship` stage line reads `ship:   open pr · merge · deploy staging · confirm · promote · deploy production · smoke · archive`, which puts deploy staging, promote, deploy production and smoke in that order between merge and archive, and confirm before promote; `### ship` itself states the four stages. | the line is matched whole, in the form the vocabulary requirement gives it; the section is read for each stage's words without regard to case. | state 1, red on real content |
| `workflow-full-unpromoted-not-archived` | within `### ship`, a change is archived only once confirmed or its gate waived and it is in production; a change deliberately not going to production is archived on the operator's word as a waiver of `promote`, distinct from a confirmation waiver. | the scans are co-occurrences on one line, this repository writing a paragraph per line; the wording of 'distinct' is not fixed, so several forms satisfy it. | state 1, red on real content |

**Deliberately untested:**

- That the blocked report states *what each* of `--workflow full` and `--workflow direct` does. The cases check that both are named; no token separates a statement of the effect from a mention, and the wording is unstated.
- That a report names the variants in a particular order on a crossing line. The specification states only that both are named.
- Whether `project-init` reports a contrary choice against a `v12` or malformed block. The specification gives no case.

**Discriminators.** Every static case in this pass runs over fixtures before reading the real file, one mutant per property, and those runs pass today. A static case red on real content also records that it is red on the property named in its failure. That red becomes the observed failure the skill calls for once it goes green; no second record is owed.

**Not executed.** The 30 executing cases stop at `require_variants`, so their assertions have never run. Their fixture helpers were exercised separately in a scratch run, and `bash -n` and ShellCheck are clean. Read their first real failure as the first evidence about them. Where one disagrees with a compliant tool, a **specified** assertion means the tool is wrong, and only a **derived** one may be reconsidered, as a recorded change.

## Obsolete tests

Every entry is a **candidate for human confirmation**, not a conclusion. Each is a case in `tests/cases/`. Task 3.3 owns the revision and this pass edited none of them. The search covered `tests/cases/**` and nothing else; no earlier `test-plan.md` was dispatched.

### O1: an assertion is superseded

| Test | Superseding delta | Evidence | What it needs |
| --- | --- | --- | --- |
| `manifest-lists-three-blocks` | `project-bootstrap` MODIFIED, *A project receives exactly the blocks the manifest lists*: "A record MAY carry a third key, `alternative`" | `check_manifest`'s `[two-keys]` scan rejects any line other than `name:`, `target:` or a separator, and its header classifies that as "two keys" | The scan must admit `alternative:`. **This is an assertion change, which task 3.3's "no assertion changes" and design's risk entry do not foresee.** Neither a moved sentence nor `--workflow full` resolves it. |

### O2: a workflow block below `2.0.0` driven with no flag, red after the change

Each drives a block the delta now blocks on. Each needs `--workflow full` on its `project-update` invocation, assertions unchanged.

| Test | Evidence | Superseding delta |
| --- | --- | --- |
| `project-update-stale-replaced` | `seed_all stale` puts the workflow block at 1.9.0; asserts every record replaced | `project-update` MODIFIED, *A stale block nobody edited is replaced*, and ADDED, *A project states its workflow* |
| `project-update-stale-surrounding-text` | workflow block at `lower_version`; asserts it replaced | `project-update` MODIFIED, *A stale block nobody edited is replaced*, and ADDED, *A project states its workflow* |
| `project-update-second-run` | `seed_all stale`; asserts the first run replaced each. Only the first run needs the flag | `project-update` MODIFIED, *A stale block nobody edited is replaced*, and ADDED, *A project states its workflow* |
| `project-update-mode-kept` | `seed_all stale`; asserts the backlog replaced, which a blocked run does not do | `project-update` MODIFIED, *A stale block nobody edited is replaced*, and ADDED, *A project states its workflow* |
| `project-update-target-line` | `seed_all stale` in the target; asserts its workflow block at the fragment's version | `project-update` MODIFIED, *A stale block nobody edited is replaced*, and ADDED, *A project states its workflow* |
| `project-update-replacement-equals-project-init` | `compare` runs `seed_all stale`, then compares every block with `project-init`'s | `project-update` MODIFIED, *A stale block nobody edited is replaced*, and ADDED, *A project states its workflow* |
| `project-update-root-link-written-through` | workflow block at `lower_version` behind the link. The delta changes this scenario's text; `project-update-root-link-workflow-full` covers it as revised | `project-update` MODIFIED, *A stale block nobody edited is replaced*, and ADDED, *A project states its workflow* |
| `project-update-version-numeric` | copy at `1.10.0`, block at `1.9.0`; asserts `replaced`, both below `alternative_since` | `project-update` MODIFIED, *A stale block nobody edited is replaced*, and ADDED, *A project states its workflow* |
| `project-update-self-location` | block at `0.0.1`; asserts the invoked copy's version written | `project-update` MODIFIED, *A stale block nobody edited is replaced*, and ADDED, *A project states its workflow* |
| `project-update-write-failure-reports-written` | first record, the workflow block, stale; asserts `ERROR` and `replaced` | `project-update` MODIFIED, *Every run ends in one of three outcomes* |
| `project-update-legacy-v12-converted` | `V12_BLOCK`; asserts conversion. The delta changes this scenario's text; `project-update-legacy-v12-converted-workflow-full` covers it as revised | `project-update` MODIFIED, *The shapes before 1.0.0 are converted*, and ADDED, *A project states its workflow* |
| `project-update-legacy-readme-write-failure` | `V12_BLOCK` beside a README; asserts `ERROR` | `project-update` MODIFIED, *The shapes before 1.0.0 are converted*, and ADDED, *A project states its workflow* |
| `project-update-legacy-uncommitted-blocks` | `V12_BLOCK`; asserts the report names `docs/workstreams/README.md`, which the choice now precedes | `project-update` MODIFIED, *The shapes before 1.0.0 are converted*, and ADDED, *A project states its workflow* |
| `project-update-legacy-root-link-chain-blocks` | `V12_BLOCK`; asserts the report names the file outside | `project-update` MODIFIED, *The shapes before 1.0.0 are converted*, and ADDED, *A project states its workflow* |
| `project-update-legacy-root-link-modified-blocks` | `V12_BLOCK`; asserts `Reason:` names the link and its file | `project-update` MODIFIED, *The shapes before 1.0.0 are converted*, and ADDED, *A project states its workflow* |
| `project-update-legacy-root-link-outside-blocks` | `V12_BLOCK`; asserts the report names the link and its file | `project-update` MODIFIED, *The shapes before 1.0.0 are converted*, and ADDED, *A project states its workflow* |

### O3: stays green but stops testing what it says

Each asserts `BLOCKED` over a project that now blocks on the owed choice, so it would pass whatever its own precondition did. Each needs `--workflow full`, assertions unchanged, so that `BLOCKED` can only come from what the case is about.

| Test | Evidence | Superseding delta |
| --- | --- | --- |
| `project-update-legacy-no-commit-blocks` | `V12_BLOCK`, asserts only `BLOCKED` and an unchanged tree | `project-update` MODIFIED, *The shapes before 1.0.0 are converted*, and ADDED, *A project states its workflow* |
| `project-update-legacy-no-repository-blocks` | `V12_BLOCK`, both arms | `project-update` MODIFIED, *The shapes before 1.0.0 are converted*, and ADDED, *A project states its workflow* |
| `project-update-legacy-staged-blocks` | `V12_BLOCK` | `project-update` MODIFIED, *The shapes before 1.0.0 are converted*, and ADDED, *A project states its workflow* |
| `project-update-legacy-unreachable-readme-blocks` | `V12_BLOCK` | `project-update` MODIFIED, *The shapes before 1.0.0 are converted*, and ADDED, *A project states its workflow* |
| `project-update-fragment-missing-blocks` | `seed_all stale` | `project-update` ADDED, *A project states its workflow* |
| `project-update-fragment-invalid-blocks` | `seed_all stale`, both arms | `project-update` ADDED, *A project states its workflow* |
| `project-update-hash-command-absent-blocks` | `seed_all stale` | `project-update` ADDED, *A project states its workflow* |
| `project-update-unusable-target-blocks` | the third arm, `seed_all stale` in a read-only target | `project-update` ADDED, *A project states its workflow* |
| `project-update-older-bash` | `seed_all stale` compares two runs, which would both block alike. Its running half runs only where a bash 3.2 is found | `project-update` ADDED, *A project states its workflow* |

### O4: a sentence that moved

**None was found by this search, which is not to say no such case exists.** The search read every line selector, section anchor and fixed phrase in the check code of the 62 cases naming the workflow fragment, and matched them against the words `design.md` decision 6 changes. No selector anchors inside `### ship`, and the transition checks read `deploy` and `merge` by substring, which the promoting line still satisfies.

Three cases read a co-occurrence the rewrite could disturb, and they could not be checked against the text because the fragment is outside this pass's read set: `workflow-fragment-deploy-is-only-path` (a line naming `local` and `production`), `workflow-fragment-confirmation-waiver` (`production`, `waiv`) and `workflow-fragment-states-assumptions` (`deploy`). Run them after task 1.2; a failure there is a moved sentence, and it changes what the case reads.

Comment-only staleness, needing no revision to stay correct: the headers of `workflow-fragment-deploy-is-only-path`, `workflow-fragment-publication-set` and `workflow-fragment-states-assumptions` describe one publication or one deploy.

## Unresolved project questions

- **Q1: what counts as shared arrangement here.** The dispatch named none, and `tests/README.md` names `tests/lib.sh` as supplying assertions without calling it arrangement. Assumption taken: `tests/lib.sh` is the runner's assertion library, used through `$TESTLIB` as the README documents and not read, being outside the read set; `tests/cases/lib/*.sh` are test modules, so nothing here imports them. Every new case depends on this.
- **Q2: the home of task 1.4's comparison.** The specification asks for "a test taking the two paths as arguments" and names no file. Assumption taken: `compare_fragments` is a function inside `workflow-fragments-differ-only-in-ship`, so **task 1.4 is met by that case** and the implementer owes no second comparison. It is a function, not a script: the case takes no arguments, since `tests/run.sh` passes none.
- **Q3: selectors for the allowed paragraphs.** The comparison identifies them by `too small to be a change`, `assum` and `transition`. The fragment is outside the read set, so these come from the specification's wording and were never run against the real text. If a compliant fragment misses one, the shipped half fails naming a line it should have allowed: reconsider that derived selector, as a recorded change. Dependent test: `workflow-fragments-differ-only-in-ship`.
- **Q4: order of the blocks.** The specification places the owed choice before every write and every git precondition, and does not order it against fragment validation or the hash-command check. No test depends on an order; the O3 entries exist so that none has to.

## Missing shared arrangement

**Disposition, every entry below: kept local.** This repository's conventions record no location for a shared test arrangement, so the workflow keeps each entry; the backlog entry `record-this-repositorys-shared-test-arrangement` holds that decision.

The dispatch named no shared arrangement, so there is no home to propose for anything below and no near-miss to record. Q1 asks whether there should be one.

**Group T** is the 30 cases named `project-init-*` and `project-update-*` in this pass. **Group S** is the 12 static cases, `manifest-alternative-and-versions` and `workflow-*`. Each case in a group declares the group's helpers locally; none imports them.

| Declared | In | Stands in for | Found in |
| --- | --- | --- | --- |
| `PROJECT_UPDATE`, `require_update` | T | the update tool's path, which `run.sh` does not export | `project-update-stale-replaced` |
| `sha256_of`, `frag_key`, `frag_body`, `records`, `target_of`, `fversion`, `lower_version` | T | digest, fragment frontmatter and body, and manifest readers | `project-update-stale-replaced` |
| `block_body`, `block_lines`, `marker_line`, `marker_version`, `hash_ok`, `put_block`, `seed_all`, `edit_inside` | T | managed-block readers and fixture writers | `project-update-stale-replaced` |
| `rline`, `expect_line`, `refuse_line`, `tree_sum`, `assert_tree`, `assert_outcome` | T | report and tree assertions | `project-update-stale-replaced` |
| `git_fixture`, `toolkit_copy`, `set_version`, `V12_BLOCK` | T | a committed project, a copy of the toolkit, an edited fragment version, a legacy block | `project-update-stale-replaced` |
| `FULL`, `DIRECT`, `require_variants` | T | the two names, and the target-absent guard for the direct fragment and the manifest's `alternative` | new |
| `put_block_at`, `put_others`, `open_count`, `assert_block_is`, `assert_absent_block` | T | a block written by path, for the alternative, which no record's name reaches; a block's identity with its fragment | new; `put_block_at` adapts `put_block` |
| `variant_line`, `assert_names_both`, `outside_block`, `assert_names_choice`, `higher_major` | T | the variant's report line, and the checks that both names and both flags appear | new; `outside_block` adapts `outside` in `project-update-stale-surrounding-text` |
| `frag_body`, `frag_key` | S | fragment readers | `rules-manifest-only-non-fragment` |
| `split_ship`, `FRAGMENT_FULL`, `FRAGMENT_DIRECT`, `SCANS`, `need`, `scan_lines`, `discriminate_scans` | S | the section split, the two paths, and a one-line co-occurrence scan with its mutants | new; `tests/cases/lib/line-scan.sh` is a neighbour, a test module and not importable |
| `compare_fragments`, `seen_once`, `expect`, `SEEN` | `workflow-fragments-differ-only-in-ship` | the comparison itself | new |
| `check` | `workflow-full-ship-stages`, `workflow-full-no-project-names`, `workflow-full-deploy-states`, `workflow-direct-ship-stages`, `workflow-fragments-no-dangling-either-form`, `manifest-alternative-and-versions` | that case's check over a path, so a fixture can reach it | `workflow-fragments-no-dangling-either-form` adapts `workflow-fragment-no-dangling-reference` and `workflow-fragment-names-shipped-assets`; the rest new |
| `mkroot`, `mutate`, `expect` | `manifest-alternative-and-versions` | a fixture toolkit root and one mutant per property | `mkroot` and `expect` adapt `manifest-fragments-kind-semver` |
| `run_blocked` | `project-init-alternative-missing-blocks`, `project-update-alternative-missing-blocks` | one blocked run over a broken copy | adapts `project-update-fragment-invalid-blocks` |
| `run` | `project-init-contrary-choice-reported` | one run against a held variant | new |

## What the implementation must make pass

`bash tests/run.sh` with every case above green, after task 3.3's revisions. Task 1.4 is already written; see Q2. Task 3.3's list is O1 to O3, and O4 names what to rerun after task 1.2.
