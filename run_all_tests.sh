#!/usr/bin/env bash
# Run all InCollege test suites.
# Usage: bash run_all_tests.sh
# Compiles the binary first, then runs each suite.

set -uo pipefail

cd "$(dirname "$0")"

echo "=== Compiling InCollege ==="
cobc -x -o InCollege InCollege.cob
echo "Compilation OK"
echo ""

SUITES=(
    "tests/test_KAN18_account_creation.sh"
    "tests/test_KAN28_login.sh"
    "tests/test_KAN31_37_menus.sh"
    "tests/test_KAN24_persistence.sh"
    "test_dual_output.sh"
)

OVERALL=0

for suite in "${SUITES[@]}"; do
    echo "=== $suite ==="
    bash "$suite" || OVERALL=1
    echo ""
done

if [[ $OVERALL -eq 0 ]]; then
    echo "All suites passed."
else
    echo "One or more suites failed."
    exit 1
fi
