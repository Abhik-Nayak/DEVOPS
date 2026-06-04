# Day 8: Conditionals

## Goal
Learn to make decisions in bash scripts using `if/else`, `test` commands, and `case` statements — the foundation of every automation script.

---

## Core Concepts

### How Bash Evaluates Conditions

Bash does not have true/false values like Python or JavaScript. Instead, every command returns an **exit code**: `0` means success (true), and any non-zero value means failure (false). The `if` statement simply checks the exit code of whatever command you give it.

```bash
# Every command returns an exit code
ls /etc/passwd        # exits 0 (success — file exists)
echo $?               # prints 0

ls /nonexistent       # exits 2 (failure — file not found)
echo $?               # prints 2
```

This is the single most important concept in bash conditionals: **0 = true, non-zero = false**. It is the opposite of most programming languages.

### The `test` Command and `[ ]` Syntax

The `test` command evaluates an expression and returns an exit code. The `[ ]` syntax is just a shorthand alias for `test`.

```bash
# These two are identical:
test -f /etc/passwd
[ -f /etc/passwd ]

# Important: spaces inside [ ] are required
[ -f /etc/passwd ]     # correct
[-f /etc/passwd]       # WRONG — will error
```

### `[[ ]]` vs `[ ]`

Bash provides an improved version: `[[ ]]`. It is safer and more powerful.

| Feature | `[ ]` (POSIX) | `[[ ]]` (Bash) |
|---------|---------------|-----------------|
| Word splitting on variables | Yes (bugs if unquoted) | No (safe without quotes) |
| Pattern matching (`*`, `?`) | No | Yes |
| Regex matching (`=~`) | No | Yes |
| `&&` and `||` inside | No (use `-a`, `-o`) | Yes |
| Available in | All shells (sh, dash) | Bash, zsh, ksh |

**Rule of thumb**: Use `[[ ]]` in bash scripts. Use `[ ]` only when writing portable POSIX shell scripts.

```bash
# [[ ]] handles unquoted variables safely
name=""
[[ -z $name ]]    # works fine
[ -z $name ]      # breaks — expands to [ -z ] which is an error
```

---

## Topics to Learn

### 1. `if / elif / else / fi` Syntax

The basic structure:

```bash
if [[ condition ]]; then
    # commands when condition is true
elif [[ another_condition ]]; then
    # commands when another_condition is true
else
    # commands when nothing above matched
fi
```

Simple example:

```bash
#!/bin/bash
read -p "Enter a number: " num

if [[ $num -gt 100 ]]; then
    echo "$num is greater than 100"
elif [[ $num -gt 50 ]]; then
    echo "$num is between 51 and 100"
elif [[ $num -gt 0 ]]; then
    echo "$num is between 1 and 50"
else
    echo "$num is zero or negative"
fi
```

You can also use a command directly (without `[[ ]]`) — the exit code is the condition:

```bash
if grep -q "error" /var/log/syslog; then
    echo "Errors found in syslog"
fi

if ping -c 1 -W 2 google.com &>/dev/null; then
    echo "Internet is reachable"
else
    echo "No internet connection"
fi
```

### 2. String Comparisons

| Operator | Meaning |
|----------|---------|
| `=` or `==` | Strings are equal |
| `!=` | Strings are not equal |
| `-z` | String is empty (zero length) |
| `-n` | String is not empty (non-zero length) |
| `<` | String sorts before (alphabetically) |
| `>` | String sorts after (alphabetically) |

```bash
name="admin"

if [[ $name == "admin" ]]; then
    echo "Welcome, administrator"
fi

if [[ -z $name ]]; then
    echo "Name is empty"
fi

if [[ -n $name ]]; then
    echo "Name is set to: $name"
fi

# Pattern matching (only inside [[ ]])
if [[ $name == a* ]]; then
    echo "Name starts with 'a'"
fi
```

### 3. Number Comparisons

String operators (`==`, `<`, `>`) compare alphabetically. For numbers, use these:

| Operator | Meaning |
|----------|---------|
| `-eq` | Equal |
| `-ne` | Not equal |
| `-gt` | Greater than |
| `-lt` | Less than |
| `-ge` | Greater than or equal |
| `-le` | Less than or equal |

