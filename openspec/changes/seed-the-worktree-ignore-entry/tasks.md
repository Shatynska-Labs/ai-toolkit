## 1. Tool

- [ ] 1.1 In `scripts/project-init`'s ignore-file heredoc, add the `# Working trees` category with `.worktrees/` and `.claude/worktrees/` after `# Editors`, preceded by one blank line (design.md decision 1). Verify with the derived case

## 2. Foundation checklist

- [ ] 2.1 In `rules/project-foundation.md`, extend the *Provisioning* concern's line so that it covers keeping tools that recurse the tree without reading the ignore file out of the roots the workflow places working trees under (`.worktrees/`, `.claude/worktrees/`), named by that source rather than by what the ignore file says, and naming no tool (design.md decision 2). Verify by reading, and that the checklist's item list and `design.md` section list are unchanged

## 3. Tests and records

- [ ] 3.1 Account in `tests/coverage.md` for the modified scenario *Created ignore file carries no stack assumption*, the added scenario *Created ignore file ignores the working-tree roots*, and the added `project-foundation` scenario *Recursive tools are kept out of the working-tree roots*

## 4. Verify

- [ ] 4.1 `bash tests/run.sh` passes
- [ ] 4.2 `shellcheck scripts/project-init tests/*.sh tests/cases/*.sh tests/cases/lib/*.sh` is clean
