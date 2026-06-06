#!/bin/bash
# =============================================================
# 07-sysinfo.sh -- Practical system information report
# Demonstrates: combining everything from Day 7 into a useful script
# Usage: ./07-sysinfo.sh
# =============================================================

# --- Header ---
echo "========================================"
echo "      SYSTEM INFORMATION REPORT"
echo "========================================"
echo "  Generated: $(date)"
echo "  By user:   $(whoami)"
echo "========================================"
echo ""

# --- Hostname and OS ---
echo "--- Host ---"
echo "  Hostname:     $(hostname)"
echo "  Kernel:       $(uname -r)"
echo "  Architecture: $(uname -m)"

if [ -f /etc/os-release ]; then
    OS_NAME=$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f 2)
    echo "  OS:           $OS_NAME"
else
    echo "  OS:           $(uname -s)"
fi
echo ""

# --- Uptime ---
echo "--- Uptime ---"
if [ -f /proc/uptime ]; then
    UPTIME_SEC=$(cut -d '.' -f 1 /proc/uptime)
    DAYS=$(( UPTIME_SEC / 86400 ))
    HOURS=$(( (UPTIME_SEC % 86400) / 3600 ))
    MINS=$(( (UPTIME_SEC % 3600) / 60 ))
    echo "  System up for: ${DAYS} days, ${HOURS} hours, ${MINS} minutes"
else
    echo "  Uptime: $(uptime 2>/dev/null || echo 'unavailable')"
fi
echo ""

# --- Disk Usage ---
echo "--- Disk Usage (/) ---"
if command -v df > /dev/null 2>&1; then
    DISK_INFO=$(df -h / 2>/dev/null | tail -1)
    DISK_TOTAL=$(echo "$DISK_INFO" | awk '{print $2}')
    DISK_USED=$(echo "$DISK_INFO" | awk '{print $3}')
    DISK_FREE=$(echo "$DISK_INFO" | awk '{print $4}')
    DISK_PCT=$(echo "$DISK_INFO" | awk '{print $5}')
    echo "  Total:    $DISK_TOTAL"
    echo "  Used:     $DISK_USED ($DISK_PCT)"
    echo "  Free:     $DISK_FREE"
else
    echo "  df command not available."
fi
echo ""

# --- Memory ---
echo "--- Memory ---"
if command -v free > /dev/null 2>&1; then
    MEM_INFO=$(free -h | grep Mem)
    MEM_TOTAL=$(echo "$MEM_INFO" | awk '{print $2}')
    MEM_USED=$(echo "$MEM_INFO" | awk '{print $3}')
    MEM_FREE=$(echo "$MEM_INFO" | awk '{print $4}')
    echo "  Total:    $MEM_TOTAL"
    echo "  Used:     $MEM_USED"
    echo "  Free:     $MEM_FREE"
else
    echo "  free command not available (try: cat /proc/meminfo)"
fi
echo ""

# --- Logged-in Users ---ls 
echo "--- Logged-in Users ---"
if command -v who > /dev/null 2>&1; then
    USER_COUNT=$(who 2>/dev/null | wc -l)
    echo "  Currently logged in: $USER_COUNT user(s)"
    who 2>/dev/null | awk '{print "  - " $1 " (from " $5 " since " $3 " " $4 ")"}'
else
    echo "  who command not available."
fi
echo ""

# --- Top 5 Processes by CPU ---
echo "--- Top 5 Processes (by CPU) ---"
if command -v ps > /dev/null 2>&1; then
    printf "  %-12s %6s %6s %s\n" "USER" "%CPU" "%MEM" "COMMAND"
    ps aux --sort=-%cpu 2>/dev/null | head -6 | tail -5 | awk '{printf "  %-12s %6s %6s %s\n", $1, $3, $4, $11}'
else
    echo "  ps command not available."
fi
echo ""

# --- Footer ---
echo "========================================"
echo "      END OF REPORT"
echo "========================================"

exit 0