```bash
count=15

if [[ $count -gt 10 ]]; then
    echo "Count exceeds threshold"
fi

if [[ $count -ge 10 ]] && [[ $count -le 20 ]]; then
    echo "Count is between 10 and 20"
fi
```

> **Why not `>` and `<` for numbers?** Inside `[[ ]]`, `>` and `<` do string comparison. `"9" > "10"` is true (alphabetically), but `9 -gt 10` is false (numerically). Always use `-gt`, `-lt`, etc. for numbers.

### 4. File Tests

These are the most useful tests for DevOps scripts:

| Operator | What It Tests |
|----------|--------------|
| `-f FILE` | FILE exists and is a regular file |
| `-d FILE` | FILE exists and is a directory |
| `-e FILE` | FILE exists (any type) |
| `-r FILE` | FILE exists and is readable |
| `-w FILE` | FILE exists and is writable |
| `-x FILE` | FILE exists and is executable |
| `-s FILE` | FILE exists and is not empty (size > 0) |

```bash
config="/etc/app/config.yaml"

if [[ -f $config ]]; then
    echo "Config file found"
else
    echo "ERROR: Config file missing: $config"
    exit 1
fi

if [[ -d /var/log/app ]]; then
    echo "Log directory exists"
fi

if [[ ! -x ./deploy.sh ]]; then
    echo "deploy.sh is not executable, fixing..."
    chmod +x ./deploy.sh
fi

# Check if a file is non-empty
if [[ -s /var/log/errors.log ]]; then
    echo "There are errors to review"
fi
```

### 5. Logical Operators

| Operator | Meaning |
|----------|---------|
| `&&` | AND — both conditions must be true |
| `\|\|` | OR — at least one must be true |
| `!` | NOT — inverts the condition |

```bash
# AND — both must be true
if [[ -f config.yaml ]] && [[ -r config.yaml ]]; then
    echo "Config exists and is readable"
fi

# OR — at least one is true
if [[ -f config.yaml ]] || [[ -f config.json ]]; then
    echo "Found a config file"
fi

# NOT — invert
if [[ ! -d /tmp/build ]]; then
    echo "Build directory does not exist"
    mkdir -p /tmp/build
fi

# Combine inside [[ ]]
if [[ -f config.yaml && -r config.yaml ]]; then
    echo "Config exists and is readable"
fi

if [[ $env == "prod" || $env == "staging" ]]; then
    echo "Deploying to: $env"
fi
```

### 6. `case` Statements

`case` is bash's version of a switch statement. It matches a value against multiple patterns.

```bash
case $variable in
    pattern1)
        # commands
        ;;
    pattern2)
        # commands
        ;;
    pattern3 | pattern4)
        # matches either pattern3 or pattern4
        ;;
    *)
        # default — no other pattern matched
        ;;
esac
```

Practical example:

```bash
#!/bin/bash
read -p "Enter environment (dev/staging/prod): " env

case $env in
    dev)
        echo "Deploying to development"
        server="dev.example.com"
        ;;
    staging)
        echo "Deploying to staging"
        server="staging.example.com"
        ;;
    prod)
        echo "Deploying to production"
        server="prod.example.com"
        read -p "Are you sure? (yes/no): " confirm
        if [[ $confirm != "yes" ]]; then
            echo "Aborted."
            exit 1
        fi
        ;;
    *)
        echo "Unknown environment: $env"
        echo "Usage: choose dev, staging, or prod"
        exit 1
        ;;
esac

echo "Target server: $server"
```

Pattern matching features:

```bash
case $input in
    *.tar.gz)   echo "Gzipped tarball"   ;;
    *.zip)      echo "Zip archive"       ;;
    *.sh)       echo "Shell script"      ;;
    [0-9]*)     echo "Starts with a number" ;;
    "")         echo "Empty input"       ;;
    *)          echo "Unknown format"    ;;
esac
```

### 7. Short-Circuit Evaluation

You can use `&&` and `||` outside of `if` statements for concise one-liners.

