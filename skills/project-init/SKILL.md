---
name: project-init
description: >
  This skill should be used when the user wants to initialize a new project
  into this repository's development workflow, or adopt that workflow in an
  existing project — "set up a new project", "initialize this repo",
  "bootstrap this project for spec-driven development", "adopt this
  workflow here", "run project-init". It resolves the ai-toolkit toolkit
  root, invokes the deterministic `scripts/project-init` tool, relays its
  report verbatim, offers a new project's first commit, connects a remote
  from a URL the user supplies, and names foundation discovery as the next
  step without starting it. The tool performs only deterministic
  setup — Git, OpenSpec, a seeded `docs/backlog/` README, a managed workflow
  block in `AGENTS.md` — and the skill never creates a hosted repository
  or makes any judgment about the project's identity, scope, or
  architecture;
  for those, see `project-foundation`, which it never invokes itself. Not
  for authoring library assets (`create-skill`, `create-agent`) and not for
  proposing an OpenSpec change once a project already has a foundation
  (`openspec-explore`, `openspec-propose`).
metadata:
  tags: [project-lifecycle, openspec]
---

# project-init

A thin wrapper around `scripts/project-init`. Every decision about what initialization creates belongs to that script; this skill's job is to find it, run it, relay what it says, and then take the two steps the script cannot, because each needs the user's answer: the repository's first commit, and connecting a remote. It takes the mode — new project or adoption — from the tool's report and never re-derives it: a new project's `Next step:` line names foundation discovery as the next step, an adoption's begins `none required`.

## 1. Resolve the toolkit root

Try, in order, stopping at the first that resolves:

1. `$AI_TOOLKIT_ROOT`
2. `$CLAUDE_PLUGIN_ROOT`
3. the machine-local default, `~/projects/shatynska/ai-toolkit`

If none resolves, report yourself blocked — name what you looked for — and stop. Do not fall back to running `git init` or `openspec init` directly, and do not write the workflow rules from memory. An improvised equivalent produces a project initialized differently from every other one while looking like it succeeded, which is the exact failure this workflow exists to prevent.

## 2. Invoke the tool

Run it through its interpreter, never as a bare path:

```
bash "<resolved-root>/scripts/project-init" [--tools <value>] [TARGET_DIR]
```

Pass through whatever the user specified (a `--tools` value, a target directory other than the current one). Do not parse or second-guess the tool's internal logic — it owns every decision about what gets created, skipped, or reported.

## 3. Relay the report

Show the user what the tool printed — target directory, each concern and its outcome, the terminal outcome, and the next step. Do not summarize away detail the report considered worth stating (an import line the user needs to add, a version mismatch in an existing managed block, files a delegated command wrote).

If the tool reported `BLOCKED` or `ERROR`, stop here. Explain the reason from the report; do not attempt the failed step yourself.

## 4. Offer the first commit, on `SUCCESS` in a new project only

The first commit of a repository with no commit is the one commit the workflow lets reach the trunk directly, because there is no branch yet for a pull request to merge into. Offer it only when the report shows a new project.

Every git command in this step and the next runs against the target directory the report's `Target:` line names, as `git -C <target> …`, never the current directory: a target passed through in step 2 may differ from it.

Before asking, show what the commit would contain, not only what the tool wrote: the target may already hold the project's own files. List every already staged path that the commit would include, and every untracked path git does not exclude through the ignore file or its other standard exclusions. A wholly untracked directory may be listed as one entry. `git -C <target> status --short --untracked-files=normal` gives both, whatever the user's `status.showUntrackedFiles` setting.

Wait for confirmation — never commit without it, per this workflow's own rule that commits are suggested, not automatic. On confirmation, stage with `git -C <target> add -A`, which takes exactly the paths listed, and commit with `git -C <target> commit`. If the user declines the initial commit, say that the repository's first commit and a remote are both still outstanding and that the workflow's first pull request needs both, then go to step 6.

In an adoption, offer no commit onto the current branch: the repository already has a trunk, and the tool's writes reach it through a pull request like any other change. Where the adopted repository has no remote configured, also say that a remote is needed before that pull request can be opened.

## 5. Connect a remote, after the first commit

Where the first commit was made and `git -C <target> remote` lists nothing, ask the user for the URL of a hosted repository they have created. Never create one yourself, and never choose its forge, owner, name or visibility — each is a judgment about the project. Where a remote is already configured, leave it unchanged and do not ask for one.

When the user supplies a URL, confirm before acting, since a push is outward-facing; on confirmation run `git -C <target> remote add origin <url>`, then push the current branch with its upstream set: `git -C <target> push -u origin HEAD`.

If the push fails or is rejected — the hosted repository is not empty, the URL is unreachable, access is refused — relay git's message, say that `origin` now names the supplied URL, and stop: correcting the remote and pushing are the user's. Do not force the push, and do not fetch, merge or rebase the remote's history to make it succeed. Re-running the tool will not return here, since the repository now has a commit.

If the user declines or supplies no URL, say that the workflow's first pull request needs a remote with the trunk pushed to it, and continue to step 6.

## 6. Name the next step; never take it

The tool's report already names the next step. Repeat it back and stop there:

- **New project** — name foundation discovery (`project-foundation`) as available. Do not begin that conversation yourself; starting an open-ended discovery conversation decides that this is the right moment to spend an hour on it, and that decision belongs to the user.
- **Adoption** — the report already states that foundation discovery is available if the project's decisions should be recorded retroactively. Relay that; nothing further is required.

## Trigger check fixtures

- **Positive** — "I'm starting a brand new project, can you set it up with git, openspec, and the usual conventions?" → expected routing: `project-init`.
- **Negative** — "This project already exists — help me figure out what it actually is, its scope, and what tech stack makes sense." → expected routing: `project-foundation`.
