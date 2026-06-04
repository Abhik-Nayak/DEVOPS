#!/bin/bash
# Demonstrates basic if/elif/else with string comparison

echo "=== Basic If/Elif/Else Demo ==="
echo ""

read -p "Enter your role (admin/editor/viewer): " role

if [[ $role == "admin" ]]; then
    echo "Welcome, Administrator. You have full access."
    echo "  - Read: yes"
    echo "  - Write: yes"
    echo "  - Delete: yes"
elif [[ $role == "editor" ]]; then
    echo "Welcome, Editor. You have read and write access."
    echo "  - Read: yes"
    echo "  - Write: yes"
    echo "  - Delete: no"
elif [[ $role == "viewer" ]]; then
    echo "Welcome, Viewer. You have read-only access."
    echo "  - Read: yes"
    echo "  - Write: no"
    echo "  - Delete: no"
else
    echo "Unknown role: '$role'"
    echo "Valid roles: admin, editor, viewer"
    exit 1
fi

echo ""
echo "Tip: This script uses [[ == ]] for string comparison."
