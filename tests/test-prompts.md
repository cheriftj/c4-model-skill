# Test prompts — validating the c4-model skill

These prompts are sanity checks. Each one should:

1. **Trigger the skill** (Claude recognizes this as architecture work)
2. **Route to the expected mode**
3. **Follow the expected flow** (framing → drafts → validation → delivery)

There is no automation. Walk through them mentally with a fresh Claude Code session when you change `SKILL.md`, a `mode-*.md` file, or one of the sourced references. A change is safe to ship when every prompt below still routes and flows correctly.

## Mode: Design

**Prompt**

> I'm starting a new event-sourced order management platform. Can you help me architect it? Think order capture, inventory check, payment, fulfillment — typical e-commerce surfaces.

**Expected routing**: Design.

**Expected flow**:
1. Phase 0 — framing questions (system name, audience, levels, format, constraints) in a single batch of ≤5
2. Phase 1 — reformulate scope, ask about actors and external systems, present a first Context draft, wait for validation
3. Phase 2 — walk through containers (services, data stores, brokers), technologies, flows; present Container draft; validate each relationship's intent label
4. Phase 3 — skipped unless user asks for Component
5. Phase 4 — run checklist, list residual assumptions, deliver to chosen destination, ask for finalization

**Red flags**:
- Claude produces a diagram in the first message without asking anything
- More than 5 questions in a single batch
- Generic labels like "Uses" or "Calls" in the Container draft
- Skips validation and writes files without an explicit "finalized"

## Mode: Document-code

**Prompt**

> Here's my project: [pastes a path or repo link, or says "this codebase"]. Can you draw me a C4 of it?

**Expected routing**: Document-code.

**Expected flow**:
1. Quick framing (scope of the repo, levels expected, format/destination) — ≤3 questions
2. Scan: if the repo looks > ~50 files or the stack is unfamiliar, **delegation to an Explore sub-agent** (the `Agent` tool with `subagent_type: Explore`); otherwise direct `Glob` / `Grep` / `Read`
3. Findings presented as raw lists (candidate containers, external deps, flows, ambiguities) — then asks if it matches the user's mental model
4. Dialogue to fill ambiguities, batches of 3-5
5. Draft + iteration + checklist + delivery

**Red flags**:
- Claude grepped the whole repo in the main thread instead of delegating on a big codebase
- Diagram invents a `Container` that isn't justified by the scan output
- Silently assumes a technology instead of listing it under Assumptions

## Mode: Document-prose

**Prompt**

> Here's our architecture overview doc — can you give me a C4 from it?
>
> [Pastes 1-2 pages of free-form prose describing a system]

**Expected routing**: Document-prose.

**Expected flow**:
1. Extraction: systems, actors, external systems, candidate containers, technologies, explicit flows
2. Two-column presentation: *what we understood* / *what's missing*
3. Dialogue to fill gaps — batches of 3-5
4. Draft + checklist + delivery

**Red flags**:
- Claude fills a gap by invention rather than by asking
- Missing items don't show up under Assumptions in the final document

## Mode: Review

**Prompt**

> Can you review this Container diagram?
>
> ```mermaid
> C4Container
>     title My API
>     Container(api, "API", "Node")
>     ContainerDb(db, "DB")
>     Rel(api, db, "Uses")
> ```

**Expected routing**: Review (critique sub-mode).

**Expected flow**:
1. Walk through the review checklist
2. Group remarks by severity (blocking / important / nice-to-have) — here: missing title scope, "Uses" is vague, DB has no technology, no legend, no scope/description
3. **Concrete** correction suggestions (not just "add a label")
4. Offer to apply corrections (→ Update mode)

**Red flags**:
- Review is general ("this needs more detail") rather than item-by-item
- Misses a blocking rule (like the missing technology on the DB)

## Mode: Update

**Prompt**

> I have a Container diagram in `docs/architecture/02-container.md`. I just added a Redis cache in front of the API to reduce mainframe latency. Can you update the diagram?

**Expected routing**: Update.

**Expected flow**:
1. `Read` the existing file
2. Clarify the diff: Redis position (between API and Mainframe? in front of the API? cache-aside from the API?), technology details, new relationships' labels and protocols
3. Identify affected levels (Container always; Context if the external Mainframe relationship label changes)
4. Update "Architectural decisions" to capture the latency rationale
5. Validate → deliver via `Write` / `Edit` depending on the scope of the change

**Red flags**:
- Claude re-generates the whole C4 from scratch instead of surgically adding Redis
- Decision rationale (*"why add a cache"*) is missing from the updated "Architectural decisions" section

## Supporting diagrams

**Prompt**

> We deploy across three AWS regions with separate RDS per region and a global CloudFront in front. Can you show me how that looks?

**Expected routing**: Supporting diagrams → C4Deployment.

**Expected flow**:
- Claude loads `supporting-diagrams.md`
- Proposes a `C4Deployment` with nested `Deployment_Node`s
- Each container from the Container diagram should map to a deployment node, no "ghost" containers

**Red flags**:
- Produces a new Container diagram instead of a Deployment
- Invents containers not previously defined at the Container level

---

## How to read the results

If any red flag appears when running a prompt:

1. Check `SKILL.md` first (is the router still clear?)
2. Check the matching `mode-*.md` (is the flow still concrete?)
3. Check `review-checklist.md` (did a rule drift out?)
4. Fix the guidance, not the output — a prompt-specific fix will not generalize