```bash
# command && do_this  — runs do_this only if command succeeds
[[ -f config.yaml ]] && echo "Config exists"

# command || do_that  — runs do_that only if command fails
[[ -d /tmp/build ]] || mkdir -p /tmp/build

# Common pattern: check or exit
[[ -f .env ]] || { echo "ERROR: .env file not found"; exit 1; }

# Chain them together
command -v docker &>/dev/null && echo "Docker is installed" || echo "Docker is NOT installed"

# Real-world: ensure a directory exists before writing
[[ -d /var/log/myapp ]] || mkdir -p /var/log/myapp
echo "$(date): started" >> /var/log/myapp/app.log
```

> **Caution**: Do not chain `&&` and `||` together as a replacement for `if/else`. If the `&&` command fails, the `||` command runs too. Use a proper `if` block when the logic is complex.

---

## Hands-On Exercises

### Exercise 1: Check If a File Exists
Write a script that takes a filename as an argument and reports whether it exists, what type it is, and what permissions it has.

```bash
#!/bin/bash
file=$1

if [[ -z $file ]]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

if [[ ! -e $file ]]; then
    echo "'$file' does not exist"
    exit 1
fi

echo "'$file' exists"

if [[ -f $file ]]; then
    echo "  Type: regular file"
elif [[ -d $file ]]; then
    echo "  Type: directory"
elif [[ -L $file ]]; then
    echo "  Type: symbolic link"
fi

[[ -r $file ]] && echo "  Readable: yes" || echo "  Readable: no"
[[ -w $file ]] && echo "  Writable: yes" || echo "  Writable: no"
[[ -x $file ]] && echo "  Executable: yes" || echo "  Executable: no"
[[ -s $file ]] && echo "  Non-empty: yes" || echo "  Non-empty: no (empty file)"
```

---

### Exercise 2: Number Range Validator
Write a script that takes a number and classifies it into ranges.

```bash
#!/bin/bash
read -p "Enter a number (1-100): " num

# Check if input is a number
if [[ ! $num =~ ^[0-9]+$ ]]; then
    echo "ERROR: '$num' is not a valid number"
    exit 1
fi

if [[ $num -ge 90 ]]; then
    echo "Grade: A"
elif [[ $num -ge 80 ]]; then
    echo "Grade: B"
elif [[ $num -ge 70 ]]; then
    echo "Grade: C"
elif [[ $num -ge 60 ]]; then
    echo "Grade: D"
else
    echo "Grade: F"
fi
```

---

### Exercise 3: User Validator
Write a script that validates a username input: must be non-empty, between 3 and 20 characters, and contain only lowercase letters and numbers.

```bash
#!/bin/bash
read -p "Enter username: " username

if [[ -z $username ]]; then
    echo "FAIL: Username cannot be empty"
    exit 1
fi

length=${#username}

if [[ $length -lt 3 ]]; then
    echo "FAIL: Username too short (minimum 3 characters, got $length)"
    exit 1
fi

if [[ $length -gt 20 ]]; then
    echo "FAIL: Username too long (maximum 20 characters, got $length)"
    exit 1
fi

if [[ ! $username =~ ^[a-z0-9]+$ ]]; then
    echo "FAIL: Username can only contain lowercase letters and numbers"
    exit 1
fi

echo "OK: '$username' is a valid username"
```

---

### Exercise 4: Environment Switcher with `case`
Write a script that accepts an environment name and prints the corresponding configuration.

```bash
#!/bin/bash
env=${1:-""}

case $env in
    dev | development)
        echo "Environment: Development"
        echo "  Database: localhost:5432/app_dev"
        echo "  Debug: enabled"
        echo "  Log level: debug"
        ;;
    staging | stg)
        echo "Environment: Staging"
        echo "  Database: staging-db.internal:5432/app_staging"
        echo "  Debug: disabled"
        echo "  Log level: info"
        ;;
    prod | production)
        echo "Environment: Production"
        echo "  Database: prod-db.internal:5432/app_prod"
        echo "  Debug: disabled"
        echo "  Log level: warn"
        ;;
    "")
        echo "ERROR: No environment specified"
        echo "Usage: $0 <dev|staging|prod>"
        exit 1
        ;;
    *)
        echo "ERROR: Unknown environment '$env'"
        echo "Valid options: dev, staging, prod"
        exit 1
        ;;
esac
```

