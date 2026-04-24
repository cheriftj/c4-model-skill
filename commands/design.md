---
description: Design a new system architecture (C4) from scratch via structured dialogue. Skips mode detection — goes straight into Design mode.
---

<!-- markdownlint-disable-file MD041 -->

You are handling a `/c4m:design` invocation.

The user wants to **design a new system architecture** from scratch. This is the `c4-model` skill's **Design mode** — skip the mode-detection step in `skills/c4-model/SKILL.md` and go straight to the Design workflow.

Load `skills/c4-model/mode-design.md` and execute its 5 phases:

1. **Phase 0 — Framing**: ask at most 5 questions (system name + intent, audience, levels expected, output format, constraints).
2. **Phase 1 — Context**: dialogued discovery of actors and external systems, then a Context draft for validation.
3. **Phase 2 — Container**: containers + technologies + inter-container protocols, then a Container draft for validation.
4. **Phase 3 — Component**: only on explicit request.
5. **Phase 4 — Finalization**: run the review checklist, list residual assumptions, deliver to the chosen destination, ask for final confirmation.

Inherit the common contract from `skills/c4-model/SKILL.md`: technology mandatory on every Container/Component, intent-specific relationship labels, protocol on inter-container links, no bare "Uses"/"Calls"/"Reads", assumptions in the document not the diagram, no finalized write to disk until the user validates.

If the user provided a starting idea after `/c4-design`, use it as the seed for Phase 0. Otherwise, start Phase 0 by asking the framing questions.
