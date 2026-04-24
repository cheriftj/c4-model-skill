# Contributing

Thanks for your interest in improving this skill. Small, focused PRs are easier to review than big refactors.

## Before you start

1. Read [`CLAUDE.md`](./CLAUDE.md). It captures the editorial invariants that keep the skill's output quality consistent.
2. Skim [`skills/c4-model/SKILL.md`](./skills/c4-model/SKILL.md) so you understand the router and common-contract pattern.
3. Open [`tests/test-prompts.md`](./tests/test-prompts.md) to see the prompts that validate the skill.

## What kinds of changes are welcome

**Welcome**:

- Tightening existing guidance with a clearer example.
- Fixing an inconsistency between files (e.g. a rule in `SKILL.md` not mirrored in `review-checklist.md`).
- Re-grounding a normative claim with a source URL.
- Adding a genuinely new mode that covers a use case not addressed by the existing five.
- Translating the skill to another language (keep the English version as the authoritative source).
- Improving example deliverables in `skills/c4-model/examples/`.

**Be careful with**:

- Adding new prose to `SKILL.md` or a `mode-*.md` without a specific failure it addresses. Prefer *"I watched Claude do X without this skill, the new sentence prevents it"* over *"this feels like it should be said."*

**Not accepted**:

- Sections without a clear trigger. Skills that drift into general advice lose signal.
- Removing editorial invariants from `CLAUDE.md` without a discussed replacement.
- Making a specific MCP server a hard dependency of a flow. MCP destinations are optional.

## Proposing a change

1. Fork the repo.
2. Create a focused branch (`fix/<short-slug>`, `feat/<short-slug>`, or `docs/<short-slug>`).
3. Make your change.
4. **Validate manually**: walk through `tests/test-prompts.md` with a fresh Claude Code session. Every prompt should still route and flow as documented. If your change breaks a prompt, update the test first or reconsider the change.
5. Update [`CHANGELOG.md`](./CHANGELOG.md) under `## [Unreleased]`, describing what changed.
6. Open a PR with:
   - A one-line summary.
   - *Before / after* for the user-visible behavior.
   - Which test prompt(s) you re-validated against.

## Adding a new mode

New modes are significant additions. Before writing code:

1. Open an issue describing the use case and why the existing five modes don't cover it.
2. Agree on the mode name and file path (`mode-<name>.md`).
3. Add the mode to the router table in `SKILL.md` **and** to the "Bundled references" section.
4. Write the mode file following the structure of the existing ones: *When to use*, *Steps*, *Tools to use*, *Links*.
5. Add a test prompt for it in `tests/test-prompts.md`.
6. Update `CLAUDE.md`'s tree.

## Updating a sourced reference

`mermaid-c4-syntax.md` and `review-checklist.md` are grounded in external authoritative sources ([mermaid.js.org](https://mermaid.js.org/syntax/c4.html), [c4model.com](https://c4model.com)). When you update them:

1. Re-fetch the source to see what changed upstream.
2. Keep the URL pointer at the top of the file.
3. Keep our editorial additions clearly labeled (*"Editorial advice"*, *"Additions specific to this skill"*) and separate from the sourced content.
4. Do not paraphrase sourced content in a way that could change its meaning.

## Releasing

Releases are cut manually and published automatically by [`.github/workflows/release.yml`](./.github/workflows/release.yml). The workflow fires on any tag matching `v*`, extracts the matching section from `CHANGELOG.md`, and creates a GitHub Release with those notes as the body.

### Versioning (SemVer)

This project follows [Semantic Versioning](https://semver.org):

- **MAJOR**: incompatible changes to the skill's contract (a mode is removed, an editorial invariant is dropped, the required output structure changes).
- **MINOR**: a new mode, a new reference file, a new feature that doesn't break existing usage.
- **PATCH**: bug fixes, wording improvements, link fixes, clarifications that don't change behavior.

Pre-release suffixes are supported: `v1.1.0-rc.1`, `v1.1.0-beta.1`, `v1.1.0-alpha.1`. The release workflow marks any tag containing `-` as a pre-release on GitHub.

### Release checklist

1. **Update `CHANGELOG.md`**: move entries from `## [Unreleased]` into a new dated section `## [X.Y.Z] - YYYY-MM-DD`. Add a fresh empty `## [Unreleased]` section at the top.
2. **Commit** on `main` with a message like `chore: prepare vX.Y.Z release`. Push to origin.
3. **Tag**: `git tag -a vX.Y.Z -m "vX.Y.Z"`. Annotated tags are required; lightweight tags won't trigger the workflow reliably.
4. **Push the tag**: `git push origin vX.Y.Z`.
5. **Watch the workflow**. It should appear under the *Actions* tab within a few seconds. On success, a Release is created under the *Releases* tab with the extracted notes as the body.

If the workflow fails because the CHANGELOG section is missing, delete the tag (`git tag -d vX.Y.Z && git push --delete origin vX.Y.Z`), fix the CHANGELOG, and redo steps 3 and 4.

## Code of conduct

This project follows the [Contributor Covenant Code of Conduct](./CODE_OF_CONDUCT.md). Be respectful, assume good faith, and prefer concrete proposals over hot takes.

## Questions

Open an issue and tag it `question`.
