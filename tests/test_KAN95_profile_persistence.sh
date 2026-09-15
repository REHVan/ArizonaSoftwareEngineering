#!/usr/bin/env bash
# KAN-95: Profile Data Persistence Test
# Run 1: create account and save profile
# Run 2: log in and view profile, assert saved values match run 1
# Usage: bash tests/test_KAN95_profile_persistence.sh
# Requires: InCollege binary compiled at project root

set -uo pipefail

BINARY="../InCollege"
ACCOUNTS_FILE="InCollege-Accounts.txt"
PASS=0
FAIL=0
SKIP=0
TIMEOUT_SEC=5

assert() {
    local name="$1"
    local condition="$2"
    if eval "$condition"; then
        echo "PASS: $name"
        ((PASS++))
    else
        echo "FAIL: $name"
        ((FAIL++))
    fi
}

skip_test() {
    echo "SKIP: $1 — profile save/load not yet implemented"
    ((SKIP++))
}

cd "$(dirname "$0")/.."

# --- Baseline: account data persists across two runs (already implemented) ---
# Run 1: create account
printf "Create New Account\nkan95user\nKan95!pwd\n4" > InCollege-Input.txt
timeout "$TIMEOUT_SEC" "$BINARY" > /dev/null 2>&1 || true

assert "KAN-95-01: account written to accounts file after run 1" \
    "grep -qF 'kan95user' '$ACCOUNTS_FILE'"

# Run 2: log in with same credentials
printf "Log In\nkan95user\nKan95!pwd\n4" > InCollege-Input.txt
RUN2_OUTPUT=$(timeout "$TIMEOUT_SEC" "$BINARY" 2>/dev/null || true)

assert "KAN-95-02: account credentials persist — login succeeds on run 2" \
    "echo \"\$RUN2_OUTPUT\" | grep -qF 'You have successfully logged in'"

assert "KAN-95-03: username displayed correctly on run 2" \
    "echo \"\$RUN2_OUTPUT\" | grep -qF 'Welcome, kan95user'"

# --- Profile field persistence: stubs until EDIT-PROFILE is implemented ---
skip_test "KAN-95-04: first name persists across restart"
skip_test "KAN-95-05: last name persists across restart"
skip_test "KAN-95-06: major persists across restart"
skip_test "KAN-95-07: university persists across restart"
skip_test "KAN-95-08: graduation year persists across restart"
skip_test "KAN-95-09: experience entry persists across restart"
# When EDIT-PROFILE is implemented, replace stubs with:
#   assert "KAN-95-04: first name persists" \
#       "echo \"\$RUN2_OUTPUT\" | grep -qF 'Jane'"

# Restore default input
printf "Log In\ntestuser\nPassw0rd!1\n4" > InCollege-Input.txt

echo ""
echo "Results: $PASS passed, $FAIL failed, $SKIP skipped."
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
