## Context

`rules/development-workflow.md` already says what the amended specification will say. Its **Commits** rule says "proactively create a commit". Its routing for a second change says "Commit that branch at once". Its **Markdown prose** rule sits under *Throughout*. `change-code-review`'s requirement on `build`'s binding already says it "governs one sentence of the workflow fragment, alongside `session-workflow` and `project-bootstrap`". So this change brings the specification up to the fragment and the third owner's own statement. It does not change behaviour.

## Goals / Non-Goals

**Goals:**

- Nothing in `session-workflow` directs proposing a commit, or describes what happens when one is declined.
- An editor who reads only `session-workflow` learns all three owners of the fragment's content and which part each one governs.
- The **Markdown prose** rule has an owning requirement, so that rewording or dropping it is a specification change.

**Non-Goals:**

- A requirement for the **Commits** rule as a whole. The handoff requirement only appealed to it, and once that appeal is dropped, nothing in the specification depends on how the rule is worded. Specifying the rule is a separate decision.
- Changing `change-code-review` or `project-bootstrap`. Both already state their side of the seam.
- Applying the prose rule to anything other than the fragment's direction. How this repository's own Markdown is written is set by `AGENTS.md`, not by this capability.

## Decisions

### 1. Commit the handoff branch, with no declined path

The fragment's commit rule creates commits, so there is no proposal left to decline. The requirement keeps its reason (the session that opened the branch does not return to it, so no later commit will carry the handoff) and drops the rest. *Alternative:* keep a fallback for a failed commit, such as a hook or a signing failure. Rejected: a commit that fails is an error the session reports, like any other error. It is not a declined proposal, and the fragment does not state one.

### 2. Name the third owner in the publication requirement and the Purpose, and test it with a scenario

The seam paragraph of the publication requirement already lists what `project-bootstrap` owns. `change-code-review` is added there with its one sentence, the content of `build`'s Claude Code binding: what the session does on each verdict. The Purpose's ownership sentence says the same thing in short. The census of owners was checked across `openspec/specs/`. `toolkit-structure` owns a fragment's form, not its content, and the Purpose already names it, so it is not added to the content seam. `change-test-authoring` obliges "a rule fragment" to direct reading `test-plan.md`; that fragment is `rules/test-plan.md`, not the workflow fragment. The workflow fragment's promote-or-keep paragraph is governed by this capability's own *Test arrangement a derivation lacked is promoted by the change that needed it*. So the content owners are three, and the scenario is titled for content owners. A scenario is added because every requirement change in this capability carries one, and because "an editor starting here learns all three owners" can be checked by reading the requirement. *Alternative:* name the owner in the Purpose only. Rejected: the backlog entry names the publication requirement as the place an editor reads the seam, and the Purpose only summarises it.

### 3. The prose rule is a requirement of its own

It sits under *Throughout* and does not belong to any existing requirement's subject. A new requirement, *Fragment prose is not hard-wrapped*, states the direction and the reason `AGENTS.md` gives: a hard-wrapped paragraph makes every later edit reflow the lines around it, so the diff can no longer tell an edit from a reflow. It states what the direction excludes, which is Markdown's own line structure. It does not list frontmatter, code blocks and tables, because the fragment says only "where Markdown's own structure requires one", and the requirement should not say more than the rule it governs.

### 4. Tests are derived as usual

`change-test-writer` derives cases from the delta. The new and changed scenarios each have a mechanical half that a static scan of the fragment or the specification can reach. The fragment directs committing the handoff branch and names no proposed commit there. The fragment carries the prose rule. The publication requirement names `change-code-review`. Whatever a scan cannot reach is recorded as uncovered, with the reason, in `tests/coverage.md`.

## Risks / Trade-offs

- [The fragment and the specification can drift again the same way] → The derived cases scan the fragment for the committed form, so if the fragment returns to "propose", the suite fails.
- [Naming owners in three places: the Purpose, the publication requirement, and `change-code-review`] → Each place says what it says for a different reader. Any fourth owner would change all three, and the scenario in decision 2 reads the publication requirement.
