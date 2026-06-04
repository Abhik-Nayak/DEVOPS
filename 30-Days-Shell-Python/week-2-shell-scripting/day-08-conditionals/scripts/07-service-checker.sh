#!/bin/bash
# Checks if common services are running — a practical DevOps health-check script

echo "=========================================="
echo "  SERVICE HEALTH CHECK"
echo "=========================================="
echo ""

# Define services to check
services=("sshd" "nginx" "docker" "postgresql" "redis-server" "cron")

running=0
stopped=0
total=${#services[@]}

for svc in "${services[@]}"; do
    # Method 1: Try systemctl (modern Linux with systemd)
    if command -v systemctl &>/dev/null; then
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            echo "  [RUNNING]  $svc"
            ((running++))
            continue
        fi
    fi

    # Method 2: Try checking the process list
    if pgrep -x "$svc" &>/dev/null; then
        echo "  [RUNNING]  $svc"
        ((running++))
        continue
    fi

    # If neither found it running
    echo "  [STOPPED]  $svc"
    ((stopped++))
done

echo ""
echo "=========================================="
echo "  SUMMARY"
echo "=========================================="
echo "  Total services checked: $total"
echo "  Running:                $running"
echo "  Stopped:                $stopped"
echo ""

if [[ $stopped -eq 0 ]]; then
    echo "  All services are running."
elif [[ $stopped -eq $total ]]; then
    echo "  WARNING: No services are running!"
else
    echo "  WARNING: $stopped service(s) are not running."
fi

echo ""
echo "Tip: Run with sudo for more accurate results."
echo "Tip: Edit the 'services' array to check your own services."
