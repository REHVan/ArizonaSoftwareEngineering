#!/usr/bin/env bash
# KAN-95: Profile Data Persistence Test
# Run 1: log in, create/edit profile and save profile data
# Run 2: restart program, log in again and view saved profile
# Verifies that profile data persists across program restarts.

set -uo pipefail

BINARY="./InCollege"
ACCOUNTS_FILE="InCollege-Accounts.txt"
PROFILE_FILE="user-data/kan95user.txt"
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

# Make sure the test account exists.
if ! grep -qF "kan95user" "$ACCOUNTS_FILE"; then
    printf "Create New Account\nkan95user\nKan95!pwd\n" > InCollege-Input.txt
    timeout "$TIMEOUT_SEC" "$BINARY" > /dev/null 2>&1 || true
fi

# Remove any old profile so Run 1 starts clean.
rm -f "$PROFILE_FILE"

# ------------------------------------------------------------
# RUN 1: Log in and create a profile.
# ------------------------------------------------------------
cat > InCollege-Input.txt <<'EOF'
Log In
kan95user
Kan95!pwd
1
Jane
Smith
University of South Florida
Computer Science
2027
Persistence test profile
START
Software Engineer Intern
Test Company
Summer 2026
Persistence testing experience
DONE
DONE
EOF

RUN1_OUTPUT=$(timeout "$TIMEOUT_SEC" "$BINARY" 2>/dev/null || true)

assert "KAN-95-01: login succeeds on run 1" \
    "echo \"\$RUN1_OUTPUT\" | grep -qF 'You have successfully logged in'"

assert "KAN-95-02: profile saved successfully on run 1" \
    "echo \"\$RUN1_OUTPUT\" | grep -qF 'Profile saved successfully!'"

assert "KAN-95-03: profile file exists after run 1" \
    "test -f '$PROFILE_FILE'"

# ------------------------------------------------------------
# RUN 2: Restart, log in and view the saved profile.
# ------------------------------------------------------------
cat > InCollege-Input.txt <<'EOF'
Log In
kan95user
Kan95!pwd
2
EOF

RUN2_OUTPUT=$(timeout "$TIMEOUT_SEC" "$BINARY" 2>/dev/null || true)

assert "KAN-95-04: first name persists across restart" \
    "echo \"\$RUN2_OUTPUT\" | grep -qF 'Jane'"

assert "KAN-95-05: last name persists across restart" \
    "echo \"\$RUN2_OUTPUT\" | grep -qF 'Smith'"

assert "KAN-95-06: major persists across restart" \
    "echo \"\$RUN2_OUTPUT\" | grep -qF 'Computer Science'"

assert "KAN-95-07: university persists across restart" \
    "echo \"\$RUN2_OUTPUT\" | grep -qF 'University of South Florida'"

assert "KAN-95-08: graduation year persists across restart" \
    "echo \"\$RUN2_OUTPUT\" | grep -qF '2027'"

assert "KAN-95-09: experience entry persists across restart" \
    "echo \"\$RUN2_OUTPUT\" | grep -qF 'Software Engineer Intern'"

# Restore a normal input file after testing.
printf "Log In\nJohnDoe123456\ntEstpass3@!\n" > InCollege-Input.txt

echo ""
echo "Results: $PASS passed, $FAIL failed."
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
