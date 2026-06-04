#!/bin/bash
# Demonstrates case statements with a practical command dispatcher

echo "=== System Admin Command Dispatcher ==="
echo ""
echo "Available commands:"
echo "  status   - Show system status"
echo "  disk     - Show disk usage"
echo "  users    - Show logged-in users"
echo "  network  - Show network info"
echo "  procs    - Show top processes by memory"
echo "  help     - Show this help"
echo "  quit     - Exit"
echo ""

while true; do
    read -p "sysadmin> " cmd

    case $cmd in
        status)
            echo ""
            echo "--- System Status ---"
            echo "Hostname: $(hostname)"
            echo "Uptime:   $(uptime -p 2>/dev/null || uptime)"
            echo "Kernel:   $(uname -r)"
            echo "Date:     $(date)"
            echo ""
            ;;
        disk)
            echo ""
            echo "--- Disk Usage ---"
            df -h 2>/dev/null | head -10
            echo ""
            ;;
        users)
            echo ""
            echo "--- Logged-In Users ---"
            who 2>/dev/null || echo "  (unable to determine logged-in users)"
            echo ""
            ;;
        network | net)
            echo ""
            echo "--- Network Info ---"
            if command -v ip &>/dev/null; then
                ip addr show 2>/dev/null | grep "inet " | head -5
            elif command -v ifconfig &>/dev/null; then
                ifconfig 2>/dev/null | grep "inet " | head -5
            else
                echo "  (no network tools available)"
            fi
            echo ""
            ;;
        procs | processes)
            echo ""
            echo "--- Top 5 Processes by Memory ---"
            ps aux --sort=-%mem 2>/dev/null | head -6
            echo ""
            ;;
        help | h | "?")
            echo "Commands: status, disk, users, network, procs, help, quit"
            ;;
        quit | exit | q)
            echo "Goodbye."
            exit 0
            ;;
        "")
            # Empty input, just show prompt again
            ;;
        *)
            echo "Unknown command: '$cmd'. Type 'help' for available commands."
            ;;
    esac
done
