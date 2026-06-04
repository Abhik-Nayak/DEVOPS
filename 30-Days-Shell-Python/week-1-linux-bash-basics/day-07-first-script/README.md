# Day 7: Your First Shell Script

## Goal
Transition from running individual commands to writing reusable shell scripts with variables, arguments, user input, and exit codes.

---

## Core Concepts

### What Is a Shell Script?

A shell script is just a text file containing a sequence of commands. Instead of typing commands one by one, you put them in a file and run that file. That is it — no compilation, no special tooling. If you can type it in a terminal, you can put it in a script.

### The Shebang Line

The very first line of a script tells the system which interpreter to use:

```bash
#!/bin/bash
```

This is called the **shebang** (or hashbang). Without it, the system does not know which shell to use and may default to something unexpected.

| Shebang | Interpreter |
|---------|-------------|
| `#!/bin/bash` | Bash (most common) |
| `#!/bin/sh` | POSIX shell (more portable, fewer features) |
| `#!/usr/bin/env bash` | Finds bash in PATH (portable across systems) |
| `#!/usr/bin/env python3` | Python scripts use this pattern too |

### Making Scripts Executable

A script file needs execute permission before you can run it directly:

```bash
chmod +x myscript.sh       # Add execute permission
./myscript.sh              # Run it
```

Without `chmod +x`, you would have to run it as:
```bash
bash myscript.sh           # Works but not the standard way
```

### How Scripts Run

When you execute `./myscript.sh`, the system:
1. Reads the shebang line to find the interpreter (`/bin/bash`)
2. Starts a **new shell process** (a child of your current shell)
3. Runs every command in the file, top to bottom
4. Exits when it reaches the end or hits an `exit` command
5. Returns an exit code to the parent shell

> **Key point**: Scripts run in a new process. Variables set inside a script do not affect your current terminal session.

---

## Topics to Learn

### 1. Shebang and Script Structure

Every script follows this basic structure:

```bash
#!/bin/bash
# Description: What this script does
# Author: Your name
# Date: 2024-01-15

# Your commands go here
echo "Hello from a script!"
```

**Creating and running your first script:**
```bash
# Create the file
cat > hello.sh << 'EOF'
#!/bin/bash
echo "Hello, World!"
EOF

# Make it executable
chmod +x hello.sh

# Run it
./hello.sh
```

### 2. Variables -- Declaring, Using, and Quoting

Variables store values for reuse. No spaces around the `=` sign.

```bash
# Declaring variables (NO spaces around =)
NAME="Abhik"
AGE=25
CITY="New York"

# Using variables — prefix with $
echo "Name: $NAME"
echo "Age: $AGE"

# Curly braces — needed when variable is adjacent to other text
FILE="report"
echo "${FILE}_2024.txt"       # report_2024.txt
echo "$FILE_2024.txt"         # WRONG — looks for variable $FILE_2024

# Quoting matters
GREETING="Hello World"
echo $GREETING                # Works, but unsafe with special characters
echo "$GREETING"              # CORRECT — always quote variables
echo '$GREETING'              # Prints literal $GREETING (single quotes = no expansion)
```

**Rules of thumb:**
| Syntax | Behavior |
|--------|----------|
| `$VAR` | Expands the variable |
| `"$VAR"` | Expands the variable, preserves spaces (use this) |
| `'$VAR'` | Literal string, no expansion |
| `${VAR}` | Explicit boundary for variable name |
| `${VAR:-default}` | Use "default" if VAR is unset |

### 3. Special Variables

Bash provides built-in variables that give you information about the script and its arguments:

```bash
#!/bin/bash
echo "Script name:       $0"
echo "First argument:    $1"
echo "Second argument:   $2"
echo "Number of args:    $#"
echo "All args:          $@"
echo "Exit code of last command: $?"
echo "Process ID:        $$"
```

| Variable | Meaning |
|----------|---------|
| `$0` | Name of the script |
| `$1`, `$2`, ... | Positional arguments (1st, 2nd, ...) |
| `$#` | Number of arguments passed |
| `$@` | All arguments as separate words |
| `$*` | All arguments as a single string |
| `$?` | Exit code of the last command (0 = success) |
| `$$` | Process ID of the current script |
| `$!` | Process ID of the last background command |

### 4. Reading User Input

