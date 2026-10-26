## MODIFIED Requirements

### Requirement: The minimal ignore file is enumerated, not described

Where no ignore file exists, the tool SHALL create one containing exactly these entries and no others:

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

The entries are enumerated here, in the specification, rather than characterized as "minimal" or "generic". An adjective invites growth that each addition can justify individually; an enumeration does not. They are enumerated *here* rather than in a design document because a design document is archived with its change, while this requirement outlives it — a durable constraint that pointed at a transient file could not be checked later.

The working-tree entries are the roots the workflow the tool installs places a change's working tree under: `.worktrees/` by the workflow's own rule, and `.claude/worktrees/` by its Claude Code binding. Unignored, a sibling working tree fills the main tree's `git status`, and `git add -A` commits it as an embedded repository.

The tool SHALL NOT include stack-specific entries. It cannot know the project's language, and a wrong entry asserts something false about the project. Stack-specific exclusions belong to foundation discovery as a deliverable.

The ignore file reaches only tools that read it. A recursive tool that does not — test collection, a linter, a container build context — still descends into the working-tree roots. Keeping such tools out of them is stack-specific configuration, which foundation discovery decides under its provisioning concern; the tool SHALL NOT write any of it.

#### Scenario: Created ignore file carries no stack assumption

- **WHEN** an ignore file is created in a directory whose language is not yet decided
- **THEN** it contains only the four enumerated categories, and no entry naming a language's dependency directory, build output, or cache

#### Scenario: Created ignore file ignores the working-tree roots

- **WHEN** an ignore file is created
- **THEN** it contains `.worktrees/` and `.claude/worktrees/`