---

### Exercise 5: Service Checker
Write a script that checks whether common services are running.

```bash
#!/bin/bash
echo "=== Service Status Check ==="
echo ""

services=("nginx" "docker" "postgresql" "sshd")

for svc in "${services[@]}"; do
    if command -v systemctl &>/dev/null; then
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            echo "[RUNNING] $svc"
        else
            echo "[STOPPED] $svc"
        fi
    else
        if pgrep -x "$svc" &>/dev/null; then
            echo "[RUNNING] $svc"
        else
            echo "[STOPPED] $svc"
        fi
    fi
done
```

---

### Exercise 6: Disk Space Warning
Write a script that checks disk usage and warns if any partition is over 80% full.

```bash
#!/bin/bash
threshold=80

echo "Checking disk usage (threshold: ${threshold}%)..."
echo ""

warning_found=false

while read -r usage mount; do
    usage_num=${usage%\%}
    if [[ $usage_num -ge $threshold ]]; then
        echo "WARNING: $mount is at ${usage}% capacity"
        warning_found=true
    else
        echo "OK: $mount is at ${usage}%"
    fi
done < <(df -h --output=pcent,target 2>/dev/null | tail -n +2 | sed 's/^ *//')

if [[ $warning_found == false ]]; then
    echo ""
    echo "All partitions are below ${threshold}%."
fi
```

---

### Exercise 7: Script Argument Validator
Write a script that validates its own arguments — checks that the right number and type were passed.

```bash
#!/bin/bash

# Usage: ./script.sh <action> <target> [--force]
# Example: ./script.sh deploy staging --force

if [[ $# -lt 2 ]]; then
    echo "ERROR: Expected at least 2 arguments, got $#"
    echo "Usage: $0 <action> <target> [--force]"
    exit 1
fi

action=$1
target=$2
force=${3:-""}

# Validate action
case $action in
    deploy|rollback|restart)
        echo "Action: $action"
        ;;
    *)
        echo "ERROR: Invalid action '$action'"
        echo "Valid actions: deploy, rollback, restart"
        exit 1
        ;;
esac

# Validate target
if [[ $target != "dev" && $target != "staging" && $target != "prod" ]]; then
    echo "ERROR: Invalid target '$target'"
    echo "Valid targets: dev, staging, prod"
    exit 1
fi

echo "Target: $target"

# Check for force flag
if [[ $force == "--force" ]]; then
    echo "Force mode: enabled"
elif [[ -n $force ]]; then
    echo "ERROR: Unknown flag '$force'"
    exit 1
fi

# Safety check for production
if [[ $target == "prod" && $force != "--force" ]]; then
    echo ""
    echo "WARNING: Production deployment requires --force flag"
    echo "Run: $0 $action prod --force"
    exit 1
fi

echo ""
echo "Proceeding with: $action -> $target"
```

---

### Exercise 8: HTTP Status Code Classifier
Write a script that takes an HTTP status code and explains it using `case` with pattern matching.

```bash
#!/bin/bash
code=${1:-""}

if [[ -z $code ]]; then
    echo "Usage: $0 <http-status-code>"
    exit 1
fi

if [[ ! $code =~ ^[0-9]{3}$ ]]; then
    echo "ERROR: '$code' is not a valid HTTP status code"
    exit 1
fi

case $code in
    200) echo "$code OK — Request succeeded" ;;
    201) echo "$code Created — Resource created" ;;
    204) echo "$code No Content — Success, no response body" ;;
    301) echo "$code Moved Permanently — Resource relocated" ;;
    302) echo "$code Found — Temporary redirect" ;;
    304) echo "$code Not Modified — Use cached version" ;;
    400) echo "$code Bad Request — Invalid request syntax" ;;
    401) echo "$code Unauthorized — Authentication required" ;;
    403) echo "$code Forbidden — Access denied" ;;
    404) echo "$code Not Found — Resource does not exist" ;;
    405) echo "$code Method Not Allowed" ;;
    429) echo "$code Too Many Requests — Rate limited" ;;
    500) echo "$code Internal Server Error — Server-side failure" ;;
    502) echo "$code Bad Gateway — Upstream server error" ;;
    503) echo "$code Service Unavailable — Server overloaded or down" ;;
    504) echo "$code Gateway Timeout — Upstream server timeout" ;;
    1??) echo "$code — Informational response" ;;
    2??) echo "$code — Success (unrecognized code)" ;;
    3??) echo "$code — Redirection (unrecognized code)" ;;
    4??) echo "$code — Client error (unrecognized code)" ;;
    5??) echo "$code — Server error (unrecognized code)" ;;
    *)   echo "$code — Unknown status code range" ;;
esac
```

