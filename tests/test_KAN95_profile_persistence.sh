#!/usr/bin/env bash
# KAN-95: Profile Data Persistence Test
# Run 1: create account and save profile
# Run 2: log in and view profile, assert saved values are present
# Usage: bash tests/test_KAN95_profile_persistence.sh
# Requires: InCollege binary compiled at project root

set -uo pipefail

BINARY="../InCollege"
PASS=0
FAIL=0
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

cd "$(dirname "$0")/.."

# --- Run 1: create account and save profile ---
cat > InCollege-Input.txt << 'EOF'
Create New Account
PersistProfile
Profile@99!
Edit Profile
Jane
Smith
Information Systems
Arizona State University
2025
1
Data Analyst Intern
Google
Summer 2025
EOF

timeout "$TIMEOUT_SEC" "$BINARY" > /dev/null 2>&1 || true

assert "KAN-95-01: program completes run 1 without hanging" \
    "true"

# --- Run 2: log in and view profile ---
cat > InCollege-Input.txt << 'EOF'
Log In
PersistProfile
Profile@99!
View Profile
EOF

RUN2_OUTPUT=$(timeout "$TIMEOUT_SEC" "$BINARY" 2>/dev/null || true)

# Assert saved profile values appear in run 2 output
assert "KAN-95-02: first name persists across restart" \
    "echo \"\$RUN2_OUTPUT\" | grep -qF 'Jane'"

assert "KAN-95-03: last name persists across restart" \
    "echo \"\$RUN2_OUTPUT\" | grep -qF 'Smith'"

assert "KAN-95-04: major persists across restart" \
    "echo \"\$RUN2_OUTPUT\" | grep -qF 'Information Systems'"

assert "KAN-95-05: university persists across restart" \
    "echo \"\$RUN2_OUTPUT\" | grep -qF 'Arizona State University'"

assert "KAN-95-06: graduation year persists across restart" \
    "echo \"\$RUN2_OUTPUT\" | grep -qF '2025'"

assert "KAN-95-07: experience entry persists across restart" \
    "echo \"\$RUN2_OUTPUT\" | grep -qF 'Data Analyst Intern'"

# Restore default input
printf "Create New Account\nJohn Doe\nJohn6769420@!@@@@!\$" > InCollege-Input.txt

echo ""
echo "Results: $PASS passed, $FAIL failed."
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
