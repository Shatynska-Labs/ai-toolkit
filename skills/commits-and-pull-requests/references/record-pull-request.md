# The record pull request

The record is the last pull request of a change: it carries the change's specification record to the trunk. Its reader wants to know what shipped, where it is now recorded, and what else the change's closing touched. Write its description from what the repository and the forge show, not from memory of the session.

**Title.** Name the change it records — for example `Archive <change-name>` — so the record is findable by the change's name.

**Description.** Say, in this order:

- **Which pull requests it records** — the number of every pull request that carried the change's work and fixes, not only the first.
- **The specification record** — which specifications the change's deltas were synced into, and where the change directory now sits in the archive.
- **The backlog re-read** — the entries the change completed, made obsolete, unblocked or made stale, and how each was updated. Where the re-read found no entry affected, say that it was made and that nothing was affected; an absent line cannot be told apart from a re-read that was skipped.
- **The workstream re-read** — where the change advanced a workstream, what was revised in it, or that it was archived. Where it advanced none, say so; where the re-read changed nothing, say that too.
- **Confirmation** — whether the change's effect was confirmed, and how; or, where the confirmation was waived, the waiver's class and where the waiver is recorded.

Folded-in work and verification are reported as in any description, where the record carries any.
