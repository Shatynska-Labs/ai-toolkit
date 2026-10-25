## Context

`project-bootstrap` owns the entry and workstream shapes and states them in the seeded files. `backlog-maintenance` reads them from the files and restates neither. The layout and the absent values are both in those shapes, so the change is to the seeded text and to the skill's reading of it. The workflow fragment names no field and is untouched.

## Goals / Non-Goals

**Goals:** an entry's fields take one line each and no blank line between; each empty field reads naturally; no existing backlog stops being readable.

**Non-Goals:**
- Rewriting any consumer's files. commerce-ops follows up on its own.
- Changing which fields exist, or their order.
- Changing the entry's prose paragraph, which stays a paragraph.

## Decisions

**1. A list, not bare lines.** Bare consecutive lines render as one paragraph in GitHub and in every Markdown preview, so the fields would run together exactly where people read the backlog. A list keeps one field per rendered line with no blank lines.

**2. The seeded entry shape:**

> ```
> ## `change-name`
>
> What the change is and why it is needed, written for a session that has not seen the work that found it.
>
> - **Priority**: …
> - **Kind**: …
> - **Waits on**: `nothing`, or something that can be checked: a change by name, a person's answer, an event.
> - **Design with**: the entries that share a design with this one, by name, or `none`.
> - **Workstream**: the workstream this entry is a step of or serves, by name, or `none`. An entry recorded by a change in a workstream takes that workstream unless it serves another goal. An entry without this field is `none`.
> - **Recorded by**: …
> - **Re-checked**: …
> ```

Each item keeps its current wording, except the three `nothing`s named here, which become `none`. The workstream shape lists Not in scope, Open questions, Decisions and Opened the same way, each with `none` for its absent value. An abandoned workstream gains `- **Abandoned**: <date>, <reason>` as the item after Opened, and the README's abandonment paragraph says so.

**3. `none` everywhere but Waits on.** Each field reads as its name followed by its value. *Waits on nothing* is English; *Design with nothing* and *Workstream nothing* are not, and *none* is. `none` is already the status row's word and a proposal's (`advances none`), so the absence of a workstream reads one way throughout.

**4. Old files stay readable, and the skill writes the file's value.** `project-init` never rewrites an existing file, so backlogs in the earlier layout and wording will persist. The skill reads paragraph fields as it reads listed ones, and an earlier `nothing` in a field the file now gives as `none` as that field's absent value. This is stated under *Entries in an older shape*, where the skill already handles a shape that has moved on. The skill writes what the file states: record and pick name the file's absent value, `none` in the seeded file, as Priority already names the file's default. In a backlog whose preamble still says `nothing`, record therefore writes `nothing`. Pick groups an entry naming no workstream apart, whichever word it carries.

**5. Tests.** By trial on the seeded text, the new layout fails 8 existing seeded-backlog cases, which locate a field by a line starting with `**Label**`: `backlog-seeded-priority-statements`, `-priority-values`, `-kind-definition`, `-workstream-default`, `-priority-transitions`, `-priority-no-low`, `-priority-field` and `-workstream-field`. The skill text's change will also fail `backlog-skill-record-workstream`, whose scan requires `nothing` beside Workstream. The derived tests specify the new layout and values, and each existing case asserting the old one is obsolete, judged at `apply` as the test plan lists it. `tests/lib.sh`'s `fenced_line` learns to accept a list marker, which keeps `backlog-seeded-workstream-field` (the derived case that takes it from there) working. `backlog-seeded-priority-field` declares its own copy and falls to the obsolete judgement with the rest.

## Risks / Trade-offs

- **Two absent words.** A reader has to know that Waits on says `nothing` and the rest say `none`. Mitigation: the seeded text states each field's own value beside it, so no rule needs remembering.
- **Mixed files during migration.** A consumer may hold paragraph entries and list entries side by side until it reformats. Mitigation: decision 4's reading of both.

## Migration Plan

New projects get the new text. ai-toolkit converts its own backlog in this change. commerce-ops converts in a follow-up pull request, mechanically, which is work too small to be a change.
