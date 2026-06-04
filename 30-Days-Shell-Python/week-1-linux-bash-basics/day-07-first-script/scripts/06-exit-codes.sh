#!/bin/bash
# =============================================================
# 06-exit-codes.sh -- Understanding and using exit codes
# Demonstrates: $?, exit 0, exit 1, checking command success
# =============================================================

echo "=== Exit Codes of Common Commands ==="

# Successful command
echo "Running: ls /tmp"
ls /tmp > /dev/null 2>&1
echo "Exit code: $? (0 means success)"

echo ""

# Failed command
echo "Running: ls /nonexistent_directory"
ls /nonexistent_directory > /dev/null 2>&1
echo "Exit code: $? (non-zero means failure)"

echo ""
echo "=== Checking Exit Codes in Scripts ==="

# Check if a file exists
FILE="/etc/passwd"
echo "Checking if $FILE exists..."
if [ -f "$FILE" ]; then
    echo "  Result: File exists (would exit 0)"
else
    echo "  Result: File not found (would exit 1)"
fi

echo ""
echo "=== Using Exit Codes for Flow Control ==="

# Try to create a temp file and check if it worked
TEMP_FILE="/tmp/exit_code_test_$$"
touch "$TEMP_FILE" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "Successfully created temp file: $TEMP_FILE"
    rm "$TEMP_FILE"
    echo "Cleaned up temp file."
else
    echo "Failed to create temp file."
fi

echo ""
echo "=== Command Chaining with Exit Codes ==="
echo "Using && (AND) -- second command runs only if first succeeds:"
echo "  ls /tmp > /dev/null && echo '  /tmp is accessible'"

ls /tmp > /dev/null 2>&1 && echo "  /tmp is accessible"

echo ""
echo "Using || (OR) -- second command runs only if first fails:"
echo "  ls /fake_dir 2>/dev/null || echo '  /fake_dir does not exist'"

ls /fake_dir 2>/dev/null || echo "  /fake_dir does not exist"

echo ""
echo "=== Summary of Common Exit Codes ==="
echo "  0   -- Success"
echo "  1   -- General error"
echo "  2   -- Misuse of command"
echo "  126 -- Command not executable"
echo "  127 -- Command not found"
echo "  130 -- Terminated by Ctrl+C"

echo ""
echo "This script will exit with code 0 (success)."
exit 0