The `read` command pauses the script and waits for the user to type something:

```bash
# Basic read
echo "What is your name?"
read NAME
echo "Hello, $NAME!"

# Prompt on the same line with -p
read -p "Enter your age: " AGE
echo "You are $AGE years old."

# Silent input with -s (for passwords)
read -s -p "Enter password: " PASSWORD
echo ""   # Newline after silent input
echo "Password received (${#PASSWORD} characters)."

# Read with a timeout (-t seconds)
read -t 5 -p "Quick! Enter a number: " NUM

# Read multiple values
read -p "Enter first and last name: " FIRST LAST
echo "First: $FIRST, Last: $LAST"
```

### 5. Command Substitution

Capture the output of a command into a variable:

```bash
# Modern syntax (preferred)
TODAY=$(date +%Y-%m-%d)
HOST=$(hostname)
USER_COUNT=$(who | wc -l)

echo "Date: $TODAY"
echo "Host: $HOST"
echo "Users logged in: $USER_COUNT"

# Backtick syntax (older, avoid in new scripts)
TODAY=`date +%Y-%m-%d`

# Nested command substitution (only works with $() syntax)
echo "Config backup: $(basename $(pwd))_config_$(date +%s).tar.gz"
```

### 6. Exit Codes

Every command returns an exit code. `0` means success, anything else means failure.

```bash
# Check exit code of the last command
ls /etc/passwd
echo "Exit code: $?"     # 0 (success)

ls /nonexistent
echo "Exit code: $?"     # 2 (no such file)

# Set your own exit code in scripts
#!/bin/bash
if [ -f "$1" ]; then
    echo "File exists: $1"
    exit 0               # Success
else
    echo "File not found: $1"
    exit 1               # Failure
fi
```

**Common exit codes:**
| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | General error |
| `2` | Misuse of command (bad arguments) |
| `126` | Command found but not executable |
| `127` | Command not found |
| `130` | Script terminated by Ctrl+C |

### 7. Simple Arithmetic

Bash can do integer math (no decimals):

```bash
# Double parentheses (preferred)
A=10
B=3
echo "Sum:        $(( A + B ))"       # 13
echo "Difference: $(( A - B ))"       # 7
echo "Product:    $(( A * B ))"       # 30
echo "Division:   $(( A / B ))"       # 3 (integer division)
echo "Remainder:  $(( A % B ))"       # 1
echo "Power:      $(( A ** 2 ))"      # 100

# Increment and decrement
COUNT=0
(( COUNT++ ))
echo "Count: $COUNT"                   # 1

# Using expr (older method)
RESULT=$(expr 10 + 5)
echo "Result: $RESULT"                 # 15

# For floating point, use bc
echo "scale=2; 10 / 3" | bc           # 3.33
```

---

## Hands-On Exercises

### Setup

Create a working directory for your scripts:

```bash
mkdir -p ~/day7-scripts
cd ~/day7-scripts
```

You can also look at the sample scripts in the `scripts/` directory of this lesson for reference.

---

### Exercise 1: Hello World Script

Write a script called `hello.sh` that prints "Hello, World!" to the terminal.

```bash
#!/bin/bash
# My first shell script
echo "Hello, World!"
```

```bash
chmod +x hello.sh
./hello.sh
```

Expected output:
```
Hello, World!
```

---

### Exercise 2: Personalized Greeting

Write a script called `greet.sh` that takes a name as an argument and prints a greeting. If no name is given, it should print a usage message.

```bash
#!/bin/bash
# Greet a user by name

if [ $# -eq 0 ]; then
    echo "Usage: $0 <name>"
    exit 1
fi

echo "Hello, $1! Welcome to Day 7."
echo "This script is: $0"
echo "You provided $# argument(s)."
```

```bash
chmod +x greet.sh
./greet.sh Abhik
./greet.sh          # Should show usage message
```

---

### Exercise 3: Interactive Script

Write a script called `interview.sh` that asks the user for their name, age, and favorite language, then prints a summary.

```bash
#!/bin/bash
# Interactive interview script

read -p "What is your name? " NAME
read -p "How old are you? " AGE
read -p "Favorite programming language? " LANG

echo ""
echo "--- Profile ---"
echo "Name:     $NAME"
echo "Age:      $AGE"
echo "Language: $LANG"
echo "---------------"
```

---

