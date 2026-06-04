#!/bin/bash
# =============================================================
# 02-variables.sh -- Variable declaration, usage, and quoting
# Demonstrates: assignment, $VAR, "$VAR", '${VAR}', defaults
# =============================================================

echo "=== Basic Variable Assignment ==="
# No spaces around the = sign
NAME="Abhik"
CITY="Mumbai"
YEAR=2024

echo "Name: $NAME"
echo "City: $CITY"
echo "Year: $YEAR"

echo ""
echo "=== Curly Braces for Boundaries ==="
APP="server"
echo "Without braces: $APP_log.txt"      # WRONG -- looks for $APP_log
echo "With braces:    ${APP}_log.txt"     # CORRECT -- server_log.txt

echo ""
echo "=== Quoting Differences ==="
GREETING="Hello World"
echo "Double quotes: \"$GREETING\""       # Expands the variable
echo 'Single quotes: $GREETING'           # Literal string, no expansion

echo ""
echo "=== Spaces in Variables ==="
DIR_NAME="My Project Files"
echo Without quotes: $DIR_NAME            # Unsafe -- word splitting happens
echo "With quotes:    $DIR_NAME"          # Safe -- treated as one string

echo ""
echo "=== Default Values ==="
# Use a default if the variable is not set
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
echo "Database host: $DB_HOST"
echo "Database port: $DB_PORT"

echo ""
echo "=== Reassigning Variables ==="
COUNT=1
echo "Count is: $COUNT"
COUNT=2
echo "Count is now: $COUNT"

echo ""
echo "Done! Variables are straightforward once you remember: no spaces around = and always quote."
