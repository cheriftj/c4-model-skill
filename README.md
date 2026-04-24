# c4-model

A [Claude Code](https://claude.com/claude-code) skill for producing [C4 architecture diagrams](https://c4model.com) (Simon Brown's model), interactively.

[![CI](https://github.com/cheriftj/c4-model-skill/actions/workflows/ci.yml/badge.svg)](https://github.com/cheriftj/c4-model-skill/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

## How it works

When you ask for an architecture diagram, the skill first figures out what you're actually doing. Designing a new system from a vague idea is a different job from retro-documenting an existing codebase, which is different again from reviewing someone else's diagram or updating one you already have.

Once the mode is clear, it runs the matching workflow: a structured dialogue, batches of no more than five questions at a time, with an explicit validation checkpoint at every level. Nothing gets written to disk until you say it's final.

By default the output is one Markdown document per C4 level (Context, Container, optionally Component) with the diagram embedded as Mermaid. Format and destination are negotiated at the start: Structurizr DSL, PlantUML, or an MCP destination (Notion, Linear, Google Drive) are all on the table.

See [`skills/c4-model/examples/`](./skills/c4-model/examples/) for a filled-out Context + Container pair built from Simon Brown's canonical Internet Banking System.

## Installation

### Claude Code plugin marketplace

```bash
/plugin marketplace add cheriftj/c4-model-skill
/plugin install c4-model@c4-model-skill
```

### Copy into a single project

```bash
cp -r path/to/this-repo/skills/c4-model /your/project/.claude/skills/
```

Claude Code auto-discovers skills under `.claude/skills/` in the current project.

### Install for all your projects

```bash
cp -r path/to/this-repo/skills/c4-model ~/.claude/skills/
```

## The 5 modes

Mode detection is automatic based on the signal in your message.

| Signal | Mode | What it does |
|---|---|---|
| Vague idea, no code | **Design** | Framing → Context → Container → optional Component → finalization |
| You point at a repo | **Document-code** | Quick framing → scan (delegates to an Explore sub-agent on large repos) → review → dialogue → deliver |
| You paste a README / ADR / spec | **Document-prose** | Extraction → gap-filling dialogue → deliver |
| You paste a diagram + *"is this good?"* | **Review** | Checklist critique (grouped by severity) or structured narration |
| You have a C4 + *"add / remove / change X"* | **Update** | Read, clarify the diff, update every affected level |

Supporting diagrams (System Landscape, C4Deployment, C4Dynamic) are offered on explicit request.

## Example conversation (Design mode)

```text
You:   I'm building an event-sourced order management system. Can you help me design the architecture?

Claude: Before we draft anything, a few quick questions (max 5):
        1. System name + one-line business intent?
        2. Audience (tech team, stakeholder, onboarding)?
        3. Which levels: Context only, Context + Container, deeper?
        4. Output format? Default is Mermaid + Markdown; alternatives: Structurizr DSL, PlantUML.
        5. Destination? Default docs/architecture/, or a Notion/Linear/Drive MCP if available.

You:   Orders MS, greenfield. Tech team audience. Context + Container. Defaults.

Claude: Got it. For Context first: who interacts with this system, and what external systems does it depend on?

[... dialogue continues, diagram emerges, user validates each level ...]

You:   Finalized, looks good.

Claude: Writing docs/architecture/01-context.md and docs/architecture/02-container.md now.
```

## What makes it honest

- **Mode detection first.** Don't generate if we don't know what you want.
- **Simon Brown's golden rule.** Context + Container are enough for most teams; Component only on explicit request.
- **One Markdown document per level.** Never a bare Mermaid block.
- **Relation labels state intent.** *"Uses"*, *"Calls"*, *"Reads"* are banned on their own.
- **Technology is mandatory** on every Container and Component.
- **Assumptions stay explicit.** Inferences never slip silently into the diagram.
- **Grounded in authority.** The Mermaid syntax reference is rebuilt from [mermaid.js.org](https://mermaid.js.org/syntax/c4.html); the review checklist from [c4model.com](https://c4model.com/diagrams/checklist). Editorial additions are separated from sourced content.

## Contributing

Bug fixes, wording improvements, and new modes are all welcome. For anything larger than a typo, open an issue first so we can agree on scope before code is written. See [`CONTRIBUTING.md`](./CONTRIBUTING.md) for the editorial invariants, the PR checklist, and the release process. This project follows the [Contributor Covenant Code of Conduct](./CODE_OF_CONDUCT.md).

## License

MIT. See [LICENSE](./LICENSE).

## Credits

The [C4 model](https://c4model.com) is by [Simon Brown](https://simonbrown.je/); the example deliverables in this repo use his canonical [Internet Banking System](https://c4model.com/diagrams). The Mermaid C4 syntax comes from the [Mermaid](https://mermaid.js.org/) project.
