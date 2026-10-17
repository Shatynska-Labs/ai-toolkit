## Context

`docs/backlog.md` exists in seven local projects, each written by its first session: three share one long header (numbered headings, a paragraph explaining numbers are not stable, "things deliberately not done" mixed in), the others carry shorter variants. The recurring entry fields across them are the change's name as heading, what and why, where it was recorded, and what it depends on or when to take it. `scripts/project-init` creates the ignore file from a heredoc and reports each concern on one line; the backlog is a fifth concern of the same kind.

## Goals / Non-Goals

**Goals:** a project gets the backlog with its rules from the tool; the fragment loses the rules it now defers; entry numbers disappear from both.

**Non-Goals:** rewriting any existing project's backlog, including this repository's own `docs/backlog.md`; a tool route for reconciling an older managed block (out of scope for the tool, as today).

## Decisions

**The seeded text lives in the script as a heredoc**, as the ignore file does. A separate template file would need a resource-location rule and a precondition for its absence; the heredoc has neither, and the text is the script's output, not a library asset.

**The spec fixes what the text states, not the text verbatim.** The ignore file is enumerated verbatim because its entries are atoms an adjective would let grow. The backlog header is prose; fixing its statements keeps it checkable and leaves its wording editable without a spec delta. The test asserts each statement by a stable phrase.

**The seeded text:**

````markdown
# Backlog

Changes this project has identified and not yet archived. Each entry is a change recorded here instead of being folded into the change that found it, or opened on a branch of its own.

An entry's heading is the change's name in kebab-case — the name its branch and change directory are expected to take, though the session that opens the change may rename it if the work turns out different. Refer to an entry only by that name.

The order of entries carries no meaning. If an entry waits on another change, or should come before or after one, it says so itself.

Delete an entry when its change is archived, when the operator takes it as a fix rather than a change, or when the operator decides the change will not be made. Keep this file when it has no entries.

An entry takes this shape:

```
## `change-name`

What the change is and why it is needed, written for a session that has not seen the work that found it.

**Recorded by**: the change that identified it, and why it was not done there.

**Depends on**: the changes that must land first, or nothing.
```
````

The example heading sits inside a fence, so a heading scan of the file finds only `# Backlog` and no entry.

**The fragment's backlog paragraphs become one.** The routing bullet keeps "record it in `docs/backlog.md`, or open the identified change", without "creating that file if absent". The three closing paragraphs are replaced by one: the backlog holds identified changes recorded rather than opened — the scope rule's separate proposed change — sits outside any change because a note kept inside one is archived with it, and states itself how an entry is written and when it is deleted. The waiver sentence's "its backlog entry" stays. Version 5 → 6.

**Report line:** `backlog: created | already present`, printed after the ignore file line. The backlog is checked before any write, like the other concerns, as `[ -e ] || [ -L ]`, so a dangling link counts as present and is never written through. A `docs/` that is itself a link is followed: where a project keeps its documents is its own decision, and the backlog belongs with them.

**Ownership.** `project-bootstrap` owns the entry rules it seeds; `session-workflow` keeps routing. This avoids widening `session-workflow`'s publication requirement, which names the two fragments as the only places its obligations are published.

## Risks / Trade-offs

- [A project that takes the rules by `@` import never runs the tool and has no backlog until a session creates one, now with no instruction to] → accepted by the operator to keep the fragment short; the routing rule still names the path.
- [Every adopting project reports version skew after this] → expected, and the tool already reports it rather than rewriting.
- [`docs/` created in an adoption repository that had none] → it holds only the backlog; consistent with the tool already creating `AGENTS.md` and `.gitignore` there.
