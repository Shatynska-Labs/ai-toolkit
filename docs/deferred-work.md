# Deferred work

What this repository has deliberately not done, and why. Each entry names the change that argued it rather than repeating the argument.

This is not `docs/backlog.md`. An entry here is deleted when it stops being true; an entry there is deleted when its change is archived. An entry filed in the wrong one is swept early or kept forever.

This file exists outside any change because a deferral recorded only inside one stops being findable when that change is archived — it is the change *succeeding*, not the session ending, that loses it.

## The development workflow's reasoning is not published as a skill

`rules/development-workflow.md` was compressed hard, and the reasoning behind its rules lives only in the changes that decided them: chiefly the archived `consolidate-development-workflow`, `add-session-workflow-fragments` and `revise-development-workflow`. A skill carrying that reasoning was planned as `add-development-workflow-skill` and dropped before a proposal was written.

`session-workflow` allows such a skill only if it carries reasoning and nothing that changes an outcome, so it cannot make a session act more correctly. It is model-invoked, so it would load rarely, and it would have to track every version of a fragment that went from v3 to v6 in six weeks. The material assembled for it was the fragment as it stood at v2–v3, which no longer matches what ships. The three corrected arguments worth keeping from it are in `openspec/changes/archive/2026-09-05-consolidate-development-workflow/lessons.md`.

This stops being true if a consuming project shows a session going wrong for want of the reasoning, not the rule.

## A session's shared-service namespace is allocated and never reclaimed

`rules/development-workflow.md` directs a session to take its own namespace in any shared service its verification writes to, and directs nothing about releasing it. A project carrying those rules therefore accumulates namespaces and needs a sweep of its own. (The rule lived in `rules/worktree-isolation.md` until `consolidate-development-workflow` folded that fragment into the workflow one; the gap is unchanged.)

`add-namespace-reclamation` owns the release. It is a separate change because reclamation is an algorithm whose every predicate — eligible, claims, enumeration succeeded, this checkout's identity — would be left to an adopting project's binding, and six review rounds established that prose can require those predicates to exist without making them agree with one another. See `add-session-workflow-fragments`, Decision 5.

Until it ships, the sweep is manual.

## A tooling-created worktree is governed by no removal obligation

`rules/development-workflow.md` keys every working-tree rule to *the change* — a change's branch, a change's working tree, a change's record — so a worktree that carries no change falls outside them with no exclusion written, and the capability forbids the fragment writing one. The scoping is what matters here — such a worktree carries no branch destined for the trunk, so it can satisfy neither route of the removal condition, and unscoped rules would make it permanently unremovable.

But nothing in this repository obliges anyone to remove it either. `agent-authoring` mandates a cold-run worktree and states no removal. So the accumulation those rules exist to prevent is displaced onto a class of worktree they now exclude, rather than solved for it.

Either `agent-authoring` gains a removal clause, or something else takes the obligation. Recorded from `add-session-workflow-fragments`, whose sixth review round found the collision.
