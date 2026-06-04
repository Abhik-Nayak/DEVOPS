#!/bin/bash
# Demonstrates string tests: -z, -n, ==, !=, and pattern matching

echo "=== String Checks Demo ==="
echo ""

# --- Empty vs non-empty ---
echo "--- Testing -z (empty) and -n (non-empty) ---"

empty_var=""
set_var="hello"

if [[ -z $empty_var ]]; then
    echo "empty_var is empty (-z is true)"
fi

if [[ -n $set_var ]]; then
    echo "set_var is non-empty (-n is true), value: '$set_var'"
fi

# --- String equality ---
echo ""
echo "--- Testing string equality ---"

read -p "Enter a color (red/green/blue): " color

if [[ $color == "red" ]]; then
    echo "You chose red."
elif [[ $color == "green" ]]; then
    echo "You chose green."
elif [[ $color == "blue" ]]; then
    echo "You chose blue."
elif [[ -z $color ]]; then
    echo "You did not enter anything."
else
    echo "'$color' is not one of the expected colors."
fi

# --- String inequality ---
echo ""
echo "--- Testing string inequality ---"

default_shell="/bin/bash"
current_shell="$SHELL"

if [[ $current_shell != "$default_shell" ]]; then
    echo "Your shell ($current_shell) is not the default ($default_shell)"
else
    echo "You are using the default shell: $current_shell"
fi

# --- Pattern matching (only works inside [[ ]]) ---
echo ""
echo "--- Pattern matching with [[ ]] ---"

filename="deploy-v2.3.tar.gz"

if [[ $filename == *.tar.gz ]]; then
    echo "'$filename' is a gzipped tarball"
fi

if [[ $filename == deploy* ]]; then
    echo "'$filename' is a deployment artifact"
fi

email="user@example.com"
if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo "'$email' looks like a valid email address"
fi