### Exercise 4: Variable Practice

Write a script called `vars.sh` that demonstrates different types of variable usage: regular variables, curly braces, default values, and command substitution.

```bash
#!/bin/bash
# Variable practice

# Regular variables
APP="my-web-app"
VERSION="2.1.0"
ENV="production"

# Curly braces for clarity
echo "Deploying ${APP} version ${VERSION} to ${ENV}"
echo "Artifact: ${APP}-${VERSION}.tar.gz"

# Default values
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
echo "Database: $DB_HOST:$DB_PORT"

# Command substitution
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CURRENT_USER=$(whoami)
WORKING_DIR=$(pwd)

echo "Deployed by $CURRENT_USER at $TIMESTAMP"
echo "Working directory: $WORKING_DIR"
```

---

### Exercise 5: Simple Calculator

Write a script called `calc.sh` that takes two numbers and an operator as arguments and prints the result.

```bash
#!/bin/bash
# Simple calculator

if [ $# -ne 3 ]; then
    echo "Usage: $0 <number> <operator> <number>"
    echo "Operators: + - x / %"
    echo "Example: $0 10 + 5"
    exit 1
fi

NUM1=$1
OP=$2
NUM2=$3

case $OP in
    +) RESULT=$(( NUM1 + NUM2 )) ;;
    -) RESULT=$(( NUM1 - NUM2 )) ;;
    x) RESULT=$(( NUM1 * NUM2 )) ;;
    /) 
        if [ "$NUM2" -eq 0 ]; then
            echo "Error: Division by zero"
            exit 1
        fi
        RESULT=$(( NUM1 / NUM2 ))
        ;;
    %) RESULT=$(( NUM1 % NUM2 )) ;;
    *) 
        echo "Unknown operator: $OP"
        exit 1
        ;;
esac

echo "$NUM1 $OP $NUM2 = $RESULT"
```

```bash
chmod +x calc.sh
./calc.sh 10 + 5      # 15
./calc.sh 20 - 8      # 12
./calc.sh 7 x 6       # 42
./calc.sh 15 / 4      # 3
./calc.sh 15 % 4      # 3
```

> Note: We use `x` instead of `*` for multiplication because `*` is a glob character in the shell.

---

### Exercise 6: File Backup Script

Write a script called `backup.sh` that takes a filename as an argument, creates a timestamped backup copy, and reports what it did.

```bash
#!/bin/bash
# Create a timestamped backup of a file

if [ $# -eq 0 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

SOURCE=$1

if [ ! -f "$SOURCE" ]; then
    echo "Error: File '$SOURCE' not found."
    exit 1
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP="${SOURCE}.backup_${TIMESTAMP}"

cp "$SOURCE" "$BACKUP"

if [ $? -eq 0 ]; then
    echo "Backup created successfully."
    echo "  Source: $SOURCE ($(wc -c < "$SOURCE") bytes)"
    echo "  Backup: $BACKUP"
else
    echo "Error: Backup failed."
    exit 1
fi
```

```bash
chmod +x backup.sh
echo "important data" > testfile.txt
./backup.sh testfile.txt
ls -la testfile*
```

---

### Exercise 7: Argument Printer

Write a script called `args.sh` that prints detailed information about all the arguments it receives.

```bash
#!/bin/bash
# Print detailed info about all arguments

echo "=== Argument Report ==="
echo "Script name: $0"
echo "Number of arguments: $#"
echo "All arguments: $@"
echo "Process ID: $$"
echo ""

if [ $# -eq 0 ]; then
    echo "No arguments provided."
    exit 0
fi

COUNT=1
for ARG in "$@"; do
    echo "  Arg $COUNT: $ARG"
    COUNT=$(( COUNT + 1 ))
done

echo ""
echo "=== Done ==="
```

```bash
chmod +x args.sh
./args.sh
./args.sh hello world
./args.sh "first arg" second "third arg"
```

---

### Exercise 8: Password Prompt

Write a script called `secret.sh` that asks for a username and password (hidden), then checks them against hardcoded values.

```bash
#!/bin/bash
# Simple password prompt demo

VALID_USER="admin"
VALID_PASS="secret123"

read -p "Username: " USERNAME
read -s -p "Password: " PASSWORD
echo ""

if [ "$USERNAME" = "$VALID_USER" ] && [ "$PASSWORD" = "$VALID_PASS" ]; then
    echo "Access granted. Welcome, $USERNAME."
    exit 0
else
    echo "Access denied. Invalid credentials."
    exit 1
fi
```

