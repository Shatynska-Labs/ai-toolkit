## Context

The workflow fragment that `project-init` inlines tells every session to create a working tree inside the repository, at `.worktrees/<name>`. Its Claude Code binding notes that `EnterWorktree` uses `.claude/worktrees/` instead. Neither path is ignored in a project the tool initializes. This repository's own `.gitignore` already ignores both under `# Session working trees`, so the gap exists only in consuming projects.

## Goals / Non-Goals

**Goals:** a project initialized by the tool ignores every root the installed workflow puts a working tree under; the enumeration stays closed and stack-neutral.

**Non-Goals:**
- Rewriting an existing ignore file. The never-overwrite guarantee holds; `project-init` reports `already present` and does nothing else.
- Writing scoping configuration for test runners, linters or container builds. That configuration is stack-specific, so `project-init` writes none of it.
- Telling a project whose existing ignore file lacks the roots. See decision 4.
- Changing the workflow fragment or the managed block's version.

## Decisions

**1. Both roots, in a category of their own.** `.worktrees/` is the fragment's harness-neutral placement. `.claude/worktrees/` is where the fragment's own Claude Code binding says trees go. Both come from the workflow the tool installs, not from the project's stack, so they meet the requirement's bar for an enumerated entry. Omitting the binding's root would leave the gap open for the harness this toolkit ships to. Neither path fits the existing Environment, OS or Editors categories, so they get a category of their own, named `# Working trees`, placed last.

The created file becomes:

```
# Environment
.env
.env.*
!.env.example

# OS
.DS_Store
Thumbs.db

# Editors
.idea/
.vscode/

# Working trees
.worktrees/
.claude/worktrees/
```

**2. The boundary is stated in `project-bootstrap`, and the obligation is given to `project-foundation`.** The ignore file covers Git, and any tool that chooses to read it. A test runner that collects recursively, a linter, or a container build context sees the sibling trees unless it is kept out of them, and would then run or lint every other change's copy of the code. The tool cannot write that configuration without knowing the stack. So `project-bootstrap` states the boundary as information and forbids the tool from writing the configuration. The SHALL goes where an actor reads it: foundation's *Provisioning* concern, which already covers "what a new working tree needs before its verification can be trusted". A sibling tree's code leaking into verification is exactly that kind of trust failure. Extending an existing concern, rather than adding a named item, leaves foundation's fixed `Development Tooling` section list and its skill unchanged. An obligation stated only in `project-bootstrap` would repeat what lost it the first time: a statement no actor reads.

**3. The test asserts entries, not layout.** `gitignore-enumerated-entries.sh` checks for each entry's presence and for the absence of stack markers. It gains the two roots. None of its forbidden stack markers occurs in the new entries.

**4. The report stays silent about an existing ignore file's content.** The tool reports per concern whether it created something or found it present. It never inspects what a file the project owns says. Reporting missing entries would make the tool judge the content of a project file, and the entry set is open-ended: a project may already ignore the roots through a broader pattern. A project initialized before this change adds the two lines by hand. A notice belongs in a future update path, not in initialization.

## Risks / Trade-offs

- A project that already uses `.worktrees/` for something it means to track would see it ignored. This only applies to newly created ignore files, where nothing is tracked yet, and the project can edit the file. Accepted.
