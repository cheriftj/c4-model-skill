# Changelog

All notable changes to the `c4-model` skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- **README example conversation** updated to show the `/c4-design` slash command as the trigger (the previous version only showed a natural-language prompt) and a second example added for `/c4-review` demonstrating the critique output format.

## [1.0.3] - 2026-04-24

### Added

- **Mode-specific slash commands**: `/c4-design`, `/c4-document-code`, `/c4-document-prose`, `/c4-review`, `/c4-update`. Each skips the router in `SKILL.md` and goes straight to its mode's workflow (`skills/c4-model/mode-<name>.md`). The catch-all `/c4-model` from v1.0.2 is still available for users who want auto-detection. All six commands live under `commands/` and are registered via the `commands: ["./commands"]` entry in `marketplace.json`.
- **README**: *The 5 modes* table now includes a *Slash command* column; the *How it works* section points at the mode commands for users who already know the mode.

## [1.0.2] - 2026-04-24

### Added

- **Slash command `/c4-model`** via `commands/c4-model.md`. Lets users invoke the skill explicitly instead of relying only on description-triggered activation. The command routes to the right mode based on what follows the invocation (idea, repo path, pasted diagram, prose document), or asks the user to pick if nothing follows. Registered in `marketplace.json` via a new `commands: ["./commands"]` entry.

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

[Unreleased]: https://github.com/cheriftj/c4-model-skill/compare/v1.0.3...HEAD
[1.0.3]: https://github.com/cheriftj/c4-model-skill/releases/tag/v1.0.3
[1.0.2]: https://github.com/cheriftj/c4-model-skill/releases/tag/v1.0.2
[1.0.1]: https://github.com/cheriftj/c4-model-skill/releases/tag/v1.0.1
[1.0.0]: https://github.com/cheriftj/c4-model-skill/releases/tag/v1.0.0
