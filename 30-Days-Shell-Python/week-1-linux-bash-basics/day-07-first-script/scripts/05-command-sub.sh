#!/bin/bash
# =============================================================
# 05-command-sub.sh -- Capturing command output into variables
# Demonstrates: $(command) syntax for date, hostname, whoami, etc.
# =============================================================

echo "=== Basic Command Substitution ==="
CURRENT_DATE=$(date)
CURRENT_USER=$(whoami)
CURRENT_HOST=$(hostname)
CURRENT_DIR=$(pwd)

echo "Date:      $CURRENT_DATE"
echo "User:      $CURRENT_USER"
echo "Hostname:  $CURRENT_HOST"
echo "Directory: $CURRENT_DIR"

echo ""
echo "=== Formatted Date ==="
TODAY=$(date +%Y-%m-%d)
NOW=$(date +%H:%M:%S)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "Today:     $TODAY"
echo "Time:      $NOW"
echo "Timestamp: $TIMESTAMP"

echo ""
echo "=== System Information via Command Substitution ==="
KERNEL=$(uname -r)
ARCH=$(uname -m)
SHELL_NAME=$(basename "$SHELL")

echo "Kernel:    $KERNEL"
echo "Arch:      $ARCH"
echo "Shell:     $SHELL_NAME"

echo ""
echo "=== Counting Things ==="
NUM_FILES=$(ls -1 2>/dev/null | wc -l)
NUM_PROCS=$(ps aux 2>/dev/null | wc -l)

echo "Files in current directory: $NUM_FILES"
echo "Running processes:          $NUM_PROCS"

echo ""
echo "=== Using Command Substitution in Strings ==="
echo "This script was run by $(whoami) on $(hostname) at $(date +%H:%M)"

echo ""
echo "=== Creating Dynamic Filenames ==="
BACKUP_NAME="backup_$(hostname)_$(date +%Y%m%d).tar.gz"
LOG_NAME="deploy_$(whoami)_$(date +%s).log"

echo "Backup filename: $BACKUP_NAME"
echo "Log filename:    $LOG_NAME"

echo ""
echo "Done! Command substitution lets your scripts react to the environment."
