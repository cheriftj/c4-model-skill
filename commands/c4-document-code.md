---
description: Retro-document an existing codebase as a C4 diagram. Scans the repo, presents findings, then dialogues to fill ambiguities.
---

<!-- markdownlint-disable-file MD041 -->

You are handling a `/c4-document-code` invocation.

The user wants to **retro-document an existing codebase**. This is the `c4-model` skill's **Document-code mode** — skip mode detection and go straight to the scan + dialogue workflow.

Load `skills/c4-model/mode-document-code.md` and execute its steps:

1. **Quick framing** (max 3 questions): repo scope, expected levels, output format and destination.
2. **Scan**: for a repo larger than ~50 files or an unfamiliar stack, delegate to a sub-agent via the `Agent` tool with `subagent_type: Explore` using the inventory prompt in `mode-document-code.md`. Otherwise use `Glob` / `Grep` / `Read` directly.
3. **Present findings** as raw lists: candidate containers (with technology), external dependencies, identified flows, doubtful flows, ambiguities. Ask the user if the breakdown matches reality.
4. **Dialogue** to fill ambiguities (3-5 questions per batch). If the user doesn't know, mark it as an assumption.
5. **Draft, iterate, finalize** — produce Context + Container, run the checklist, deliver.

Inherit the common contract from `SKILL.md`. Inferences from code without explicit confirmation go into the *Assumptions* section of the document, never silently into the diagram.

If the user provided a repo path or description after `/c4-document-code`, use it as the scan target. Otherwise, ask which repo to document and what scope (whole monorepo or subfolder).
