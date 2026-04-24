# Changelog

All notable changes to the `c4-model` skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

*No changes yet.*

## [1.0.1] - 2026-04-24

### Fixed

- Removed `.claude-plugin/plugin.json` to resolve a conflict detected by `/doctor`: both `plugin.json` and `marketplace.json` were specifying plugin components, which Claude Code refuses to merge. Following the pattern used by [`anthropics/skills`](https://github.com/anthropics/skills), `marketplace.json` is now the single source of truth for plugin metadata and skill paths. CI's manifest validation job updated accordingly.

## [1.0.0] - 2026-04-24

First public release.

### Added

- **Mode router** in `SKILL.md` that detects the usage mode from signals in the user's message and routes to one of five workflows: design (greenfield), document-code (retro-doc from a codebase, delegates to an Explore sub-agent on large repos), document-prose (README / ADR / spec), review (critique or explanation), and update (evolve an existing C4).
- **Supporting diagrams** reference (`supporting-diagrams.md`) for System Landscape, C4Deployment, and C4Dynamic.
- **Common contract** applied to every mode: format negotiation (Mermaid C4 + Markdown by default; Structurizr DSL, PlantUML, and images as alternatives), destination negotiation (local filesystem or connected MCP: Notion, Linear, Google Drive), notation rules, deliverable structure, and dialogue rules.
- **Sourced references** grounded in external authority: `mermaid-c4-syntax.md` rebuilt from [`mermaid.js.org/syntax/c4.html`](https://mermaid.js.org/syntax/c4.html); `review-checklist.md` sourced from [`c4model.com/diagrams/checklist`](https://c4model.com/diagrams/checklist). Editorial additions are clearly separated from sourced content.
- **Level template** (`level-template.md`) and **example deliverables** (`examples/`) filled out for Simon Brown's Internet Banking System.
- **Bilingual discoverability**: English-authored body with French trigger phrases (*"modèle C4"*, *"diagramme d'architecture"*) preserved in the frontmatter.
- **Plugin marketplace config** (`.claude-plugin/marketplace.json`, `.claude-plugin/plugin.json`) and **release automation** (`.github/workflows/release.yml`): a `v*` tag push triggers extraction of the matching CHANGELOG section and publishes a GitHub Release.
- **Test suite**: an automated bash suite (`tests/claude-code/`) that invokes `claude -p` with assertion helpers (`assert_contains`, `assert_order`, `assert_file_exists`) and a manual test matrix (`tests/test-prompts.md`) with expected routing, flows, and red flags per mode.
- **Governance**: `README.md`, `LICENSE` (MIT), `CLAUDE.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `.github/PULL_REQUEST_TEMPLATE.md`.

### Editorial invariants

Load-bearing rules encoded in `SKILL.md` and mirrored in `review-checklist.md`:

- Simon Brown's golden rule: Context + Container are the default; Component and Code only on explicit request.
- One Markdown document per level, never a bare diagram.
- Relation labels must state intent. Bare *"Uses"*, *"Calls"*, and *"Reads"* are banned.
- Inter-container relationships must state the protocol.
- Technology is mandatory on every Container and Component.
- Assumptions stay explicit. Inferences never slip silently into the diagram.
- Interactive by default. No finalized delivery without explicit user validation.

[Unreleased]: https://github.com/toujenicherif/c4-model-skill/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/toujenicherif/c4-model-skill/releases/tag/v1.0.0