---

### Exercise 9: System Info Script

Write a script called `sysinfo.sh` that gathers and displays key system information in a formatted report.

```bash
#!/bin/bash
# System information report

echo "=============================="
echo "   SYSTEM INFORMATION REPORT"
echo "=============================="
echo ""
echo "Hostname:      $(hostname)"
echo "User:          $(whoami)"
echo "Date:          $(date)"
echo "Uptime:       $(uptime -p 2>/dev/null || uptime)"
echo ""
echo "--- Operating System ---"
if [ -f /etc/os-release ]; then
    grep PRETTY_NAME /etc/os-release | cut -d '"' -f 2
else
    uname -s -r
fi
echo "Kernel:        $(uname -r)"
echo "Architecture:  $(uname -m)"
echo ""
echo "--- Disk Usage ---"
df -h / | tail -1 | awk '{print "  Total: " $2 "  Used: " $3 "  Free: " $4 "  Use%: " $5}'
echo ""
echo "--- Memory ---"
free -h 2>/dev/null | grep Mem | awk '{print "  Total: " $2 "  Used: " $3 "  Free: " $4}'
echo ""
echo "--- Top 5 Processes by Memory ---"
ps aux --sort=-%mem 2>/dev/null | head -6 | awk '{printf "  %-10s %5s %5s %s\n", $1, $3, $4, $11}'
echo ""
echo "=============================="
echo "   Report generated: $(date +%Y-%m-%d\ %H:%M:%S)"
echo "=============================="
```

---

### Exercise 10: Challenge -- Server Health Check Script

Build a comprehensive health check script called `healthcheck.sh` that checks disk usage, memory, uptime, and running services, then outputs a report with PASS/WARN/FAIL status for each check.

Requirements:
- Check if disk usage is under 80%
- Check if memory usage is under 90%
- Check if system uptime is more than 0 (system is up)
- Check if key processes are running (pass process names as arguments, or default to checking `sshd`)
- Print a summary at the end with the total PASS/FAIL count
- Exit with code 0 if all checks pass, exit with code 1 if any check fails

<details>
<summary>Click to reveal solution</summary>

