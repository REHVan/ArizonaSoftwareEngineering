#!/usr/bin/env bash
# KAN-99 & KAN-100: Edge-Case Batch Testing
# Feeds all batch input files into the COBOL binary.
# Logs stdout and stderr to results/ for review.
# A crash (non-zero exit) or hang (timeout) counts as a failure.
# Usage: bash run_profile_batch_tests.sh
# Requires: InCollege binary compiled at project root

set -uo pipefail

BINARY="./InCollege"
BATCH_DIR="tests/batch_inputs"
RESULTS_DIR="results"
TIMEOUT_SEC=5
PASS=0
FAIL=0

cd "$(dirname "$0")"
mkdir -p "$RESULTS_DIR"

for input_file in "$BATCH_DIR"/*.txt; do
    test_name=$(basename "$input_file" .txt)
    stdout_log="$RESULTS_DIR/${test_name}.stdout.log"
    stderr_log="$RESULTS_DIR/${test_name}.stderr.log"

    cp "$input_file" InCollege-Input.txt

    if timeout "$TIMEOUT_SEC" "$BINARY" > "$stdout_log" 2> "$stderr_log"; then
        echo "PASS: $test_name — exited cleanly"
        ((PASS++))
    else
        exit_code=$?
        if [[ $exit_code -eq 124 ]]; then
            echo "FAIL (TIMEOUT): $test_name — hung after ${TIMEOUT_SEC}s"
            echo "TIMEOUT" >> "$stdout_log"
        else
            echo "FAIL (CRASH): $test_name — exit code $exit_code"
        fi
        ((FAIL++))
    fi
done

# Restore default input
printf "Log In\ntestuser\nPassw0rd!1\n4" > InCollege-Input.txt

echo ""
echo "Batch Results: $PASS passed, $FAIL failed."
echo "Logs saved to $RESULTS_DIR/"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
