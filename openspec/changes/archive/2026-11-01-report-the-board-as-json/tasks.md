## 1. The flag

- [x] 1.1 Parse `--json`, send the report and blocked outcomes to standard error under it, and refuse it with `--output`, whichever order the arguments come in, and verify the cases for a blocked run, a usage error, a failed run, the report under `--json` and with an output pass

## 2. The document

- [x] 2.1 Add `jstr` and the JSON renderer to `board.awk`, keeping each entry's raw body and warnings as text, printing the document only once complete, and verify the cases for a document and for hard characters pass
- [x] 2.2 Emit every field the requirement names, with its type, and verify a case fixes the key set and `schema_version`, and that `warnings` is the sum of the lists
- [x] 2.3 Verify the cases pass that compare status, stage and placement with the page, and that the trunk's three states, a step of two workstreams, a step with another workstream's entry value, a closed workstream, a task with no workstream and an unreached forge read as stated

## 3. Documentation and verification

- [x] 3.1 Add `--json` to `--help`, the document's contract and an example to `tests/README.md`, and its cases to `tests/coverage.md`, and verify they match the output
- [x] 3.2 Run ShellCheck and `bash tests/run.sh`, run the tool with `--json` on commerce-ops, and verify the document parses and every task's status matches the page's
