# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

This repo hosts a **Claude Code skill**, not an application. The skill `c4-model` teaches Claude how to produce C4 architecture diagrams (Simon Brown's model) as Mermaid + accompanying Markdown, across five distinct usage modes (design, document-code, document-prose, review, update) plus supporting diagram variants (Landscape, Deployment, Dynamic). Changes are validated manually by reading the skill end-to-end, by walking the test prompt matrix, and by running the automated test suite in `tests/claude-code/`.

The skill is authored in **English**. Keep prose, examples, and section headings in English when editing `SKILL.md` and its bundled files. The frontmatter `description` intentionally keeps a few French trigger phrases (*"modèle C4"*, *"diagramme d'architecture"*) to widen discoverability for bilingual users.

## Layout and how the pieces connect

```text
.
├── README.md                                     # Public-facing landing page (GitHub visitors)
├── LICENSE                                       # MIT
├── CHANGELOG.md                                  # Release history (Keep a Changelog format)
├── CONTRIBUTING.md                               # How to propose changes
├── CODE_OF_CONDUCT.md                            # Contributor Covenant v2.1 (by reference)
├── CLAUDE.md                                     # This file — guidance for Claude Code
├── .claude-plugin/
│   └── marketplace.json                          # Claude Code marketplace catalog and plugin manifest (single source of truth)
├── commands/                                     # Slash commands registered via marketplace.json
│   ├── c4-model.md                               # /c4-model — auto-detects the mode from the user's message
│   ├── c4-design.md                              # /c4-design — skip detection, go to Design mode
│   ├── c4-document-code.md                       # /c4-document-code — Document-code mode
│   ├── c4-document-prose.md                      # /c4-document-prose — Document-prose mode
│   ├── c4-review.md                              # /c4-review — Review mode (critique or explain)
│   └── c4-update.md                              # /c4-update — Update mode
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                                # Always-on: lint, JSON validation, shellcheck, link check
│   │   └── release.yml                           # Tag-triggered: auto-publishes GitHub Release from CHANGELOG
│   └── PULL_REQUEST_TEMPLATE.md                  # PR checklist (editorial invariants, validation steps)
├── .markdownlint.json                            # Markdown lint configuration
├── .gitignore
├── tests/
│   ├── test-prompts.md                           # Manual test matrix (human-readable)
│   └── claude-code/                              # Automated test suite
│       ├── README.md
│       ├── run-skill-tests.sh                    # Orchestrator (--verbose, --integration, --test, --timeout)
│       ├── test-helpers.sh                       # Shared helpers: run_claude, assert_contains, etc.
│       ├── test-c4-model.sh                      # Fast test (~2 min, targeted Q&A)
│       ├── test-c4-model-integration.sh          # Integration test (~3-5 min, full Design workflow)
│       └── fixtures/
│           └── taskflow-prompt.md                # Prompt body for the integration test
└── skills/c4-model/
    ├── SKILL.md                                  # Entry point — router + common contract, loaded every time
    ├── level-template.md                         # Markdown template Claude MUST use for each generated level
    ├── mode-design.md                            # Greenfield brainstorm — 5 dialogued phases
    ├── mode-document-code.md                     # Retro-doc from a codebase (delegates heavy scan to Agent/Explore)
    ├── mode-document-prose.md                    # Retro-doc from prose (README, ADR, spec…)
    ├── mode-review.md                            # Critique or explain an existing diagram
    ├── mode-update.md                            # Evolve an existing C4
    ├── supporting-diagrams.md                    # System Landscape, C4Deployment, C4Dynamic
    ├── mermaid-c4-syntax.md                      # Full Mermaid C4 syntax (sourced from mermaid.js.org)
    ├── review-checklist.md                       # Pre-delivery checklist (sourced from c4model.com)
    └── examples/
        ├── 01-context.example.md                 # Filled-out Context deliverable (Internet Banking System)
        └── 02-container.example.md               # Filled-out Container deliverable (same system)
```

The skill's canonical location in this repo is `./skills/<name>/`, matching the convention used by `anthropics/skills` and community marketplaces. The folder name (`c4-model`) must match the `name` field in `SKILL.md`'s frontmatter **and** in `.claude-plugin/plugin.json`.

### Progressive disclosure pattern

`SKILL.md` stays lean. It is the **router + shared contract** loaded every time the skill triggers. Detailed per-mode flows live in `mode-*.md` and are read on demand once the mode is detected. If you rename or move any of these files, update every reference in `SKILL.md` (the router table and the "Bundled references" section both point to them).

Two reference files (`mermaid-c4-syntax.md`, `review-checklist.md`) are grounded in authoritative external sources; keep a pointer to the source URL at the top so they can be re-synced if the upstream evolves. Editorial additions on top of sourced content must stay clearly labeled (*"Editorial advice"*, *"Additions specific to this skill"*).

## Editorial invariants

These rules are load-bearing for the skill's output quality. Preserve them when editing:

- **Mode detection first**: every run starts with identifying the mode (design / document-code / document-prose / review / update). Don't produce a diagram without knowing which workflow applies.
- **Simon Brown's golden rule**: Context + Container diagrams are enough for most teams. Levels 3 (Component) and 4 (Code) are produced only on explicit request or clear need. Don't dilute this guidance.
- **One Markdown document per level**, never a bare Mermaid block. The `level-template.md` structure (Overview / Diagram / Legend / Elements / Key relationships / Architectural decisions / Assumptions / Links) is the canonical shape.
- **Relation labels must state intent**: ban generic "Uses" / "Calls" / "Reads". Inter-container relations must include the protocol (HTTPS/JSON, gRPC, AMQP, JDBC, SMTP…).
- **Technology is mandatory** on every Container and Component.
- **Assumptions stay explicit**: anything inferred from partial info belongs in the "Assumptions" section, not silently baked into the diagram.
- **Interactive by default**: no finalized delivery without explicit user validation. The one exception is when the user asks for a quick v1 ("just generate a draft"); in that case produce it with assumptions clearly labeled.
- **Format and destination are negotiated**, not hardcoded. Default Mermaid + Markdown in `docs/architecture/` is a fallback, not a decision.

The review checklist in `review-checklist.md` is the source of truth for what "done" means; any new rule added to `SKILL.md` should be reflected there too (and vice versa) to avoid drift.

## Frontmatter contract

`SKILL.md` starts with YAML frontmatter (`name`, `description`). The `description` is what Claude Code matches against user requests to decide whether to load the skill. It intentionally mixes English primary content with a few French trigger phrases ("modèle C4", "diagramme d'architecture") to widen discoverability. When editing, keep the English-first voice but preserve the French triggers and keep the trigger phrases broad enough to fire proactively on architecture-overview requests.

Keep the plugin entry in `.claude-plugin/marketplace.json` in sync with the skill's `name` and with the current version (`version` field, following SemVer).

## Validating changes

CI runs cheap, deterministic checks (markdownlint, JSON schema for the manifests, shellcheck, link check). The `claude -p` skill tests stay local because their output is non-deterministic. Validation before a PR is manual and comes in three layers:

1. **Read `SKILL.md` end-to-end** as if you were a fresh Claude instance. Does the mode router fire? Is the common contract clear?
2. **Walk [`tests/test-prompts.md`](./tests/test-prompts.md) mentally**. Would a fresh Claude produce the expected behavior for each mode? Check the "red flags" lists.
3. **Run the automated suite** when you have a `claude` binary available (see [`tests/claude-code/README.md`](./tests/claude-code/README.md)). The runner takes `--integration` for integration tests and `-v` for verbose output.

**TDD-for-skills principle**: prefer adding guidance *in response to an observed failure*, not by anticipation. If your change doesn't map to a failing test prompt, question whether it's needed. When a test fails, fix the skill; don't soften the test.

When you add a rule to `SKILL.md` or a `mode-*.md`, also:
- Reflect it in `review-checklist.md` if it's something a reviewer should check
- Add (or sharpen) a matching assertion in `tests/claude-code/test-c4-model.sh`
- Note the change in `CHANGELOG.md` under `## [Unreleased]`