```bash
#!/bin/bash
# Server Health Check Script
# Usage: ./healthcheck.sh [process1 process2 ...]

PASS=0
FAIL=0
WARN=0

# Thresholds
DISK_WARN=70
DISK_CRIT=80
MEM_WARN=80
MEM_CRIT=90

echo "======================================"
echo "   SERVER HEALTH CHECK REPORT"
echo "======================================"
echo "  Host:    $(hostname)"
echo "  Date:    $(date)"
echo "  User:    $(whoami)"
echo "======================================"
echo ""

# --- Check 1: Disk Usage ---
echo "--- Disk Usage ---"
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
if [ "$DISK_USAGE" -lt "$DISK_WARN" ]; then
    echo "  [PASS] Root disk usage: ${DISK_USAGE}% (threshold: ${DISK_CRIT}%)"
    (( PASS++ ))
elif [ "$DISK_USAGE" -lt "$DISK_CRIT" ]; then
    echo "  [WARN] Root disk usage: ${DISK_USAGE}% (warning threshold: ${DISK_WARN}%)"
    (( WARN++ ))
else
    echo "  [FAIL] Root disk usage: ${DISK_USAGE}% (critical threshold: ${DISK_CRIT}%)"
    (( FAIL++ ))
fi
echo ""

# --- Check 2: Memory Usage ---
echo "--- Memory Usage ---"
if command -v free > /dev/null 2>&1; then
    MEM_TOTAL=$(free | grep Mem | awk '{print $2}')
    MEM_USED=$(free | grep Mem | awk '{print $3}')
    MEM_PERCENT=$(( MEM_USED * 100 / MEM_TOTAL ))
    if [ "$MEM_PERCENT" -lt "$MEM_WARN" ]; then
        echo "  [PASS] Memory usage: ${MEM_PERCENT}% (threshold: ${MEM_CRIT}%)"
        (( PASS++ ))
    elif [ "$MEM_PERCENT" -lt "$MEM_CRIT" ]; then
        echo "  [WARN] Memory usage: ${MEM_PERCENT}% (warning threshold: ${MEM_WARN}%)"
        (( WARN++ ))
    else
        echo "  [FAIL] Memory usage: ${MEM_PERCENT}% (critical threshold: ${MEM_CRIT}%)"
        (( FAIL++ ))
    fi
else
    echo "  [WARN] 'free' command not available, skipping memory check."
    (( WARN++ ))
fi
echo ""

# --- Check 3: Uptime ---
echo "--- System Uptime ---"
UPTIME_SECONDS=$(cat /proc/uptime 2>/dev/null | cut -d '.' -f 1)
if [ -n "$UPTIME_SECONDS" ] && [ "$UPTIME_SECONDS" -gt 0 ]; then
    DAYS=$(( UPTIME_SECONDS / 86400 ))
    HOURS=$(( (UPTIME_SECONDS % 86400) / 3600 ))
    MINS=$(( (UPTIME_SECONDS % 3600) / 60 ))
    echo "  [PASS] System up for ${DAYS}d ${HOURS}h ${MINS}m"
    (( PASS++ ))
else
    echo "  [WARN] Could not determine uptime."
    (( WARN++ ))
fi
echo ""

# --- Check 4: Process Checks ---
echo "--- Process Checks ---"
if [ $# -gt 0 ]; then
    PROCS="$@"
else
    PROCS="sshd"
fi

for PROC in $PROCS; do
    if pgrep -x "$PROC" > /dev/null 2>&1; then
        echo "  [PASS] Process '$PROC' is running."
        (( PASS++ ))
    else
        echo "  [FAIL] Process '$PROC' is NOT running."
        (( FAIL++ ))
    fi
done
echo ""

# --- Summary ---
TOTAL=$(( PASS + FAIL + WARN ))
echo "======================================"
echo "   SUMMARY"
echo "======================================"
echo "  Total checks: $TOTAL"
echo "  Passed:       $PASS"
echo "  Warnings:     $WARN"
echo "  Failed:       $FAIL"
echo "======================================"

if [ "$FAIL" -gt 0 ]; then
    echo "  Overall: FAIL"
    exit 1
else
    echo "  Overall: PASS"
    exit 0
fi
```

</details>

---

## Quick Reference

| Concept | Syntax | Example |
|---------|--------|---------|
| Shebang | `#!/bin/bash` | First line of every script |
| Make executable | `chmod +x script.sh` | Then run with `./script.sh` |
| Variable assign | `VAR="value"` | No spaces around `=` |
| Variable use | `"$VAR"` or `"${VAR}"` | Always quote in double quotes |
| Default value | `${VAR:-default}` | Use "default" if VAR is unset |
| Argument 1 | `$1` | First argument passed to script |
| All arguments | `$@` | All arguments as separate words |
| Argument count | `$#` | Number of arguments |
| Last exit code | `$?` | 0 = success, non-zero = error |
| Script name | `$0` | Name of the running script |
| Process ID | `$$` | PID of the running script |
| Read input | `read -p "Prompt: " VAR` | Prompt and store in VAR |
| Silent input | `read -s -p "Pass: " VAR` | Hidden input (passwords) |
| Command sub | `VAR=$(command)` | Capture command output |
| Arithmetic | `$(( A + B ))` | Integer math |
| Exit script | `exit 0` or `exit 1` | Set exit code |

---

## Checklist

- [ ] I can create a script file with a proper shebang line
- [ ] I can make a script executable with `chmod +x` and run it with `./`
- [ ] I can declare and use variables (with proper quoting)
- [ ] I know the difference between `$VAR`, `"$VAR"`, and `'$VAR'`
- [ ] I can use `${VAR}` for variable boundaries and `${VAR:-default}` for defaults
- [ ] I can access script arguments with `$1`, `$2`, `$#`, and `$@`
- [ ] I can read user input with `read` and `read -p`
- [ ] I can capture command output with `$(command)` substitution
- [ ] I can use `$?` to check if the last command succeeded or failed
- [ ] I can set exit codes with `exit 0` and `exit 1`
- [ ] I can do basic arithmetic with `$(( ))`
- [ ] I have written a practical script (system info or health check)

---

> **Next Week (Day 8)**: Conditionals -- if/else, test commands, and making scripts that make decisions.
