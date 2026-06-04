#!/bin/bash
# =============================================================
# 04-user-input.sh -- Reading input from the user
# Demonstrates: read, read -p, read -s, read with timeout
# =============================================================

echo "=== Basic Read ==="
echo "What is your name?"
read NAME
echo "Hello, $NAME!"

echo ""
echo "=== Read with Prompt (-p) ==="
read -p "Enter your favorite color: " COLOR
echo "Nice choice! $COLOR is a great color."

echo ""
echo "=== Reading Multiple Values ==="
read -p "Enter your first and last name: " FIRST LAST
echo "First name: $FIRST"
echo "Last name:  $LAST"

echo ""
echo "=== Silent Read (-s) for Passwords ==="
read -s -p "Enter a secret password: " PASSWORD
echo ""   # Add a newline since -s suppresses it
echo "Your password is ${#PASSWORD} characters long."

echo ""
echo "=== Read with Timeout (-t) ==="
read -t 5 -p "You have 5 seconds to type something: " QUICK
if [ $? -eq 0 ]; then
    echo ""
    echo "You typed: $QUICK"
else
    echo ""
    echo "Too slow! Time ran out."
fi

echo ""
echo "=== Confirm Before Proceeding ==="
read -p "Do you want to continue? (y/n): " CONFIRM
if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
    echo "Continuing..."
else
    echo "Aborted by user."
fi

echo ""
echo "Done! The 'read' command is how scripts become interactive."
