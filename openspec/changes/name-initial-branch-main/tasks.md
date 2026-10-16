## 1. Script

- [ ] 1.1 In `scripts/project-init`, after `git init` on the repository-creation path, resolve the branch as `git -C "$target" config --get init.defaultBranch`, falling back to `main`, and always run `git -C "$target" symbolic-ref HEAD refs/heads/<name>`; on its failure `finish_error` with a reason naming the initial-branch step (`design.md` Decisions 1–2).
- [ ] 1.2 Leave the `repository: already present` path untouched (Decision 3) and the report lines unchanged (Decision 4).
- [ ] 1.3 Keep the script bash 3.2-compatible and ShellCheck-clean.

## 2. Verification

- [ ] 2.1 Run `bash tests/run.sh`; every case, including the derived ones, passes.
- [ ] 2.2 Run `shellcheck scripts/project-init`.
- [ ] 2.3 Map the derived cases in `tests/coverage.md`.
