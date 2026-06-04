#!/bin/bash
# Demonstrates number comparisons with -eq, -gt, -lt, -ge, -le, -ne

echo "=== Number Comparison Demo ==="
echo ""

read -p "Enter your age: " age

# Validate that input is a number
if [[ ! $age =~ ^[0-9]+$ ]]; then
    echo "ERROR: '$age' is not a valid number."
    exit 1
fi

echo ""
echo "Comparing age=$age against various thresholds:"
echo ""

if [[ $age -lt 0 ]]; then
    echo "That is not a valid age."
elif [[ $age -eq 0 ]]; then
    echo "You were just born. Welcome to the world."
elif [[ $age -lt 13 ]]; then
    echo "You are a child (under 13)."
elif [[ $age -lt 18 ]]; then
    echo "You are a teenager (13-17)."
elif [[ $age -lt 65 ]]; then
    echo "You are an adult (18-64)."
elif [[ $age -ge 65 ]]; then
    echo "You are a senior (65+)."
fi

echo ""
echo "--- Additional comparisons ---"
echo "age -eq 21 : $( [[ $age -eq 21 ]] && echo "true" || echo "false" )"
echo "age -ne 0  : $( [[ $age -ne 0 ]] && echo "true" || echo "false" )"
echo "age -gt 50 : $( [[ $age -gt 50 ]] && echo "true" || echo "false" )"
echo "age -lt 30 : $( [[ $age -lt 30 ]] && echo "true" || echo "false" )"
echo "age -ge 18 : $( [[ $age -ge 18 ]] && echo "true" || echo "false" )"
echo "age -le 100: $( [[ $age -le 100 ]] && echo "true" || echo "false" )"
