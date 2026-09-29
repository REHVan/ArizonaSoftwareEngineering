#!/usr/bin/env bash
# Tests for KAN-135, KAN-136, KAN-137, KAN-138, KAN-139
PASS=0; FAIL=0
BIN=./InCollege
CONN_FILE="user-data/JohnDoe123456-connections.txt"

run() {
    local label="$1" input="$2" pattern="$3"
    local out
    out=$($BIN < "$input" 2>&1)
    if echo "$out" | grep -qF "$pattern"; then
        echo "PASS: $label"; ((PASS++))
    else
        echo "FAIL: $label (expected: '$pattern')"
        echo "  Output: $out"
        ((FAIL++))
    fi
}

# KAN-137: send a fresh request, file should contain PENDING-SENT
rm -f "$CONN_FILE" user-data/JohnDoe67420-connections.txt
run "KAN-137 send request" \
    tests/epic4/inputs/KAN137-send-request.txt \
    "Connection request sent!"
if grep -qF "PENDING-SENT:JohnDoe67420" "$CONN_FILE" 2>/dev/null; then
    echo "PASS: KAN-137 PENDING-SENT persisted"; ((PASS++))
else
    echo "FAIL: KAN-137 PENDING-SENT not found in $CONN_FILE"; ((FAIL++))
fi
if grep -qF "PENDING-RECV:JohnDoe123456" user-data/JohnDoe67420-connections.txt 2>/dev/null; then
    echo "PASS: KAN-137 PENDING-RECV written to target file"; ((PASS++))
else
    echo "FAIL: KAN-137 PENDING-RECV not in target file"; ((FAIL++))
fi

# KAN-135: already connected — seed CONNECTED entry then try again
echo "CONNECTED:JohnDoe123" > "$CONN_FILE"
run "KAN-135 already connected" \
    tests/epic4/inputs/KAN135-already-connected.txt \
    "You are already connected with this user."

# KAN-136: target already sent us a request — seed PENDING-RECV then try
echo "PENDING-RECV:JohnDoe123" > "$CONN_FILE"
run "KAN-136 already sent request" \
    tests/epic4/inputs/KAN136-already-sent-request.txt \
    "This user has already sent you a request."

# KAN-138 / KAN-139: view pending requests menu option
echo "PENDING-RECV:JohnDoe123" > "$CONN_FILE"
run "KAN-138/139 view pending requests" \
    tests/epic4/inputs/KAN138-139-view-pending.txt \
    "Request from: JohnDoe123"

# KAN-139: menu shows option 6
run "KAN-139 menu option visible" \
    tests/epic4/inputs/KAN138-139-view-pending.txt \
    "6. View Pending Requests"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ]
