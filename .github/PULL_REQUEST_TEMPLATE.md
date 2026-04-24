<!-- markdownlint-disable-file MD041 -->
## Summary

<!-- One sentence: what changes and why. -->

## Type of change

- [ ] Fix — corrects an issue or inconsistency
- [ ] Enhancement — improves existing guidance without breaking invariants
- [ ] New mode — adds a new usage mode (requires prior discussion in an issue)
- [ ] Sourced reference update — re-syncs with an authoritative external source
- [ ] Example deliverable — adds or improves `examples/`
- [ ] Governance — `README.md`, `CONTRIBUTING.md`, `CHANGELOG.md`, CI, etc.
- [ ] Other: <!-- describe -->

## Which invariant or test does this change map to?

<!-- Per the TDD-for-skills principle: new guidance should map to an observed
     failure or a covered test. If you're adding text to SKILL.md or a mode file,
     link to the test prompt (tests/test-prompts.md or tests/claude-code/) it
     addresses. If you're adding a test, describe the failure mode it catches. -->

## Validation

- [ ] Read the affected file(s) end-to-end
- [ ] Walked the relevant prompt(s) in [`tests/test-prompts.md`](../tests/test-prompts.md)
- [ ] Ran `./tests/claude-code/run-skill-tests.sh` locally (if `claude` CLI available)
- [ ] Updated [`CHANGELOG.md`](../CHANGELOG.md) under `## [Unreleased]`
- [ ] Cross-references updated (mentions in `SKILL.md`, `CLAUDE.md`, `README.md` file trees)

## Editorial invariants preserved

- [ ] Mode detection still happens first
- [ ] Simon Brown's golden rule (Context + Container default)
- [ ] One Markdown document per level
- [ ] Intent-specific relation labels (no bare `Uses` / `Calls` / `Reads`)
- [ ] Technology mandatory on every Container and Component
- [ ] Assumptions stay explicit
- [ ] No unnegotiated format or destination decisions

## Notes for reviewers

<!-- Anything non-obvious: breaking changes, style decisions, open questions. -->
