#!/usr/bin/env bash
# KAN-28: Login Validation Tests
# Tests: successful login flow, invalid menu choice, empty credentials
# Usage: bash tests/test_KAN28_login.sh
# Requires: InCollege binary compiled at project root

set -uo pipefail

BINARY="../InCollege"
PASS=0
FAIL=0

run_test() {
    local name="$1"
    local input_content="$2"
    local expect_present="$3"
    local expect_absent="$4"

    cd "$(dirname "$0")/.."
    printf "%s" "$input_content" > InCollege-Input.txt

    local output
    output=$("$BINARY" 2>/dev/null || true)

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

cd "$(dirname "$0")/.."

# --- Positive: correct login flow reaches success message ---
run_test "KAN-28-01: successful login" \
    "Log In\nJohnDoe\nSecure@123!" \
    "Logged in Successfully!" \
    ""

# --- Negative: invalid menu choice (neither Log In nor Create New Account) ---
run_test "KAN-28-02: invalid menu choice does not reach login or create" \
    "Invalid Choice\n" \
    "" \
    "Logged in Successfully!"

# --- Negative: invalid menu choice does not reach create account ---
run_test "KAN-28-03: invalid menu choice does not reach account creation" \
    "Invalid Choice\n" \
    "" \
    "Account Created!"

# --- Edge case: empty username on login ---
run_test "KAN-28-04: empty username on login" \
    "Log In\n          \nSecure@123!" \
    "Please enter your username:" \
    ""

# --- Edge case: empty password on login ---
run_test "KAN-28-05: empty password on login" \
    "Log In\nJohnDoe\n          " \
    "Please enter your password:" \
    ""

# Restore default input
printf "Create New Account\nJohn Doe\nJohn6769420@!@@@@!\$" > InCollege-Input.txt

echo ""
echo "Results: $PASS passed, $FAIL failed."
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
