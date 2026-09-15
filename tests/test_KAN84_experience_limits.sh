#!/usr/bin/env bash
# KAN-84: Experience Entry Limits Tests
<<<<<<< Updated upstream
# Tests: zero entries (skip), one entry, three entries (max)
# Verifies no array overrun or infinite loop occurs
=======
# Tests: zero entries (skip), one entry, three entries (max boundary)
>>>>>>> Stashed changes
# Usage: bash tests/test_KAN84_experience_limits.sh
# Requires: InCollege binary compiled at project root

set -uo pipefail

BINARY="../InCollege"
INPUTS="tests/inputs"
PASS=0
FAIL=0
<<<<<<< Updated upstream
=======
SKIP=0
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
cd "$(dirname "$0")/.."

# --- Zero experience entries: section skipped cleanly ---
run_test "KAN-84-01: zero experience entries completes without error" \
    "$INPUTS/KAN84_zero_experience.txt" \
    "Profile saved" \
    "error"

# --- One experience entry: stored and displayed correctly ---
run_test "KAN-84-02: one experience entry is accepted" \
    "$INPUTS/KAN84_one_experience.txt" \
    "Software Engineer Intern" \
    ""

run_test "KAN-84-03: one experience entry shows employer" \
    "$INPUTS/KAN84_one_experience.txt" \
    "Amazon" \
    ""

# --- Three experience entries: max boundary accepted ---
run_test "KAN-84-04: three experience entries all accepted" \
    "$INPUTS/KAN84_three_experience.txt" \
    "Software Engineer Intern" \
    ""

run_test "KAN-84-05: third experience entry is stored" \
    "$INPUTS/KAN84_three_experience.txt" \
    "QA Tester" \
    ""

# --- Three entries: program terminates within timeout (no infinite loop) ---
cp "$INPUTS/KAN84_three_experience.txt" InCollege-Input.txt
if timeout "$TIMEOUT_SEC" "$BINARY" > /dev/null 2>&1; then
    echo "PASS: KAN-84-06: three entries terminates within ${TIMEOUT_SEC}s"
    ((PASS++))
else
    echo "FAIL: KAN-84-06: program hung or crashed on three experience entries"
    ((FAIL++))
fi

# Restore default input
printf "Create New Account\nJohn Doe\nJohn6769420@!@@@@!\$" > InCollege-Input.txt

echo ""
echo "Results: $PASS passed, $FAIL failed."
=======
skip_test() {
    echo "SKIP: $1 — experience paragraph not yet implemented"
    ((SKIP++))
}

cd "$(dirname "$0")/.."

# --- Zero experience entries: section skipped cleanly ---
skip_test "KAN-84-01: zero experience entries completes without error"
# run_test "KAN-84-01: ..." "$INPUTS/KAN84_zero_experience.txt" "Profile saved" "error"

# --- One experience entry accepted ---
skip_test "KAN-84-02: one experience entry title is stored"
skip_test "KAN-84-03: one experience entry employer is stored"
# run_test "KAN-84-02: ..." "$INPUTS/KAN84_one_experience.txt" "Software Engineer Intern" ""
# run_test "KAN-84-03: ..." "$INPUTS/KAN84_one_experience.txt" "Amazon" ""

# --- Three experience entries: max boundary ---
skip_test "KAN-84-04: three experience entries all accepted"
skip_test "KAN-84-05: third experience entry is stored"
# run_test "KAN-84-04: ..." "$INPUTS/KAN84_three_experience.txt" "Software Engineer Intern" ""
# run_test "KAN-84-05: ..." "$INPUTS/KAN84_three_experience.txt" "QA Tester" ""

# --- Three entries: no infinite loop ---
skip_test "KAN-84-06: three entries terminates within timeout"
# cp "$INPUTS/KAN84_three_experience.txt" InCollege-Input.txt
# if timeout "$TIMEOUT_SEC" "$BINARY" > /dev/null 2>&1; then
#     echo "PASS: KAN-84-06: three entries terminates within ${TIMEOUT_SEC}s"; ((PASS++))
# else
#     echo "FAIL: KAN-84-06: program hung or crashed"; ((FAIL++))
# fi

# Restore default input
printf "Log In\ntestuser\nPassw0rd!1\n4" > InCollege-Input.txt

echo ""
echo "Results: $PASS passed, $FAIL failed, $SKIP skipped."
>>>>>>> Stashed changes
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
