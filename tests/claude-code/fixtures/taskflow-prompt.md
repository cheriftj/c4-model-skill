<!-- markdownlint-disable-file MD041 -->
<!-- This file holds the prompt body for test-c4-model-integration.sh. -->
<!-- It is fed verbatim to `claude -p`, so it intentionally has no title. -->

Use the c4-model skill to produce a C4 architecture for the following system.
All framing information is provided below, so you can skip Phase 0 framing
questions and proceed directly to producing the final deliverables.

System:             TaskFlow
Business intent:    a cloud-based task-management SaaS for small teams.
Audience:           engineering team, used for onboarding new hires.
Levels requested:   Context + Container only.
Format:             Mermaid C4 + Markdown per level (default).
Destination:        local filesystem, in docs/architecture/.
Hard constraints:   must run on AWS, SOC 2 compliance target.

Actors:

- Small-team employees (primary users)
- Team admins
- Internal support staff

External systems:

- Stripe (billing)
- Auth0 (SSO / identity)
- SendGrid (email delivery)
- Datadog (observability)

Internal containers:

- Web SPA: React + TypeScript, runs in the browser
- Public API: Node.js + Fastify, exposes JSON/HTTPS
- Background worker: Node.js, processes async jobs
- Postgres 15: primary datastore
- Redis: session cache + job queue

Flows:

- SPA -> API:        JSON/HTTPS
- API -> Postgres:   SQL over TCP
- API -> Redis:      RESP (session read/write)
- API -> Auth0:      OIDC over HTTPS
- API -> Stripe:     JSON/HTTPS (outbound calls + inbound webhooks)
- API -> SendGrid:   REST over HTTPS
- Worker -> Redis:   RESP (consumes jobs)
- Worker -> Postgres: SQL (writes results)
- Worker -> SendGrid: REST over HTTPS (scheduled emails)
- All containers -> Datadog: StatsD/HTTPS for metrics

Produce the Context and Container diagrams as deliverables. Write them to:

- docs/architecture/01-context.md
- docs/architecture/02-container.md

Apply every rule of the c4-model skill: technology on every Container,
intent-specific relation labels (no bare "Uses" / "Calls" / "Reads"), protocols
on inter-container relationships, an Assumptions section in each document,
and the level-template structure.
