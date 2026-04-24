#!/usr/bin/env bash
# Integration test — exercises the c4-model skill through a complete
# Design-mode workflow and validates the files produced.
#
# This test takes several minutes and consumes API credits. Run via:
#   ./run-skill-tests.sh --integration

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./test-helpers.sh
source "${SCRIPT_DIR}/test-helpers.sh"

check_claude_installed

# Isolated test project
TEST_DIR=$(create_test_project)
trap 'cleanup_test_project "$TEST_DIR"' EXIT

# Copy the skill into the test project so Claude Code auto-discovers it
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
mkdir -p "${TEST_DIR}/.claude/skills"
cp -r "${PROJECT_ROOT}/skills/c4-model" "${TEST_DIR}/.claude/skills/"

cd "$TEST_DIR" || { echo "ERROR: cannot cd to $TEST_DIR" >&2; exit 1; }

echo "Test file:     test-c4-model-integration.sh"
echo "Test project:  ${TEST_DIR}"
echo "Purpose:       run a full Design-mode workflow end-to-end"

# ---------------------------------------------------------------------------
begin_test_section "Run Design-mode workflow"
# ---------------------------------------------------------------------------
# The prompt provides all Phase-0 framing info upfront so the skill can
# produce deliverables in one pass (claude -p headless mode does not
# natively support multi-turn dialogue). Prompt body is stored as a fixture
# so it can be edited and version-diffed without touching test logic.
PROMPT_FIXTURE="${SCRIPT_DIR}/fixtures/taskflow-prompt.md"
if [[ ! -f "$PROMPT_FIXTURE" ]]; then
  echo "ERROR: missing prompt fixture: $PROMPT_FIXTURE" >&2
  exit 1
fi
PROMPT=$(cat "$PROMPT_FIXTURE")

output=$(run_claude "$PROMPT" 600)
echo "$output" | tail -20

# ---------------------------------------------------------------------------
begin_test_section "Deliverable files produced"
# ---------------------------------------------------------------------------
assert_file_exists "docs/architecture/01-context.md" "Context document written"
assert_file_exists "docs/architecture/02-container.md" "Container document written"

context_content=""
container_content=""
[[ -f "docs/architecture/01-context.md" ]]   && context_content=$(cat docs/architecture/01-context.md)
[[ -f "docs/architecture/02-container.md" ]] && container_content=$(cat docs/architecture/02-container.md)

# ---------------------------------------------------------------------------
begin_test_section "Context document structure"
# ---------------------------------------------------------------------------
assert_contains "$context_content" "^#"                    "Has a top-level heading"
assert_contains "$context_content" "C4Context"             "Contains a C4Context Mermaid block"
assert_contains "$context_content" "TaskFlow"              "Mentions the system name"
assert_contains "$context_content" "(Stripe|Auth0|SendGrid|Datadog)" "Mentions external systems"
assert_contains "$context_content" "(elements|éléments)"   "Has an Elements section"
assert_contains "$context_content" "(relationships|relations)" "Has a Relationships section"
assert_contains "$context_content" "assumption"            "Has an Assumptions section"
assert_contains "$context_content" "(overview|vue)"        "Has an Overview section"

# ---------------------------------------------------------------------------
begin_test_section "Container document structure"
# ---------------------------------------------------------------------------
assert_contains "$container_content" "C4Container"         "Contains a C4Container Mermaid block"
assert_contains "$container_content" "(Node\.?js|Fastify)" "Technology specified on API"
assert_contains "$container_content" "(React|TypeScript)"  "Technology specified on SPA"
assert_contains "$container_content" "(Postgres|postgresql)" "Postgres container present"
assert_contains "$container_content" "Redis"               "Redis container present"
assert_contains "$container_content" "assumption"          "Has an Assumptions section"

# ---------------------------------------------------------------------------
begin_test_section "Protocols on inter-container relationships"
# ---------------------------------------------------------------------------
assert_contains "$container_content" "(JSON/HTTPS|JSON.*HTTPS)" "JSON/HTTPS protocol appears"
assert_contains "$container_content" "(SQL|TCP|JDBC)"           "SQL / TCP / JDBC protocol appears"
assert_contains "$container_content" "(RESP|redis protocol)"    "RESP protocol appears (for Redis)"
assert_contains "$container_content" "(OIDC|HTTPS)"             "HTTPS / OIDC protocol appears (for Auth0)"

# ---------------------------------------------------------------------------
begin_test_section "Label quality (no generic verbs)"
# ---------------------------------------------------------------------------
uses_count=0
if [[ -f "docs/architecture/02-container.md" ]]; then
  # Count bare "Uses" labels inside Rel(...) calls in the Mermaid block
  uses_count=$(grep -Ec 'Rel[^(]*\([^,]+,[^,]+,[[:space:]]*"Uses"' docs/architecture/02-container.md 2>/dev/null || echo 0)
fi

if [[ "$uses_count" -eq 0 ]]; then
  echo -e "  ${GREEN}PASS${NC} No bare 'Uses' labels on relations"
  PASS_COUNT=$((PASS_COUNT + 1))
else
  echo -e "  ${RED}FAIL${NC} Found ${uses_count} bare 'Uses' labels (expected 0)"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

report_and_exit "test-c4-model-integration.sh"
