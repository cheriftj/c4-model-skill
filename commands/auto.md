---
description: Co-build a C4 architecture diagram (Simon Brown's model) interactively. Detects the mode (design, document-code, document-prose, review, update) and runs the matching workflow.
---

<!-- markdownlint-disable-file MD041 -->

You are handling a `/c4m:auto` invocation. Load the skill at `skills/c4-model/SKILL.md` and follow its workflow.

## What the user may have given you

After `/c4m:auto`, the user may have passed one of:

- A short architecture idea or system description → route to **Design mode**.
- A path to a repository or source code → route to **Document-code mode**. For repos larger than ~50 files or an unfamiliar stack, delegate the initial scan to a sub-agent via the `Agent` tool with `subagent_type: Explore` (see `skills/c4-model/mode-document-code.md` for the scan prompt).
- A pasted README, ADR, spec, or other prose → route to **Document-prose mode**.
- A pasted Mermaid, PlantUML, or Structurizr diagram → route to **Review mode**.
- An existing C4 + a change request → route to **Update mode**.
- Nothing → ask which mode applies: *"Do you want to design a new architecture, retro-document an existing system, review an existing diagram, or update a C4?"*

## Rules (inherited from SKILL.md)

Apply the skill's common contract before producing any diagram:

- Ask framing questions in batches of at most five, with explicit validation at every level. No finalized delivery to disk until the user confirms.
- Format and destination are negotiated. Default: Mermaid C4 + Markdown under `docs/architecture/`. Alternatives: Structurizr DSL, PlantUML, images; local filesystem or connected MCP (Notion, Linear, Drive).
- Simon Brown's golden rule: Context + Container are the default. Produce Component / Code only on explicit request.
- Every Container and Component states its technology. Relationship labels state intent (ban bare "Uses", "Calls", "Reads"). Inter-container relationships state the protocol.
- Assumptions inferred without confirmation go in the "Assumptions" section of the document, never silently into the diagram.
- Pass `skills/c4-model/review-checklist.md` before delivering.

Begin by identifying the mode, then proceed.
