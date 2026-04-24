#!/usr/bin/env bash
# Runner for the c4-model Claude Code skill test suite.
# Discovers test-*.sh in this directory, runs each with a timeout,
# and reports an aggregate summary.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || { echo "ERROR: cannot cd to $SCRIPT_DIR" >&2; exit 1; }

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
# Flags
# ---------------------------------------------------------------------------
VERBOSE=0
INTEGRATION=0
TIMEOUT=300
SPECIFIC_TEST=""

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Run the c4-model skill test suite.

Options:
  -v, --verbose              Show full output of each test
  -i, --integration          Include slow integration tests (~3-5 minutes)
  -t, --test NAME            Run only one test (filename without path)
      --timeout SECONDS      Per-test timeout (default: 300)
  -h, --help                 Show this help

Default behavior runs only fast tests (*-integration.sh excluded).

Examples:
  $(basename "$0")                              # fast tests only
  $(basename "$0") --integration                # fast + integration
  $(basename "$0") -t test-c4-model.sh -v       # one test, verbose
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--verbose)     VERBOSE=1; shift ;;
    -i|--integration) INTEGRATION=1; shift ;;
    -t|--test)        SPECIFIC_TEST="$2"; shift 2 ;;
    --timeout)        TIMEOUT="$2"; shift 2 ;;
    -h|--help)        usage; exit 0 ;;
    *)                echo "Unknown flag: $1" >&2; usage >&2; exit 2 ;;
  esac
done

# ---------------------------------------------------------------------------
# Prerequisites
# ---------------------------------------------------------------------------
if ! command -v claude >/dev/null 2>&1; then
  echo -e "${RED}Error${NC}: 'claude' CLI not found in PATH." >&2
  echo "Install Claude Code first: https://claude.com/claude-code" >&2
  exit 2
fi

if ! command -v timeout >/dev/null 2>&1; then
  echo -e "${RED}Error${NC}: 'timeout' command not found." >&2
  echo "On macOS: brew install coreutils (then ensure 'timeout' resolves, or symlink gtimeout → timeout)" >&2
  exit 2
fi

# ---------------------------------------------------------------------------
# Discover tests
# ---------------------------------------------------------------------------
if [[ -n "$SPECIFIC_TEST" ]]; then
  if [[ ! -f "$SPECIFIC_TEST" ]]; then
    echo -e "${RED}Error${NC}: test file not found: ${SPECIFIC_TEST}" >&2
    exit 2
  fi
  TESTS=("./${SPECIFIC_TEST}")
else
  # Gather test-*.sh; exclude integration tests unless --integration
  TESTS=()
  for f in ./test-*.sh; do
    [[ -f "$f" ]] || continue
    if [[ $INTEGRATION -eq 0 && "$f" == *"-integration.sh" ]]; then
      continue
    fi
    TESTS+=("$f")
  done
fi

if [[ ${#TESTS[@]} -eq 0 ]]; then
  echo -e "${YELLOW}No tests discovered in ${SCRIPT_DIR}.${NC}"
  exit 0
fi

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------
echo -e "${BLUE}Running ${#TESTS[@]} test file(s) (timeout ${TIMEOUT}s each)${NC}"
echo ""

PASSED=0
FAILED=0
FAILED_TESTS=()
START_TIME=$(date +%s)

for test in "${TESTS[@]}"; do
  test_name=$(basename "$test")

  if [[ ! -x "$test" ]]; then
    echo -e "${YELLOW}Skipping ${test_name} (not executable — run: chmod +x ${test_name})${NC}"
    continue
  fi

  echo -e "${BLUE}==> ${test_name}${NC}"
  start=$(date +%s)
  result=0

  if [[ $VERBOSE -eq 1 ]]; then
    timeout "${TIMEOUT}s" "$test" || result=$?
  else
    output=$(timeout "${TIMEOUT}s" "$test" 2>&1) || result=$?
    if [[ $result -ne 0 ]]; then
      echo "$output"
    fi
  fi

  elapsed=$(( $(date +%s) - start ))

  if [[ $result -eq 0 ]]; then
    echo -e "    ${GREEN}PASSED${NC} in ${elapsed}s"
    PASSED=$((PASSED + 1))
  elif [[ $result -eq 124 ]]; then
    echo -e "    ${RED}TIMEOUT${NC} after ${TIMEOUT}s"
    FAILED=$((FAILED + 1))
    FAILED_TESTS+=("$test_name (timeout)")
  else
    echo -e "    ${RED}FAILED${NC} (exit ${result}) in ${elapsed}s"
    FAILED=$((FAILED + 1))
    FAILED_TESTS+=("$test_name (exit ${result})")
  fi
  echo ""
done

total_elapsed=$(( $(date +%s) - START_TIME ))

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo "========================================"
echo -e "Total: ${PASSED} passed, ${FAILED} failed (in ${total_elapsed}s)"
if [[ $FAILED -eq 0 ]]; then
  echo -e "${GREEN}All tests passed${NC}"
  exit 0
else
  echo -e "${RED}Failures:${NC}"
  for t in "${FAILED_TESTS[@]}"; do
    echo -e "  ${RED}- ${t}${NC}"
  done
  exit 1
fi
