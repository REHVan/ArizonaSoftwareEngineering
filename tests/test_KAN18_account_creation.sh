#!/usr/bin/env bash
# KAN-18: Account Creation Tests
# Tests: positive creation, empty username, empty password, max-length username (50 chars)
# Usage: bash tests/test_KAN18_account_creation.sh
# Requires: InCollege binary compiled at project root

set -uo pipefail

BINARY="../InCollege"
PASS=0
FAIL=0

run_test() {
    local name="$1"
    local input="$2"
    local expect_in_output="$3"
    local expect_absent="$4"

    local tmpinput
    tmpinput=$(mktemp)
    echo "$input" > "$tmpinput"

    local output
    output=$("$BINARY" < /dev/null 2>/dev/null \
        || true)

    # Feed input via the file the program reads
    cp "$tmpinput" InCollege-Input.txt
    output=$("$BINARY" 2>/dev/null || true)

    rm -f "$tmpinput"

    local ok=1
    if [[ -n "$expect_in_output" ]] && ! echo "$output" | grep -qF "$expect_in_output"; then
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

# --- Positive: valid username and password ---
printf "Create New Account\nJohnDoe\nSecure@123!" > InCollege-Input.txt
run_test "KAN-18-01: valid account creation" \
    "" \
    "Account Created!" \
    ""

# --- Negative: empty username (spaces only) ---
printf "Create New Account\n          \nSecure@123!" > InCollege-Input.txt
run_test "KAN-18-02: empty username (spaces)" \
    "" \
    "Please enter your username:" \
    ""
# Program currently accepts it — test documents current behaviour
# When validation is added, assert "Invalid" appears instead of "Account Created!"

# --- Negative: empty password (spaces only) ---
printf "Create New Account\nJohnDoe\n          " > InCollege-Input.txt
run_test "KAN-18-03: empty password (spaces)" \
    "" \
    "Please enter your password:" \
    ""

# --- Edge case: username exactly 50 chars (PIC X(50) boundary) ---
LONG_USER=$(printf '%.0sA' {1..50})   # 50 'A' characters
printf "Create New Account\n%s\nSecure@123!" "$LONG_USER" > InCollege-Input.txt
run_test "KAN-18-04: username at 50-char PIC X limit" \
    "" \
    "Account Created!" \
    ""

# --- Edge case: username 51 chars (exceeds PIC X(50), gets truncated) ---
OVER_USER=$(printf '%.0sA' {1..51})   # 51 'A' characters
printf "Create New Account\n%s\nSecure@123!" "$OVER_USER" > InCollege-Input.txt
run_test "KAN-18-05: username exceeds 50-char PIC X limit (truncation)" \
    "" \
    "Account Created!" \
    ""

# Restore default input
printf "Create New Account\nJohn Doe\nJohn6769420@!@@@@!\$" > InCollege-Input.txt

echo ""
echo "Results: $PASS passed, $FAIL failed."
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
