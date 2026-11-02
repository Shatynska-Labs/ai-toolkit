## 1. The rule

- [x] 1.1 State in `AGENTS.md` that the plugin's version rises with every shipped change and what each size means, and verify the case for *The rule is stated* passes.
- [x] 1.2 Raise `.claude-plugin/plugin.json` to `2.0.0`, and verify `tests/cases/plugin-version-semantic.sh` and the derived cases pass.

## 2. Close

- [x] 2.1 Revise the workstream's Context sentence on the plugin's version so it states the rule rather than a current number, and verify it no longer says the version has stayed `0.2.0`.
- [x] 2.2 Describe the check in `tests/README.md`, record the derived cases in `tests/coverage.md`, including the case running the check over this repository, and verify `bash tests/run.sh` and `openspec validate raise-the-plugin-version-on-release --strict` pass.
