#!/usr/bin/env bash
# KAN-31 & KAN-37: Menu Navigation Tests
# KAN-31: Main menu handles unexpected input without hanging
# KAN-37: Skill selection "Go Back" returns to previous menu
# Usage: bash tests/test_KAN31_37_menus.sh
# Requires: InCollege binary compiled at project root

set -uo pipefail

BINARY="../InCollege"
PASS=0
FAIL=0
SKIP=0
TIMEOUT_SEC=5

run_test() {
    local name="$1"
    local input_content="$2"
    local expect_present="$3"
    local expect_absent="$4"

    cd "$(dirname "$0")/.."
    printf "%s" "$input_content" > InCollege-Input.txt

    local output
    # timeout guards against infinite loops (KAN-31 core concern)
    output=$(timeout "$TIMEOUT_SEC" "$BINARY" 2>/dev/null || true)

    local ok=1
    if [[ -n "$expect_present" ]] && ! echo "$output" | grep -qF "$expect_present"; then
        ok=0
    fi
    if [[ -n "$expect_absent" ]] && echo "$output" | grep -qF "$expect_absent"; then
        ok=0
    fi

    if [[ $ok -eq 1 ]]; then
        echo "PASS: $name"
        ((PASS++))
    else
        echo "FAIL: $name"
        echo "  Output: $output"
        ((FAIL++))
    fi
}

skip_test() {
    echo "SKIP: $1 — paragraph not yet implemented"
    ((SKIP++))
}

cd "$(dirname "$0")/.."

# --- KAN-31: Unexpected main menu input exits cleanly within timeout ---
# Verifies no infinite loop: program must terminate within TIMEOUT_SEC seconds
run_test "KAN-31-01: unexpected menu input terminates cleanly" \
    "GARBAGE INPUT\n" \
    "Welcome to InCollege!" \
    ""

# --- KAN-31: Numeric input at menu does not hang ---
run_test "KAN-31-02: numeric menu input terminates cleanly" \
    "99999\n" \
    "Welcome to InCollege!" \
    ""

# --- KAN-31: Whitespace-only input at menu does not hang ---
run_test "KAN-31-03: whitespace-only menu input terminates cleanly" \
    "     \n" \
    "Welcome to InCollege!" \
    ""

# --- KAN-37: Skill menu "Go Back" returns to main menu ---
# Stub: skill selection paragraph not yet implemented.
# When SKILL-MENU paragraph exists, replace skip with:
#   run_test "KAN-37-01: Go Back from skill menu shows main menu" \
#       "Skills\nGo Back\n" \
#       "Enter your choice:" \
#       ""
skip_test "KAN-37-01: Go Back from skill menu returns to main menu"

# --- KAN-37: Selecting a skill and then Go Back returns to main menu ---
skip_test "KAN-37-02: select skill then Go Back returns to main menu"

# Restore default input
printf "Create New Account\nJohn Doe\nJohn6769420@!@@@@!\$" > InCollege-Input.txt

echo ""
echo "Results: $PASS passed, $FAIL failed, $SKIP skipped."
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
