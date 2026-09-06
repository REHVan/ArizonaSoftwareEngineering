#!/usr/bin/env bash
# KAN-24: Data Persistence Test
# Verifies InCollege-Output.txt persists between program executions and
# that data written in run 1 is present when the file is read in run 2.
# Usage: bash tests/test_KAN24_persistence.sh
# Requires: InCollege binary compiled at project root

set -uo pipefail

BINARY="../InCollege"
OUT_FILE="InCollege-Output.txt"
PASS=0
FAIL=0

cd "$(dirname "$0")/.."

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

# --- Run 1: create an account, capture output ---
printf "Create New Account\nPersistUser\nPersist@99!" > InCollege-Input.txt
rm -f "$OUT_FILE"

"$BINARY" > /dev/null 2>&1 || true

assert "KAN-24-01: output file exists after run 1" \
    "[[ -f '$OUT_FILE' ]]"

assert "KAN-24-02: output file is non-empty after run 1" \
    "[[ -s '$OUT_FILE' ]]"

assert "KAN-24-03: 'Account Created!' written to file in run 1" \
    "grep -qF 'Account Created!' '$OUT_FILE'"

# Capture the file content from run 1
RUN1_CONTENT=$(cat "$OUT_FILE")

# --- Run 2: log in with same user, output file is overwritten (OPEN OUTPUT) ---
printf "Log In\nPersistUser\nPersist@99!" > InCollege-Input.txt

"$BINARY" > /dev/null 2>&1 || true

assert "KAN-24-04: output file still exists after run 2" \
    "[[ -f '$OUT_FILE' ]]"

assert "KAN-24-05: 'Logged in Successfully!' written to file in run 2" \
    "grep -qF 'Logged in Successfully!' '$OUT_FILE'"

# --- Verify run 1 data is distinct from run 2 data (two separate executions) ---
RUN2_CONTENT=$(cat "$OUT_FILE")
assert "KAN-24-06: run 1 and run 2 output files differ (separate executions)" \
    "[[ '$RUN1_CONTENT' != '$RUN2_CONTENT' ]]"

# Restore default input
printf "Create New Account\nJohn Doe\nJohn6769420@!@@@@!\$" > InCollege-Input.txt

echo ""
echo "Results: $PASS passed, $FAIL failed."
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
