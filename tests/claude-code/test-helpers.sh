#!/usr/bin/env bash
# Shared helpers for Claude Code skill tests.
# Source this from each test-*.sh script.

set -uo pipefail

# ---------------------------------------------------------------------------
# Colors (disabled when stdout is not a TTY)
# ---------------------------------------------------------------------------
if [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''
fi

# ---------------------------------------------------------------------------
# Per-test counters
# ---------------------------------------------------------------------------
PASS_COUNT=0
FAIL_COUNT=0

# ---------------------------------------------------------------------------
# Dependency check
# ---------------------------------------------------------------------------
check_claude_installed() {
  if ! command -v claude >/dev/null 2>&1; then
    echo -e "${RED}Error${NC}: 'claude' CLI not found in PATH." >&2
    echo "Install Claude Code first: https://claude.com/claude-code" >&2
    exit 2
  fi
}

# ---------------------------------------------------------------------------
# run_claude — invoke Claude Code in headless mode
#
# Usage:
#   output=$(run_claude "your prompt" [timeout_seconds])
#
# Default timeout: 60s. Captures both stdout and stderr. Returns the output
# (echo) regardless of exit code, so callers can assert on the text even when
# Claude errored or timed out.
# ---------------------------------------------------------------------------
run_claude() {
  local prompt="$1"
  local timeout_s="${2:-60}"
  local output=""
  local exit_code=0

  output=$(timeout "${timeout_s}s" claude -p "$prompt" 2>&1) || exit_code=$?

  if [[ $exit_code -eq 124 ]]; then
    output="${output}\n[TIMEOUT after ${timeout_s}s]"
  fi

  printf '%s' "$output"
}

# ---------------------------------------------------------------------------
# Assertions
# Each prints a pass/fail line and updates PASS_COUNT / FAIL_COUNT.
# ---------------------------------------------------------------------------

# assert_contains <output> <pattern> <test_name>
# Pattern is passed to grep -E -i (case-insensitive ERE).
assert_contains() {
  local output="$1"
  local pattern="$2"
  local name="$3"

  if echo "$output" | grep -Eqi "$pattern"; then
    echo -e "  ${GREEN}PASS${NC} ${name}"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo -e "  ${RED}FAIL${NC} ${name}"
    echo -e "    ${YELLOW}expected pattern:${NC} ${pattern}"
    echo -e "    ${YELLOW}first 5 lines:${NC}"
    echo "$output" | head -5 | sed 's/^/      /'
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

assert_not_contains() {
  local output="$1"
  local pattern="$2"
  local name="$3"

  if echo "$output" | grep -Eqi "$pattern"; then
    echo -e "  ${RED}FAIL${NC} ${name}"
    echo -e "    ${YELLOW}pattern should be absent:${NC} ${pattern}"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  else
    echo -e "  ${GREEN}PASS${NC} ${name}"
    PASS_COUNT=$((PASS_COUNT + 1))
  fi
}

# assert_count <output> <pattern> <expected_count> <test_name>
assert_count() {
  local output="$1"
  local pattern="$2"
  local expected="$3"
  local name="$4"
  local actual
  actual=$(echo "$output" | grep -Eic "$pattern" || true)

  if [[ "$actual" -eq "$expected" ]]; then
    echo -e "  ${GREEN}PASS${NC} ${name}"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo -e "  ${RED}FAIL${NC} ${name} (expected ${expected}, got ${actual})"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

# assert_order <output> <pattern_first> <pattern_second> <test_name>
assert_order() {
  local output="$1"
  local first="$2"
  local second="$3"
  local name="$4"
  local first_line second_line

  first_line=$(echo "$output" | grep -Eni "$first" | head -1 | cut -d: -f1)
  second_line=$(echo "$output" | grep -Eni "$second" | head -1 | cut -d: -f1)

  if [[ -n "$first_line" && -n "$second_line" && "$first_line" -lt "$second_line" ]]; then
    echo -e "  ${GREEN}PASS${NC} ${name}"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo -e "  ${RED}FAIL${NC} ${name} (expected '${first}' before '${second}')"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

# assert_file_exists <path> <test_name>
assert_file_exists() {
  local path="$1"
  local name="$2"

  if [[ -f "$path" ]]; then
    echo -e "  ${GREEN}PASS${NC} ${name}"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo -e "  ${RED}FAIL${NC} ${name} (file not found: ${path})"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

# ---------------------------------------------------------------------------
# Test scaffolding for integration tests
# ---------------------------------------------------------------------------
create_test_project() {
  mktemp -d -t c4-model-test-XXXXXX
}

cleanup_test_project() {
  local dir="$1"
  if [[ -n "${dir:-}" && -d "$dir" ]]; then
    rm -rf "$dir"
  fi
}

# ---------------------------------------------------------------------------
# Section header for readability
# ---------------------------------------------------------------------------
begin_test_section() {
  local name="$1"
  echo ""
  echo -e "${BLUE}--- ${name} ---${NC}"
}

# ---------------------------------------------------------------------------
# Summary / exit
# ---------------------------------------------------------------------------
report_and_exit() {
  local test_file="$1"
  local total=$((PASS_COUNT + FAIL_COUNT))
  echo ""
  if [[ $FAIL_COUNT -eq 0 ]]; then
    echo -e "${GREEN}${test_file}: ${PASS_COUNT}/${total} passed${NC}"
    exit 0
  else
    echo -e "${RED}${test_file}: ${FAIL_COUNT} failed, ${PASS_COUNT} passed (${total} total)${NC}"
    exit 1
  fi
}