---

### Exercise 9: Pre-Flight Checks Script
Write a script that performs multiple pre-flight checks before allowing an operation to proceed. All checks must pass.

```bash
#!/bin/bash
echo "=== Pre-Flight Checks ==="
echo ""

errors=0

# Check 1: Required commands exist
for cmd in git curl docker; do
    if command -v "$cmd" &>/dev/null; then
        echo "[PASS] $cmd is installed"
    else
        echo "[FAIL] $cmd is not installed"
        ((errors++))
    fi
done

# Check 2: Required files exist
for file in Dockerfile docker-compose.yml; do
    if [[ -f $file ]]; then
        echo "[PASS] $file exists"
    else
        echo "[FAIL] $file is missing"
        ((errors++))
    fi
done

# Check 3: Environment variable is set
if [[ -n ${APP_ENV:-} ]]; then
    echo "[PASS] APP_ENV is set to '$APP_ENV'"
else
    echo "[FAIL] APP_ENV is not set"
    ((errors++))
fi

# Check 4: Internet connectivity
if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
    echo "[PASS] Internet is reachable"
else
    echo "[FAIL] No internet connectivity"
    ((errors++))
fi

echo ""
if [[ $errors -eq 0 ]]; then
    echo "All checks passed. Ready to proceed."
else
    echo "$errors check(s) failed. Fix the issues above before proceeding."
    exit 1
fi
```

---

### Exercise 10: Challenge — Deploy Validator

Build a "deploy validator" script that checks **all** of the following pre-conditions before allowing a deployment:

1. The current git working directory is clean (no uncommitted changes)
2. You are on the correct branch (`main` or `master`)
3. A `.env` file exists and is non-empty
4. A `Dockerfile` exists
5. The test suite passes (simulate with `exit 0`)
6. The target environment is valid (passed as an argument)

The script should report each check as PASS or FAIL, and only allow the deployment if all checks pass.

<details>
<summary>Click to reveal solution</summary>

