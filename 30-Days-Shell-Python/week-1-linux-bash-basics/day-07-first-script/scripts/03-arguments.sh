#!/bin/bash
# =============================================================
# 03-arguments.sh -- Positional parameters and special variables
# Demonstrates: $0, $1, $2, $#, $@, $$
# Usage: ./03-arguments.sh arg1 arg2 arg3
# =============================================================

echo "=== Script Information ==="
echo "Script name (\$0):    $0"
echo "Process ID (\$\$):     $$"

echo ""
echo "=== Argument Details ==="
echo "Number of args (\$#): $#"
echo "All args (\$@):       $@"

echo ""
echo "=== Individual Arguments ==="
echo "Arg 1 (\$1): $1"
echo "Arg 2 (\$2): $2"
echo "Arg 3 (\$3): $3"

echo ""
echo "=== Looping Through All Arguments ==="
if [ $# -eq 0 ]; then
    echo "No arguments provided."
    echo "Try: $0 hello world foo bar"
else
    COUNT=1
    for ARG in "$@"; do
        echo "  Argument $COUNT: $ARG"
        COUNT=$(( COUNT + 1 ))
    done
fi

echo ""
echo "=== Practical Example: File Checker ==="
if [ $# -ge 1 ]; then
    for FILE in "$@"; do
        if [ -f "$FILE" ]; then
            echo "  [EXISTS] $FILE"
        else
            echo "  [MISSING] $FILE"
        fi
    done
else
    echo "Pass filenames as arguments to check if they exist."
    echo "Example: $0 /etc/passwd /etc/shadow /tmp/fake"
fi
