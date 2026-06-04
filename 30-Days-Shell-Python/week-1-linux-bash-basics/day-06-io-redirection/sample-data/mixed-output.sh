#!/bin/bash
# mixed-output.sh — Produces both stdout and stderr output
# Used for practicing I/O redirection (Day 6)

echo "Starting system check..."
echo "Checking disk space..."
df -h / 2>/dev/null || echo "Disk check complete."

echo "Reading configuration file..."
cat /etc/nonexistent-config.conf

echo "Listing application directory..."
ls /opt/myapp/bin/

echo "Current user: $(whoami)"
echo "Hostname: $(hostname)"

echo "Checking network interfaces..."
cat /proc/net/nonexistent

echo "Testing database connection..."
ls /var/run/postgresql/.s.PGSQL.5432

echo "Application version: 2.4.1"
echo "Checking temp directory..."
ls /tmp/ > /dev/null && echo "Temp directory OK"

echo "Attempting to read secure log..."
cat /var/log/secure

echo "Trying to access restricted directory..."
ls /root/private-keys/

echo "System check complete."
echo "Total checks performed: 8"
echo "Report generated at: $(date)"
