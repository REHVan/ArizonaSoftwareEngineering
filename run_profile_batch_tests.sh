#!/usr/bin/env bash
# KAN-99 & KAN-100: File-Based Batch Testing
# Feeds all edge-case input files into the COBOL binary.
# Results are written to results/ for manual review.
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
    result_file="$RESULTS_DIR/${test_name}.log"

    cp "$input_file" InCollege-Input.txt

    # Run with timeout — a hang counts as a failure
    if timeout "$TIMEOUT_SEC" "$BINARY" > "$result_file" 2>&1; then
        exit_code=0
    else
        exit_code=$?
    fi

    if [[ $exit_code -eq 124 ]]; then
        echo "FAIL (TIMEOUT): $test_name — program hung after ${TIMEOUT_SEC}s"
        echo "TIMEOUT after ${TIMEOUT_SEC}s" >> "$result_file"
        ((FAIL++))
    elif [[ $exit_code -ne 0 ]]; then
        echo "FAIL (CRASH): $test_name — exit code $exit_code"
        ((FAIL++))
    else
        echo "PASS: $test_name — completed cleanly, log: $result_file"
        ((PASS++))
    fi
done

# Restore default input
printf "Create New Account\nJohn Doe\nJohn6769420@!@@@@!\$" > InCollege-Input.txt

echo ""
echo "Batch Results: $PASS passed, $FAIL failed."
echo "Logs saved to $RESULTS_DIR/"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
