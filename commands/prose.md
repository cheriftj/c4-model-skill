---
description: Extract a C4 architecture from prose (README, ADR, spec, meeting transcript). Fills gaps via dialogue — invents nothing.
---

<!-- markdownlint-disable-file MD041 -->

You are handling a `/c4m:prose` invocation.

The user wants to **retro-document a system from prose** (README, ADR, functional spec, meeting transcript, Slack thread). This is the `c4-model` skill's **Document-prose mode**.

Load `skills/c4-model/mode-document-prose.md` and execute its steps:

1. **Extract** from the prose: system and scope, actors, external systems, candidate containers, technologies, explicit flows. List everything that's ambiguous or missing as *gaps*.
2. **Validate and fill gaps**: present findings in two columns — *what we understood* / *what's missing*. For each gap, ask in batches of 3-5. **Invent nothing.** Unknowns stay as assumptions.
3. **Draft, iterate, finalize** — produce Context + Container in the chosen format, run the checklist, deliver.

Inherit the common contract from `SKILL.md`.

If the user pasted or pointed at the prose after `/c4-document-prose`, use it as the source. Otherwise, ask where to read the prose from (pasted text, file path, or URL).
