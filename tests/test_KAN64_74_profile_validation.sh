#!/usr/bin/env bash
# KAN-64 & KAN-74: Profile Field Validation & Editing Tests
# KAN-64: User can successfully edit profile and see updated values
# KAN-74: Program handles invalid inputs for required profile fields
# Usage: bash tests/test_KAN64_74_profile_validation.sh
# Requires: InCollege binary compiled at project root

set -uo pipefail

BINARY="../InCollege"
INPUTS="tests/inputs"
PASS=0
FAIL=0
TIMEOUT_SEC=5

run_test() {
    local name="$1"
    local input_file="$2"
    local expect_present="$3"
    local expect_absent="$4"

    cd "$(dirname "$0")/.."
    cp "$input_file" InCollege-Input.txt

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

# --- KAN-64: Valid profile edit shows updated values ---
run_test "KAN-64-01: valid profile edit displays updated first name" \
    "$INPUTS/KAN64_valid_profile_edit.txt" \
    "John" \
    ""

run_test "KAN-64-02: valid profile edit displays updated major" \
    "$INPUTS/KAN64_valid_profile_edit.txt" \
    "Computer Science" \
    ""

run_test "KAN-64-03: valid profile edit displays updated university" \
    "$INPUTS/KAN64_valid_profile_edit.txt" \
    "University of Arizona" \
    ""

# --- KAN-74: Blank required field shows error ---
run_test "KAN-74-01: blank required field displays error message" \
    "$INPUTS/KAN74_blank_field.txt" \
    "required" \
    ""

# --- KAN-74: Non-numeric year shows error ---
run_test "KAN-74-02: non-numeric graduation year displays error" \
    "$INPUTS/KAN74_nonnumeric_year.txt" \
    "Invalid" \
    ""

# --- KAN-74: Out-of-range year shows error ---
run_test "KAN-74-03: out-of-range graduation year displays error" \
    "$INPUTS/KAN74_outofrange_year.txt" \
    "Invalid" \
    ""

# --- KAN-74: Invalid input does not corrupt profile ---
run_test "KAN-74-04: invalid input does not show profile saved confirmation" \
    "$INPUTS/KAN74_blank_field.txt" \
    "" \
    "Profile saved"

# Restore default input
printf "Create New Account\nJohn Doe\nJohn6769420@!@@@@!\$" > InCollege-Input.txt

echo ""
echo "Results: $PASS passed, $FAIL failed."
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
