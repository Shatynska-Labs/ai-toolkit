## Context

`add-backlog-skill` took sections 2, 3, 5 and 6 of its handoff. Sections 1 (fold in rather than record, with the reviewer's exemption) and 4 (pick up fix entries along the way) were split out as the backlog entry `fold-small-work-in`; the handoff is archived at `openspec/changes/archive/2026-10-18-add-backlog-skill/handoff.md`.

Facts that constrain the shape:

- `session-workflow` owns what the fragment says, including the scope rule's reconciliation with the backlog (*A second change surfacing…*). That requirement currently describes the scope rule as obliging all out-of-scope work to leave the change, and one of its scenarios says such work "is not implemented in the session that found it". Both are MODIFIED.
- `session-workflow` (*Archiving a change re-reads the backlog against it*) already deletes the entries an archived change completed, and requires the fragment to name no entry field. `project-bootstrap` owns the entry rules, stated in the seeded file.
- `change-code-review` owns the reviewer's `scope` kind. The reviewer runs in consuming projects, which may carry no fold-in rule at all.
- `backlog-maintenance` may carry procedure for a fragment obligation but no obligation of its own.
- The build review runs before the pull request is opened, so a pull request description does not exist when the reviewer reads the diff.

## Goals / Non-Goals

**Goals:** a stated path for small adjacent work, kept inside the guarantees the workflow already gives (one change at a time, a plan for any specified behaviour, small focused commits, independent review); a backlog that stops collecting entries a change could have closed; recording stated as the obligation where the fragment routes an independent change.

**Non-Goals:**
- Any change to the seeded backlog text or its entry shape. The seeded preamble already describes an entry as "a change recorded here instead of being folded into the change that found it", which now reads as intended.
- Consistency with commerce-ops' project-level *Visual work* exception. It sits outside the managed block; that project reconciles it when it refreshes its block.
- An operator approval step for folding in. The build review and the pull request already put every folded-in commit in front of a reviewer and the operator.

## Decisions

**1. `state-recording-as-the-obligation` is folded into this change.** Both entries name each other in Design with, and both edit the routing bullet of **A second change surfacing**. Done separately, the second to land rewrites the first's sentence. Its fragment edit is part of this change's own scope, not folded-in work.

**2. The fragment text.** **Scope** becomes:

> **Scope.** Prefer changes small enough to review in one sitting; where one grows to cover multiple independent concerns, consider splitting it. Implement only what belongs to the change in progress, with one exception. **Fold in** work noticed along the way where it touches only files the change edits for its own work, or their direct tests; owes no specification delta and no decision from the operator; and is small — a defect, a test correction, a documentation or naming fix, about a screen of diff. Give it a commit of its own whose message says it is folded in, and name it in the pull request's description. Anything else noticed along the way becomes a separate proposed change.

**A second change surfacing** opens:

> **A second change surfacing.** You work on one change at a time. Work you identify that the scope rule does not fold in is a second change: record it before doing anything else about it.

and its second bullet becomes:

> - Where it **does not**: record it in `docs/backlog.md`. That is what is owed; opening the identified change instead is the option.

**apply** gains, after its first sentence:

> Before implementing, read `docs/backlog.md` for entries the scope rule would let this change fold in, and take each as folded-in work whose commit names the entry; leave the entry itself to the archive step.

The sentence avoids "delete": `workflow-fragment-archive-reread-names-no-field.sh` reads any line naming `docs/backlog.md`, a read and the archive as the archive re-read, which states no deletion ground.

Version 8 → 9.

**3. The conditions.** *Files the change edits for its own work* rather than *already edits*: the reviewer checks it from the diff (the folded-in commit's files against the other commits' files), and it does not depend on the order the commits were made in. *Or their direct tests* lets a correction to the test of a file the change edits ride along. *Small* is set below the backlog's `fix` bar (one review sitting): a fix taken on its own may fill a review, while work riding inside another change must not crowd it. The examples are the classes the commerce-ops audit found; *about a screen of diff* is the size check.

**4. Marking.** The commit message says the work is folded in, because the build review reads commits and nothing else exists yet. The pull request description names it at **open pr**, for the operator. A folded-in commit taking a backlog entry names that entry, so the archive re-read and anyone reading the log can find it.

**5. Backlog pickup selects by the fold-in conditions, not by a field.** The fragment names no entry field (`session-workflow`, archive re-read). Selecting by `Kind: fix` would also miss entries in an older shape, and take `fix` entries too large to ride along. The entry is deleted by the archive re-read as one the change completed, not in the folded-in commit: `docs/backlog.md` is not a file the change edits for its own work, so condition (a) would bar that edit, and the re-read already exists for this case.

**6. The reviewer defers to the project's conventions.** The agent states that an edit the project's conventions let a change fold in, made as they direct, is not `scope`, and that one falling short of any of their conditions is. It does not state the conditions, because a project whose conventions name no fold-in rule has none, and a second statement of them would drift from the fragment's. To judge the conditions, the reviewer reads the range's commits as well as its diff — `git log --name-only <base>..<head>` gives each commit's message and files — so it can tell a folded-in commit's files from the rest. It judges the files, delta, size and own-commit conditions from that evidence. The no-decision condition it judges only where the diff makes a decision visible, such as an evident choice between alternatives; otherwise it is not a finding. A condition the reviewed diff cannot show at all, such as the pull request description, is not a finding. A folded-in edit gets correctness and convention findings like any other code. This is a body edit, so the cold-run check is owed and the trigger check is not. The fixture gains: the fixture project's `AGENTS.md` states a fold-in rule; `main` carries a `README.md` with an install section holding a typo; the fixture proposal names `README.md` (a greet section) alongside `bin/greet.sh`, in place of "No other file changes", with a matching fixture task; the greet commit adds that section; and a second branch commit, whose message says it is folded in, fixes the install section's typo. New pass criteria require that the typo fix is not reported as `scope` and draws no `defect`, while the `bin/util.sh` rename still is reported as `scope`.

**7. The skill applies the workflow's test.** **record** first asks whether the session is in a change and the work meets the fold-in rule the project's workflow states; where it does, it says so and writes no entry. It offers no override the fragment does not state, since an edge case answered differently in the skill is what `session-workflow`'s seam forbids. The skill names no condition itself. Only the skill's body changes; its description and trigger fixtures stand.

## Risks / Trade-offs

- **"Small" is a judgement.** The examples and the diff-size check bound it; the reviewer's `scope` finding remains for an edit that exceeds them, at `[MAJOR]` where it changes behaviour.
- **Two sessions may take the same backlog entry.** Each folds it into its own change; the second meets the fix already on the trunk when it brings the trunk in, and drops its commit. The entry is deleted once, by whichever archive re-reads first.
- **Version skew.** Projects see 8 → 9 on their next `project-init` run; nothing breaks before they refresh.
