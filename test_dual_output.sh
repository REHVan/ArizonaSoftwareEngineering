#!/usr/bin/env bash
# KAN-43: Verify dual output — console stdout matches InCollege-Output.txt exactly.
# Usage: bash test_dual_output.sh
# Requires: InCollege binary compiled (cobc -x -o InCollege InCollege.cob)

set -euo pipefail

BINARY="./InCollege"
OUT_FILE="InCollege-Output.txt"
CONSOLE_TMP=$(mktemp)

# Run program, capture stdout
"$BINARY" > "$CONSOLE_TMP"

# Strip trailing whitespace from both sources so comparison is content-only
CONSOLE_CLEAN=$(sed 's/[[:space:]]*$//' "$CONSOLE_TMP")
FILE_CLEAN=$(sed 's/[[:space:]]*$//' "$OUT_FILE")

if diff <(echo "$CONSOLE_CLEAN") <(echo "$FILE_CLEAN") > /dev/null 2>&1; then
    LINE_COUNT=$(echo "$CONSOLE_CLEAN" | wc -l | tr -d ' ')
    echo "PASS: $LINE_COUNT lines match between console and $OUT_FILE."
else
    echo "FAIL: console output does not match $OUT_FILE."
    diff <(echo "$CONSOLE_CLEAN") <(echo "$FILE_CLEAN")
    rm -f "$CONSOLE_TMP"
    exit 1
fi

rm -f "$CONSOLE_TMP"
