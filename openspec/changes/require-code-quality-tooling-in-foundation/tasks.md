## 1. Fragment

- [x] 1.1 In `rules/project-foundation.md`, rewrite the **Development tooling** bullet to name each quality concern by concern, never by tool, matching the spec's list; verify by reading that no linter, formatter, hook manager, build system or forge is named
- [x] 1.2 Add the three fixed positions (CI authority that fails rather than skips; a hook is not a gate; secrets excluded by the ignore file, with secret-bearing paths in the ignore deliverable) and the hook stand-down classifier rule; verify each is stated as a position, not an option
- [x] 1.3 Add the branch-protection rule: foundation decides and records the policy; where a policy is decided, the change introducing CI applies it once its checks have reported and the operator confirms; where it is decided against with a reason, no application task exists; state initialization's non-involvement as the reason foundation owns the decision, not as a rule on `project-init`; verify by reading
- [x] 1.4 Add the delivery rule: foundation builds nothing beyond the ignore file; before archiving it opens a successor change — branch plus committed `handoff.md` naming each item to build, the test runner where the testing strategy decided one the project lacks, the branch-protection task only where a policy was decided, and `AGENTS.md`'s `## Development Tooling` and `## Testing Strategy` sections (never the foundation `design.md`) as where the decisions are recorded — and names it under `Delivery`, or records that the tooling is already present; call the successor the owner of the tooling, not a deliverable; suggest `establish-quality-gate` as a default name; state the successor is not exempt from test authoring; verify by reading
- [x] 1.5 Extend the fixed `design.md` layout with the `Development Tooling` named items in the spec's order; revise the parenthetical introducing the layout ("one per decision (three of them … grouped under a single `Identity` heading …)") so it covers both sections with named items; add that an item may be answered "not applicable" with a reason while an empty item is a gap; verify the layout matches the spec's block exactly

## 2. Skill

- [x] 2.1 In `skills/project-foundation/SKILL.md`, update the copied section layout to match 1.5; widen the sentence after it ("an unfilled item within `Identity`") to every section carrying named items, and add the "not applicable, with a reason" rule; verify the layout matches the spec's block exactly
- [x] 2.2 Under "Converse, don't interrogate", add one sentence that the development-tooling items are proposed as a coherent set once the stack is known, not asked one by one; verify the README/AGENTS split is still not restated
- [x] 2.3 Replace "The development-tooling decision has a concrete deliverable" with a section naming the one deliverable — the ignore file, including secret-bearing paths — and the successor change as the owner of the rest, and stating that foundation does not build the tooling; verify the test-authoring section still scopes the exemption to foundation alone
- [x] 2.4 Add "quality tooling" phrasing to the description only if the trigger check in 2.5 shows it is needed; keep the description's existing routing exclusions
- [x] 2.5 Run the skill's trigger check per `skills/create-skill/SKILL.md` with the existing fixtures plus "what should our CI and linting setup be for this new project?" (positive) and "set up husky and eslint in this repo" (negative — implementation, not foundation); add both to the skill's "Trigger check fixtures" list, and record the results under `## Trigger check results` in this change's `design.md`

## 3. Coverage and backlog

- [x] 3.1 In `tests/coverage.md`'s `project-foundation` section, add the four rows missing for "Settled decisions are surfaced into the project's permanent documentation" and the fifteen scenarios this change adds, each with "Structural review" as its verification, and update the section's heading and prose count from 14 to 33; verify the row count equals the scenario count in `openspec/specs/project-foundation/spec.md` after sync
- [ ] 3.2 At archive, delete the `move-setup-gates-to-project-setup` entry from `docs/backlog.md`

## 4. Verify

- [x] 4.1 `openspec validate require-code-quality-tooling-in-foundation --strict` passes
- [x] 4.2 `bash tests/run.sh` passes (no case is expected to change; `workflow-fragment-omits-setup-obligations.sh` must stay green, since the workflow fragment is untouched)
- [x] 4.3 Structural review: walk every scenario in this change's delta spec against the edited fragment and skill and record each as met
