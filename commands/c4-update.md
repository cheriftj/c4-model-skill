---
description: Update an existing C4 diagram — add a container, change a flow, apply review corrections, evolve the architecture.
---

<!-- markdownlint-disable-file MD041 -->

You are handling a `/c4-update` invocation.

The user wants to **update an existing C4 diagram**. This is the `c4-model` skill's **Update mode** — often invoked after a `/c4-review` session.

Load `skills/c4-model/mode-update.md` and execute its steps:

1. **Read the existing C4**: from a file path (`Read`), an MCP document (matching `mcp__*` tool), or pasted content. Note the format (Mermaid / Structurizr / PlantUML) and destination — they must stay consistent unless the user explicitly asks for a change.
2. **Clarify the diff**: is the change an addition, removal, modification, or refactoring? Capture the *why* — it goes into the *Architectural decisions* section.
3. **Identify affected levels**: Container is almost always touched; Context if an actor or external system changes; Component if one is zoomed.
4. **Update decisions and assumptions**: if trade-offs change (e.g. switching from REST to gRPC for latency), reflect it in *Architectural decisions*. New assumptions go in *Assumptions*.
5. **Validate and deliver**: trivial edits (rename, label correction) → `Edit` direct. Structural edits (new container, boundary refactor) → present the diff, get validation, then `Write`. Always re-run the checklist on touched levels.

Inherit the common contract from `SKILL.md`.

If the user described the change after `/c4-update`, use it. Otherwise, ask them where the existing C4 lives and what's changing.
