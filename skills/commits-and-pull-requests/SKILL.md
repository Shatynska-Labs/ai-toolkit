---
name: commits-and-pull-requests
description: This skill should be used when writing a commit message or a pull request — "write the commit message", "open a PR", "write the PR description", "what should the PR title be", "write the archive pull request". It gives the default form where the project sets none - a commit body that says why, a PR title stating its effect, a description of what changed, why, what else and what was verified, and the workflow's work, fix and record pull requests. Form only, not when to commit or open one. Not for reviewing a diff (change-code-reviewer), sweeping the backlog (backlog) or archiving a change (openspec-archive-change).
metadata:
  tags: [git]
---

# commits-and-pull-requests

A pull request is what a reviewer opens, and what a later reader of the history opens instead of the commits. This skill gives the form a commit message and a pull request take, so that both say what changed, why, and what was verified.

Everything here is a default of form. It carries no obligation of its own: when to commit, when to open a pull request and what must be named in one are the development workflow's, and a session meets those whether or not it loads this skill.

## The project's conventions come first

Read the project before writing. Its commit-message convention, the pull request template its forge supplies, and whatever its `AGENTS.md` or `CLAUDE.md` says about commits or pull requests take precedence over this skill. Where a template sets the description's sections, follow the template and use the defaults below only for what it leaves open.

The defaults apply where the project is silent. This skill names no commit convention: which one a project's subjects follow is the project's decision, recorded at its foundation, and where it states none, write a plain subject rather than adopting one on its behalf.

## Commit messages

**Subject.** Follow the project's commit convention for the subject. Keep it to what the commit does, short enough to read in a one-line log.

**Body.** The body says why: the reason for the change, and what a reader cannot tell from the diff — the constraint that forced a choice, the alternative rejected, the incident behind it. Do not narrate the diff; it is one command away and a body restating it adds nothing. A commit whose subject says everything needs no body.

**Folded-in work.** The workflow requires folded-in work to have a commit of its own whose message says it is folded in, and to name the backlog entry it takes where it takes one. Say so in the subject or the body's first line, so the commit is identifiable as folded in from the log alone.

## Pull request title

The title states the effect of the pull request in plain words, for a reader who will not open the diff: what is different once it merges. A pull request spans several commits, often on different concerns, so its title is not one commit's subject and takes no commit-convention prefix, even where the project's commits do.

## Pull request description

Where the project's template does not settle it otherwise, the description carries four parts:

- **What changed** — at the level a reviewer needs before reading the diff: the behaviour or text that is different, not a file list.
- **Why** — the problem it answers, with a link or pointer to the change's record where the change has one, rather than restating the proposal.
- **What else** — each piece of folded-in work, which the workflow requires be named here, and any departure from the change's plan, with its reason.
- **Verification** — each check actually run on the branch head, with its result, and the review verdicts the change received.

A check that was not run is written as not run, with the reason it could not be — never listed among the passing checks. A description is read as evidence, and a check claimed but never run is the one failure a reviewer cannot see from the diff.

When the pull request changes after its description was written — commits added after review, a scope cut — revise the description so it describes the diff that merges, as it now stands, not the first one pushed.

## The workflow's pull requests

A change carried through the development workflow produces pull requests of three kinds. Each is described as above; each also says the following.

**The work** — the change's implementation. Its why points to the change's record.

**A fix** — work re-entering at the build review after an unhealthy deploy or an absent effect caused by a defect. Name the change it fixes, the earlier pull request that shipped the defect, and the defect itself, so the fix is readable without reconstructing the history.

**The record** — the last pull request of the change, carrying its specification record. Its content is in `references/record-pull-request.md`; read it when writing one.

## What this skill does not cover

When to commit, when a pull request is opened, and how many a change produces are stated by the development workflow and are not restated here. Reviewing a diff before the pull request is `change-code-reviewer`'s; sweeping the backlog against merged pull requests is `backlog`'s; archiving the change is `openspec-archive-change`'s.

## Trigger check fixtures

The prompts this skill's authoring verified against, with the routing expected of each. Per `create-skill`, no outcome or run date is recorded: a description edit, here or in any asset the evaluator holds, invalidates the check.

- **Positive** — "The branch is pushed and verification passed — write the title and description for the pull request." → expected routing: `commits-and-pull-requests`.
- **Negative** — "Before I open the pull request, review the committed diff on this branch against the change's delta specs." → expected routing: `change-code-reviewer`. Chosen because both assets sit at the moment just before a pull request is opened, and only what is asked for — a review of the diff, not the pull request's text — separates them.