```bash
#!/bin/bash
# deploy-validator.sh — Checks all pre-conditions before deploying

echo "============================================"
echo "  DEPLOYMENT VALIDATOR"
echo "============================================"
echo ""

target_env=${1:-""}
errors=0
checks=0

pass() {
    ((checks++))
    echo "[PASS] $1"
}

fail() {
    ((checks++))
    ((errors++))
    echo "[FAIL] $1"
}

# --- Check 1: Target environment argument ---
if [[ -z $target_env ]]; then
    fail "No target environment specified (usage: $0 <dev|staging|prod>)"
else
    case $target_env in
        dev|staging|prod)
            pass "Target environment: $target_env"
            ;;
        *)
            fail "Invalid environment: '$target_env' (must be dev, staging, or prod)"
            ;;
    esac
fi

# --- Check 2: Inside a git repository ---
if git rev-parse --is-inside-work-tree &>/dev/null; then
    pass "Inside a git repository"
else
    fail "Not inside a git repository"
    echo ""
    echo "$errors check(s) failed out of $checks. Deployment blocked."
    exit 1
fi

# --- Check 3: Git working directory is clean ---
if [[ -z $(git status --porcelain 2>/dev/null) ]]; then
    pass "Git working directory is clean"
else
    fail "Git working directory has uncommitted changes"
fi

# --- Check 4: On the correct branch ---
current_branch=$(git branch --show-current 2>/dev/null)
if [[ $current_branch == "main" || $current_branch == "master" ]]; then
    pass "On branch: $current_branch"
else
    fail "On branch '$current_branch' — must be on 'main' or 'master'"
fi

# --- Check 5: .env file exists and is non-empty ---
if [[ -f .env ]]; then
    if [[ -s .env ]]; then
        pass ".env file exists and is non-empty"
    else
        fail ".env file exists but is empty"
    fi
else
    fail ".env file not found"
fi

# --- Check 6: Dockerfile exists ---
if [[ -f Dockerfile ]]; then
    pass "Dockerfile exists"
else
    fail "Dockerfile not found"
fi

# --- Check 7: Tests pass (simulated) ---
echo ""
echo "Running tests..."
# Simulate test run — replace with your actual test command
# Example: npm test, pytest, go test ./...
sleep 1
test_exit_code=0  # simulate passing tests

if [[ $test_exit_code -eq 0 ]]; then
    pass "Test suite passed"
else
    fail "Test suite failed (exit code: $test_exit_code)"
fi

# --- Summary ---
echo ""
echo "============================================"
echo "  RESULTS: $((checks - errors))/$checks checks passed"
echo "============================================"

if [[ $errors -eq 0 ]]; then
    echo ""
    echo "All checks passed. Deployment to '$target_env' is authorized."
    echo ""
    if [[ $target_env == "prod" ]]; then
        echo "WARNING: You are deploying to PRODUCTION."
        read -p "Type 'yes' to confirm: " confirm
        if [[ $confirm != "yes" ]]; then
            echo "Deployment aborted."
            exit 1
        fi
    fi
    echo "Deploying to $target_env..."
else
    echo ""
    echo "$errors check(s) failed. Deployment BLOCKED."
    echo "Fix the issues above and try again."
    exit 1
fi
```

</details>

---

## Quick Reference

| Syntax | What It Does |
|--------|-------------|
| `if [[ condition ]]; then ... fi` | Basic conditional |
| `if ... elif ... else ... fi` | Multi-branch conditional |
| `[[ -f FILE ]]` | True if FILE exists and is a regular file |
| `[[ -d DIR ]]` | True if DIR exists and is a directory |
| `[[ -e PATH ]]` | True if PATH exists (any type) |
| `[[ -r FILE ]]` | True if FILE is readable |
| `[[ -w FILE ]]` | True if FILE is writable |
| `[[ -x FILE ]]` | True if FILE is executable |
| `[[ -s FILE ]]` | True if FILE is non-empty |
| `[[ -z $VAR ]]` | True if VAR is empty |
| `[[ -n $VAR ]]` | True if VAR is non-empty |
| `[[ $a == $b ]]` | String equality |
| `[[ $a != $b ]]` | String inequality |
| `[[ $n -eq $m ]]` | Numeric equality |
| `[[ $n -gt $m ]]` | Numeric greater than |
| `[[ $n -lt $m ]]` | Numeric less than |
| `[[ cond1 && cond2 ]]` | Logical AND |
| `[[ cond1 \|\| cond2 ]]` | Logical OR |
| `[[ ! cond ]]` | Logical NOT |
| `case $var in pat) ... ;; esac` | Pattern matching |
| `cmd && do_this` | Run do_this if cmd succeeds |
| `cmd \|\| do_that` | Run do_that if cmd fails |
| `$?` | Exit code of the last command |

---

## Checklist

- [ ] I understand that bash uses exit codes for conditions (0 = true, non-zero = false)
- [ ] I can write `if / elif / else / fi` blocks
- [ ] I know the difference between `[ ]` and `[[ ]]` and when to use each
- [ ] I can compare strings with `==`, `!=`, `-z`, and `-n`
- [ ] I can compare numbers with `-eq`, `-ne`, `-gt`, `-lt`, `-ge`, `-le`
- [ ] I can test files with `-f`, `-d`, `-e`, `-r`, `-w`, `-x`, `-s`
- [ ] I can combine conditions with `&&`, `||`, and `!`
- [ ] I can write `case` statements with pattern matching
- [ ] I can use short-circuit evaluation (`&&` and `||`) for concise checks
- [ ] I have built a multi-check validation script

---

> **Tomorrow (Day 9)**: Loops — for, while, until, and iterating over files, lines, and command output.
