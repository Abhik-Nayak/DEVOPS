#!/bin/bash
# Demonstrates file test operators: -f, -d, -e, -r, -w, -x, -s

echo "=== File Test Operators Demo ==="
echo ""

# Use a file passed as argument, or default to this script itself
target=${1:-"$0"}

echo "Testing: $target"
echo ""

# Does it exist at all?
if [[ -e $target ]]; then
    echo "[EXISTS]     Yes, '$target' exists"
else
    echo "[EXISTS]     No, '$target' does not exist"
    exit 1
fi

# What type is it?
if [[ -f $target ]]; then
    echo "[TYPE]       Regular file"
elif [[ -d $target ]]; then
    echo "[TYPE]       Directory"
elif [[ -L $target ]]; then
    echo "[TYPE]       Symbolic link"
else
    echo "[TYPE]       Other (device, socket, pipe, etc.)"
fi

# Permission checks
if [[ -r $target ]]; then
    echo "[READABLE]   Yes"
else
    echo "[READABLE]   No"
fi

if [[ -w $target ]]; then
    echo "[WRITABLE]   Yes"
else
    echo "[WRITABLE]   No"
fi

if [[ -x $target ]]; then
    echo "[EXECUTABLE] Yes"
else
    echo "[EXECUTABLE] No"
fi

# Size check (files only)
if [[ -f $target ]]; then
    if [[ -s $target ]]; then
        echo "[NON-EMPTY]  Yes (has content)"
    else
        echo "[NON-EMPTY]  No (file is empty)"
    fi
fi

echo ""
echo "Usage: $0 <path-to-file-or-directory>"
echo "Try: $0 /etc/passwd"
echo "Try: $0 /tmp"
echo "Try: $0 /nonexistent"
