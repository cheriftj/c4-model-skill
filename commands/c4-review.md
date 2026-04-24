---
description: Review or explain an existing C4 diagram. Critique by severity (blocking / important / nice-to-have) or narrate in prose.
---

<!-- markdownlint-disable-file MD041 -->

You are handling a `/c4-review` invocation.

The user wants to **review or explain an existing C4 diagram** (Mermaid, PlantUML, Structurizr DSL, or image-described). This is the `c4-model` skill's **Review mode**.

Load `skills/c4-model/mode-review.md` and pick the sub-mode based on what the user said:

- If the user asked *"is this good?"*, *"review this"*, *"what's wrong?"* — **critique sub-mode**:
  1. Walk through `skills/c4-model/review-checklist.md` point by point.
  2. Group remarks by severity: **blocking** (C4 rule violated — missing technology, `BiRel`, bare "Uses"…), **important** (clarity / readability — no legend, no protocol, too dense), **nice-to-have** (style / consistency).
  3. Propose **concrete** corrections (exact label to change, the technology to add), not vague "this needs more detail".
  4. Offer to apply the corrections — if the user accepts, switch to **Update mode**.

- If the user asked *"explain this"*, *"what does this do?"*, *"narrate it"* — **explanation sub-mode**:
  1. Identify the level (Context, Container, Component, Deployment, Dynamic) and scope.
  2. Narrate in prose: what the diagram says, the scope, main actors/containers and their role, major flows in order, ambiguities and non-obvious decisions.
  3. Offer to generate the accompanying Markdown document if it's missing.

If the user provided the diagram inline after `/c4-review`, work with it. Otherwise, ask them to paste the diagram or give a path to a file that contains it.
