#!/usr/bin/env bash
# KAN-9: Failed Login Notification Tests
# Verifies the program displays an error message on invalid credentials
# and handles the failed state gracefully.
# Usage: bash tests/test_KAN9_login_failure.sh
# Requires: InCollege binary compiled at project root

set -uo pipefail

BINARY="../InCollege"
PASS=0
FAIL=0
TIMEOUT_SEC=5

run_test() {
    local name="$1"
    local input_content="$2"
    local expect_present="$3"
    local expect_absent="$4"

    cd "$(dirname "$0")/.."
    printf "%s" "$input_content" > InCollege-Input.txt

    local output
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

cd "$(dirname "$0")/.."

# --- Negative: wrong password shows error message ---
run_test "KAN-9-01: wrong password displays error message" \
    "Log In\nJohnDoe\nWrongPassword!" \
    "Invalid username or password" \
    ""

# --- Negative: wrong username shows error message ---
run_test "KAN-9-02: wrong username displays error message" \
    "Log In\nFakeUser\nSecure@123!" \
    "Invalid username or password" \
    ""

# --- Negative: wrong credentials do NOT show success message ---
run_test "KAN-9-03: wrong credentials do not show success" \
    "Log In\nFakeUser\nWrongPassword!" \
    "" \
    "Logged in Successfully!"

# --- Negative: error message is recorded in output file (dual output check) ---
run_test "KAN-9-04: error message written to InCollege-Output.txt" \
    "Log In\nFakeUser\nWrongPassword!" \
    "" \
    ""
# Assert file contains the error message
if grep -qF "Invalid username or password" InCollege-Output.txt 2>/dev/null; then
    echo "PASS: KAN-9-04: error message recorded in InCollege-Output.txt"
    ((PASS++))
else
    echo "FAIL: KAN-9-04: error message not found in InCollege-Output.txt"
    ((FAIL++))
fi

# --- Positive: correct credentials still succeed after KAN-9 changes ---
run_test "KAN-9-05: valid credentials still log in successfully" \
    "Log In\nJohnDoe\nSecure@123!" \
    "Logged in Successfully!" \
    "Invalid username or password"

# Restore default input
printf "Create New Account\nJohn Doe\nJohn6769420@!@@@@!\$" > InCollege-Input.txt

echo ""
echo "Results: $PASS passed, $FAIL failed."
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
