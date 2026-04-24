# `tests/claude-code/` — automated tests for the c4-model skill

Bash-based test suite that uses Claude Code in headless mode (`claude -p`) to validate that the skill's instructions are correctly interpreted and followed. Each test is a shell script that sources a shared helper library (`test-helpers.sh`) providing `run_claude`, `assert_contains`, `assert_not_contains`, `assert_count`, `assert_order`, and `assert_file_exists`. An orchestrator (`run-skill-tests.sh`) discovers and runs all `test-*.sh` files with per-test timeout and an aggregate summary.

## Prerequisites

- [Claude Code](https://claude.com/claude-code) installed and on `PATH` (`claude` command available)
- `bash` (tested with 3.2+)
- GNU `timeout` (shipped with coreutils — native on Linux; on macOS install via `brew install coreutils`, and either ensure `timeout` resolves or symlink `gtimeout` → `timeout`)

Run `claude --version` to confirm Claude Code is working before running the suite.

## Running the tests

From anywhere in the repo:

```bash
# Fast tests only (~2-3 minutes)
./tests/claude-code/run-skill-tests.sh

# Fast + integration tests (~5-10 minutes, consumes more API credits)
./tests/claude-code/run-skill-tests.sh --integration

# Run a specific test with full output
./tests/claude-code/run-skill-tests.sh -t test-c4-model.sh -v

# Longer per-test timeout
./tests/claude-code/run-skill-tests.sh --timeout 600
```

If a test isn't executable: `chmod +x tests/claude-code/test-*.sh tests/claude-code/run-skill-tests.sh`.

## Files

| File | Role |
|---|---|
| `run-skill-tests.sh` | Orchestrator — discovers `test-*.sh`, runs each with a timeout, reports summary |
| `test-helpers.sh` | Shared bash utilities — `run_claude`, `assert_contains`, `assert_not_contains`, `assert_count`, `assert_order`, color output, scaffolding |
| `test-c4-model.sh` | **Fast test** (~2 min) — targeted Q&A probing skill instructions (routing, golden rule, notation rules, checklist presence) |
| `test-c4-model-integration.sh` | **Integration test** (~3-5 min) — runs a full Design-mode workflow end-to-end and asserts on the files produced |
| `fixtures/taskflow-prompt.md` | Prompt body used by the integration test — kept external so it can be edited and diffed without touching test logic |

## What the tests verify

### Fast test (`test-c4-model.sh`)

Targeted prompts, each probing one behavioral aspect:

- **Mode detection** — Design / Document-code / Review signals route correctly
- **Simon Brown's golden rule** — Context + Container are the default; Component only on demand
- **Interactive contract** — no finalized delivery without explicit user validation
- **Notation rules** — `Uses` / `Calls` / `Reads` are banned as bare labels; technology is mandatory on every Container; inter-container relationships state the protocol
- **Assumption handling** — inferences go to the *Assumptions* section, never silently into the diagram
- **Format negotiation** — Mermaid is the default, alternatives (Structurizr, PlantUML, images) are available
- **Default destination** — local filesystem, MCP alternatives on negotiation
- **Checklist usage** — every delivery passes through `review-checklist.md`

### Integration test (`test-c4-model-integration.sh`)

Runs a full Design-mode workflow on a fully-specified system (TaskFlow, a fictional task-management SaaS). The prompt supplies all framing information upfront so the skill can produce deliverables without multi-turn conversation (which `claude -p` headless mode doesn't natively support).

Asserts on the produced files:

- Both `docs/architecture/01-context.md` and `docs/architecture/02-container.md` are written
- Mermaid blocks of the right diagram type (`C4Context`, `C4Container`)
- Every Container states its technology
- Every inter-container relationship states a protocol
- An *Assumptions* section is present in each document
- No generic `Uses` label on any relation

## Philosophy (TDD for skills)

Tests probe *observable failure modes* of the skill, not every internal detail. When a prompt doesn't match the expected behavior, fix the skill's guidance rather than adjusting the prompt to pass.

A change to `SKILL.md` or any `mode-*.md` file should keep every test green. If it doesn't, either:

1. The change breaks something — fix the change, or
2. The test was checking an outdated invariant — update the test and document *why* in the PR

Never silence a failing test without an explanation.

## Relationship to `tests/test-prompts.md`

`tests/test-prompts.md` is the **human-readable** test matrix — narrative prompts and expected flows that a reviewer can walk through mentally or with a live Claude session. The scripts in this directory are its **machine-checkable** counterpart.

Both should stay in sync: when you add a test prompt to `test-prompts.md`, consider whether it can be translated into a targeted assertion in `test-c4-model.sh`.

## Known limitations

- **Not CI-run by design**: these tests require a local `claude` binary, consume API credits per run, and LLM responses are non-deterministic enough to make CI noisy. They're meant for manual validation before opening a PR, not for gating every push.
- **Non-deterministic outputs**: LLM responses vary. Assertions use flexible regexes (`grep -Ei`) and target invariant keywords (e.g. *"assumption"*, *"technology"*) rather than exact phrasings. A test that fails intermittently should be tightened, not masked.
- **Integration test cost**: ~300s of Claude Code time per run, plus the underlying API usage. Run sparingly.
