#!/usr/bin/env bash
# Fast test — validates c4-model skill instructions via targeted Q&A.
# Does not execute a full workflow. Each prompt probes one behavioral
# aspect of the skill.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./test-helpers.sh
source "${SCRIPT_DIR}/test-helpers.sh"

check_claude_installed

# Set up an isolated test project with the skill copied into the place
# Claude Code auto-discovers (.claude/skills/). The skill's canonical
# home in this repo is ./skills/c4-model/.
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
TEST_DIR=$(create_test_project)
trap 'cleanup_test_project "$TEST_DIR"' EXIT

mkdir -p "${TEST_DIR}/.claude/skills"
cp -r "${PROJECT_ROOT}/skills/c4-model" "${TEST_DIR}/.claude/skills/"

cd "$TEST_DIR" || { echo "ERROR: cannot cd to $TEST_DIR" >&2; exit 1; }

echo "Test file:          test-c4-model.sh"
echo "Test project:       ${TEST_DIR}"
echo "Purpose:            validate c4-model skill instructions"

# ---------------------------------------------------------------------------
begin_test_section "Mode detection"
# ---------------------------------------------------------------------------
output=$(run_claude "Using the c4-model skill: if a user pastes an existing Mermaid diagram and asks 'is this good?', which mode does the skill route to? Answer with just the mode name." 45)
assert_contains "$output" "review" "Routes 'is this good?' to Review mode"

output=$(run_claude "Using the c4-model skill: a user says 'I want to design a brand-new event-sourced order system'. Which mode applies?" 45)
assert_contains "$output" "design" "Routes 'design new system' to Design mode"

output=$(run_claude "Using the c4-model skill: the user points at an existing repo and asks for architecture documentation. Which mode applies?" 45)
assert_contains "$output" "document.code" "Routes 'document a repo' to Document-code mode"

# ---------------------------------------------------------------------------
begin_test_section "Simon Brown's golden rule"
# ---------------------------------------------------------------------------
output=$(run_claude "According to the c4-model skill, does it generate a Component-level diagram by default? Briefly explain the rule." 45)
assert_contains "$output" "(context.*container|container.*context)" "Mentions Context + Container as the default pair"
assert_contains "$output" "(only|explicit|demand|when.{1,30}requested|genuine value)" "Mentions the 'only on demand' rule for Component"

# ---------------------------------------------------------------------------
begin_test_section "Interactive contract"
# ---------------------------------------------------------------------------
output=$(run_claude "Using the c4-model skill: does the skill deliver a finalized C4 to the filesystem on the very first user message, without any dialogue?" 45)
assert_contains "$output" "(no|never|not without)" "Does not deliver without dialogue"
assert_contains "$output" "(validation|dialogue|finalization|explicit)" "Explains the validation requirement"

# ---------------------------------------------------------------------------
begin_test_section "Notation rules"
# ---------------------------------------------------------------------------
output=$(run_claude "In the c4-model skill: can a C4 relationship be labeled just 'Uses'? Explain briefly." 45)
assert_contains "$output" "(ban|avoid|proscribe|not acceptable|too generic|reject)" "Rejects generic 'Uses' label"
assert_contains "$output" "intent" "Mentions intent-specific labels"

output=$(run_claude "In the c4-model skill: is the technology field optional or mandatory on a Container?" 45)
assert_contains "$output" "(mandatory|required|must|not optional)" "Technology is mandatory"

output=$(run_claude "In the c4-model skill: when a relationship crosses between two containers, what additional information is required beyond the label?" 45)
assert_contains "$output" "(protocol|HTTPS|gRPC|JDBC|SMTP|AMQP|technology)" "Inter-container relations need a protocol"

# ---------------------------------------------------------------------------
begin_test_section "Assumption handling"
# ---------------------------------------------------------------------------
output=$(run_claude "In the c4-model skill: if something is inferred from code without explicit user confirmation, where does it go — inside the diagram itself, or in a separate section of the Markdown document?" 45)
assert_contains "$output" "assumption" "Inferences go to an Assumptions section"
assert_not_contains "$output" "silently.{1,40}diagram" "Not silently into the diagram"

# ---------------------------------------------------------------------------
begin_test_section "Output format and destination"
# ---------------------------------------------------------------------------
output=$(run_claude "Does the c4-model skill always output Mermaid, or is the format negotiated? Briefly list the alternatives." 45)
assert_contains "$output" "(negotiated|alternatives|structurizr|plantuml|image)" "Format is negotiated"

output=$(run_claude "Where does the c4-model skill deliver outputs by default when no other destination is specified?" 45)
assert_contains "$output" "(docs/architecture|local filesystem|filesystem)" "Default is local filesystem"

# ---------------------------------------------------------------------------
begin_test_section "Review checklist"
# ---------------------------------------------------------------------------
output=$(run_claude "Before final delivery, does the c4-model skill use a checklist? If so, what is its source?" 45)
assert_contains "$output" "checklist" "Mentions the checklist"
assert_contains "$output" "(simon brown|c4model\.com)" "Sourced from Simon Brown / c4model.com"

report_and_exit "test-c4-model.sh"
