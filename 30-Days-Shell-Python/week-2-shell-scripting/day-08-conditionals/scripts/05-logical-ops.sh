#!/bin/bash
# Demonstrates combining conditions with && (AND), || (OR), and ! (NOT)

echo "=== Logical Operators Demo ==="
echo ""

# --- AND: both conditions must be true ---
echo "--- AND (&&) ---"

read -p "Enter a number between 1 and 100: " num

if [[ $num -ge 1 && $num -le 100 ]]; then
    echo "  $num is in the valid range (1-100)"
else
    echo "  $num is outside the valid range"
fi

# --- OR: at least one condition must be true ---
echo ""
echo "--- OR (||) ---"

read -p "Enter a file extension (jpg/png/gif/bmp): " ext

if [[ $ext == "jpg" || $ext == "png" || $ext == "gif" ]]; then
    echo "  '.$ext' is a web-friendly image format"
else
    echo "  '.$ext' is not a standard web image format"
fi

# --- NOT: invert a condition ---
echo ""
echo "--- NOT (!) ---"

read -p "Enter a directory path to check: " dir_path

if [[ ! -d $dir_path ]]; then
    echo "  '$dir_path' does not exist or is not a directory"
else
    echo "  '$dir_path' exists and is a directory"
fi

# --- Combining all three ---
echo ""
echo "--- Combined example ---"

config_file="/etc/hosts"

if [[ -f $config_file && -r $config_file && ! -z $(cat "$config_file" 2>/dev/null) ]]; then
    echo "  '$config_file' exists, is readable, and has content"
else
    echo "  '$config_file' is missing, unreadable, or empty"
fi

# --- Short-circuit style ---
echo ""
echo "--- Short-circuit style ---"

command -v git &>/dev/null && echo "  git is installed" || echo "  git is NOT installed"
command -v docker &>/dev/null && echo "  docker is installed" || echo "  docker is NOT installed"
command -v python3 &>/dev/null && echo "  python3 is installed" || echo "  python3 is NOT installed"
