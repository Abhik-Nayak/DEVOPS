# Day 6: I/O Redirection

## Goal
Master I/O redirection and pipes to control where command input comes from and where output goes — the glue that makes Linux command-line pipelines possible.

---

## Core Concepts

Every process in Linux has three standard streams open by default:

| Stream | Name | File Descriptor | Default Destination |
|--------|------|-----------------|---------------------|
| Standard Input | stdin | 0 | Keyboard |
| Standard Output | stdout | 1 | Terminal screen |
| Standard Error | stderr | 2 | Terminal screen |

**Why two output streams?** Normal output (results) and error messages are kept separate so you can handle them independently. A script might save results to a file while still printing errors to the screen, or suppress errors entirely while keeping the output.

**The pipe philosophy**: Linux tools are designed to do one thing well and pass their output to the next tool via pipes. `grep` finds lines, `cut` extracts fields, `sort` orders them, `wc` counts them. By connecting these small tools, you build powerful data pipelines without writing a single program.

**Redirection** changes where a stream goes. Instead of the terminal, stdout can go to a file. Instead of the keyboard, stdin can come from a file. You can redirect stdout and stderr to different places, merge them, or throw them away entirely.

---

## Commands to Learn

### 1. `>` and `>>` — Redirect stdout (Overwrite vs Append)
```bash
# > writes stdout to a file, OVERWRITING any existing content
echo "first line" > output.txt
cat output.txt
# first line

echo "second line" > output.txt
cat output.txt
# second line   (first line is gone!)

# >> APPENDS stdout to a file (adds to the end)
echo "line one" > output.txt
echo "line two" >> output.txt
echo "line three" >> output.txt
cat output.txt
# line one
# line two
# line three

# Redirect command output to a file
ls -la > file-listing.txt
date > timestamp.txt
grep "ERROR" app.log > errors-only.txt
```

> **Warning**: `>` destroys the existing file contents without asking. There is no undo. Use `>>` when you want to add to a file.

### 2. `2>` and `2>>` — Redirect stderr
```bash
# Errors go to stderr (file descriptor 2), not stdout
# Try to list a nonexistent directory:
ls /nonexistent 2> errors.txt
cat errors.txt
# ls: cannot access '/nonexistent': No such file or directory

# Append errors to a log
ls /fake1 2>> error-log.txt
ls /fake2 2>> error-log.txt
cat error-log.txt
# Both errors are collected

# stdout still goes to the terminal when you only redirect stderr
ls /tmp /nonexistent 2> errors.txt
# /tmp contents print to screen; error about /nonexistent goes to file
```

### 3. `&>` and `2>&1` — Redirect Both stdout and stderr
```bash
# &> sends BOTH stdout and stderr to the same file (bash shorthand)
ls /tmp /nonexistent &> all-output.txt

# 2>&1 means "send stderr to wherever stdout is going"
# This is the traditional (POSIX) way:
ls /tmp /nonexistent > all-output.txt 2>&1

# Common pattern: redirect stdout to a file, stderr to a different file
ls /tmp /nonexistent > good.txt 2> bad.txt

# Order matters with 2>&1:
# CORRECT — redirect stdout to file first, then stderr follows:
command > output.txt 2>&1
# WRONG — stderr goes to terminal (stdout hasn't been redirected yet):
command 2>&1 > output.txt
```

### 4. `<` — Redirect stdin
```bash
# Instead of typing input, feed a file as stdin
wc -l < /etc/passwd           # Count lines (file content fed as stdin)
sort < unsorted.txt            # Sort lines from a file
tr 'a-z' 'A-Z' < input.txt    # Uppercase a file via stdin

# Difference between these two:
wc -l /etc/passwd              # wc opens the file itself, prints filename
wc -l < /etc/passwd            # shell feeds file as stdin, no filename shown

# Combine input and output redirection
sort < unsorted.txt > sorted.txt
tr 'a-z' 'A-Z' < input.txt > uppercased.txt
```

### 5. `|` — Pipes (Chaining Commands)
```bash
# A pipe connects stdout of one command to stdin of the next
ls -la | head -5                      # List files, show first 5 lines
cat /etc/passwd | wc -l               # Count users
grep "ERROR" app.log | wc -l          # Count errors
ps aux | grep nginx                   # Find nginx processes

# Multi-step pipelines
cat access.log | cut -d ' ' -f 1 | sort | uniq -c | sort -rn | head -5
# Reads log -> extracts IPs -> sorts -> counts -> top 5

# Pipes only pass stdout — stderr still goes to the terminal
ls /tmp /nonexistent | wc -l
# Error message appears on screen; only /tmp listing is piped to wc

# To pipe both stdout and stderr:
ls /tmp /nonexistent 2>&1 | wc -l
```

### 6. `tee` — Write to File AND stdout
```bash
# tee copies stdin to a file AND passes it through to stdout
echo "hello" | tee output.txt
# Prints "hello" to terminal AND writes it to output.txt

# Useful in pipelines: save intermediate results without breaking the chain
grep "ERROR" app.log | tee errors.txt | wc -l
# Saves errors to errors.txt AND counts them

# Append mode with -a
echo "new line" | tee -a output.txt

# Write to multiple files at once
echo "broadcast" | tee file1.txt file2.txt file3.txt

# Common pattern: see output AND log it
./deploy.sh 2>&1 | tee deploy.log
# Watch the deployment live AND save a log

# tee with sudo (write to a root-owned file)
echo "127.0.0.1 myapp.local" | sudo tee -a /etc/hosts
```

### 7. Here Documents (`<<EOF`) and Here Strings (`<<<`)
```bash
# Here document: feed multiple lines as stdin to a command
cat <<EOF
Hello, this is line one.
This is line two.
Variables work: HOME is $HOME
EOF

# Use <<'EOF' (quoted) to prevent variable expansion
cat <<'EOF'
This $VARIABLE is printed literally.
No expansion happens here.
EOF

# Practical: create a config file
cat <<EOF > config.txt
server=production
port=8080
debug=false
EOF

# Practical: send a multi-line email body
mail -s "Report" admin@example.com <<EOF
Daily report:
Errors: 5
Warnings: 12
EOF

# Here string: feed a single string as stdin
wc -w <<< "count these words"
# 3

tr 'a-z' 'A-Z' <<< "make me uppercase"
# MAKE ME UPPERCASE

grep "error" <<< "this line has an error in it"
# this line has an error in it
```

### 8. `/dev/null` — The Black Hole
```bash
# /dev/null discards anything written to it
echo "this disappears" > /dev/null

# Suppress stdout (only see errors)
ls /tmp /nonexistent > /dev/null
# Only the error about /nonexistent prints

# Suppress stderr (only see normal output)
ls /tmp /nonexistent 2> /dev/null
# Only the /tmp listing prints

# Suppress ALL output (run silently)
ls /tmp /nonexistent &> /dev/null
# Nothing prints at all

# Common use: check if a command succeeds without caring about output
if grep -q "root" /etc/passwd > /dev/null 2>&1; then
    echo "root user exists"
fi

# Common use: cron jobs that should not generate email
0 * * * * /usr/local/bin/cleanup.sh > /dev/null 2>&1
```

---

## Hands-On Exercises

### Setup: Use the Sample Data
Sample files are included in the `sample-data/` directory — no need to create anything.

```bash
cd sample-data/
ls -la
```

**Files included:**
| File | What It Contains |
|------|-----------------|
| `mixed-output.sh` | Script that produces both stdout and stderr |
| `server-logs/app-1.log` | Application log from server 1 |
| `server-logs/app-2.log` | Application log from server 2 |
| `server-logs/app-3.log` | Application log from server 3 |
| `urls.txt` | List of 10 URLs for stdin exercises |
| `numbers.txt` | 20 numbers, one per line |

> All exercises below assume you are inside the `sample-data/` directory.

---

### Exercise 1: Basic Output Redirection

```bash
# List the contents of server-logs/ and save to a file
ls -la server-logs/ > listing.txt
cat listing.txt

# Save all lines from app-1.log to a new file containing only ERROR lines
grep "ERROR" server-logs/app-1.log > app1-errors.txt
cat app1-errors.txt

# Append ERROR lines from app-2.log and app-3.log to the same file
grep "ERROR" server-logs/app-2.log >> app1-errors.txt
grep "ERROR" server-logs/app-3.log >> app1-errors.txt
wc -l app1-errors.txt

# Save the current date and uptime to a status file
date > status.txt
uptime >> status.txt
cat status.txt
```

---

### Exercise 2: Separating stdout and stderr

```bash
# First, look at what mixed-output.sh does
cat mixed-output.sh

# Run it — observe both normal output and errors on screen
bash mixed-output.sh

# Capture only stdout (errors still appear on screen)
bash mixed-output.sh > stdout-only.txt
cat stdout-only.txt

# Capture only stderr (normal output still appears on screen)
bash mixed-output.sh 2> stderr-only.txt
cat stderr-only.txt

# Send stdout and stderr to separate files
bash mixed-output.sh > stdout.txt 2> stderr.txt
echo "--- stdout ---"
cat stdout.txt
echo "--- stderr ---"
cat stderr.txt

# Capture everything in one file
bash mixed-output.sh &> all-output.txt
cat all-output.txt
```

---

### Exercise 3: Suppressing Output with /dev/null

```bash
# Run mixed-output.sh but only see errors (suppress stdout)
bash mixed-output.sh > /dev/null

# Run mixed-output.sh but only see normal output (suppress errors)
bash mixed-output.sh 2> /dev/null

# Run completely silently — check only the exit code
bash mixed-output.sh &> /dev/null
echo "Exit code: $?"

# Suppress errors when searching across all logs
grep -r "CRITICAL" server-logs/ 2> /dev/null

# Silently check if a pattern exists (using -q and /dev/null)
if grep -q "ERROR" server-logs/app-1.log 2> /dev/null; then
    echo "Errors found in app-1.log"
else
    echo "No errors in app-1.log"
fi
```

---

### Exercise 4: stdin Redirection

```bash
# Count how many URLs are in the file using stdin redirection
wc -l < urls.txt

# Sort the numbers file via stdin
sort -n < numbers.txt

# Uppercase all URLs
tr 'a-z' 'A-Z' < urls.txt

# Use a here string to quickly test a grep pattern
grep "https" <<< "https://example.com"
grep "https" <<< "http://example.com"

# Use a here document to create a quick report header
cat <<EOF > report-header.txt
=============================
  SERVER LOG ANALYSIS REPORT
  Generated: $(date)
=============================
EOF
cat report-header.txt

# Feed sorted numbers through a calculation
sort -n < numbers.txt | tail -1    # Largest number
sort -n < numbers.txt | head -1    # Smallest number
```

---

### Exercise 5: Pipes — Building Pipelines

```bash
# Count total ERROR lines across all three server logs
cat server-logs/app-*.log | grep "ERROR" | wc -l

# Find the 3 most common log levels across all servers
cat server-logs/app-*.log | grep -oE "\[(INFO|WARN|ERROR|DEBUG|CRITICAL)\]" | sort | uniq -c | sort -rn | head -5

# Extract unique timestamps (date only) across all logs
cat server-logs/app-*.log | cut -d ' ' -f 1 | sort -u

# Find which services generate the most errors
cat server-logs/app-*.log | grep "ERROR" | grep -oE "\[.*\]" | sort | uniq -c | sort -rn

# Build a pipeline: get all unique source IPs from logs that had errors
cat server-logs/app-*.log | grep "ERROR" | grep -oE "src=[0-9.]+" | sort -u

# Count how many lines each log file has (using a loop with a pipe)
wc -l server-logs/app-*.log

# Pipeline with numbers: sum all numbers using paste and bc
cat numbers.txt | paste -sd+ | bc
```

---

### Exercise 6: Using tee — Save and Continue

```bash
# Find all errors and save them while also counting
cat server-logs/app-*.log | grep "ERROR" | tee all-errors.txt | wc -l
cat all-errors.txt

# Build a pipeline, saving intermediate results at each step
cat server-logs/app-*.log \
    | tee step1-raw.txt \
    | grep "ERROR" \
    | tee step2-errors.txt \
    | cut -d ' ' -f 1,2 \
    | tee step3-timestamps.txt \
    | sort \
    | tee step4-sorted.txt \
    | uniq -c \
    | sort -rn > final-report.txt

# Check each intermediate file
wc -l step1-raw.txt step2-errors.txt step3-timestamps.txt step4-sorted.txt final-report.txt

# Append to a running log with tee -a
echo "=== Run 1 ===" | tee combined-log.txt
grep "WARN" server-logs/app-1.log | tee -a combined-log.txt | wc -l
echo "=== Run 2 ===" | tee -a combined-log.txt
grep "WARN" server-logs/app-2.log | tee -a combined-log.txt | wc -l
cat combined-log.txt

# Write the same output to two different files
cat server-logs/app-1.log | grep "ERROR" | tee errors-backup1.txt errors-backup2.txt > /dev/null
```

---

### Exercise 7: Here Documents — Multi-line Input

```bash
# Create a configuration file using a here document
cat <<EOF > app-config.conf
# Application Configuration
# Generated on $(date)
app_name=log-analyzer
log_level=INFO
max_retries=3
timeout=30
EOF
cat app-config.conf

# Use a here document with no variable expansion (quoted delimiter)
cat <<'EOF' > template.sh
#!/bin/bash
echo "User: $USER"
echo "Home: $HOME"
echo "Date: $(date)"
EOF
cat template.sh

# Feed a here document into grep
grep "ERROR" <<EOF
INFO: Server started
ERROR: Connection refused
WARN: Slow query
ERROR: Disk full
INFO: Request processed
EOF

# Use a here string for quick one-off tests
wc -w <<< "how many words here"
sort <<< "banana
apple
cherry"
```

---

### Exercise 8: Combining stdout and stderr in Pipelines

```bash
# Run mixed-output.sh and count ALL lines (stdout + stderr)
bash mixed-output.sh 2>&1 | wc -l

# Run mixed-output.sh, merge streams, and grep for specific text
bash mixed-output.sh 2>&1 | grep -i "error\|fail\|no such"

# Save errors from a pipeline that might fail partway through
cat server-logs/app-*.log nonexistent.log 2> pipeline-errors.txt | grep "ERROR" | wc -l
cat pipeline-errors.txt

# Process errors and output separately then combine
bash mixed-output.sh > stdout.txt 2> stderr.txt
echo "Normal output lines: $(wc -l < stdout.txt)"
echo "Error output lines: $(wc -l < stderr.txt)"
cat stdout.txt stderr.txt > combined.txt
echo "Total lines: $(wc -l < combined.txt)"
```

---

### Exercise 9: Multi-step Log Analysis Pipeline

```bash
# Scenario: Analyze all three server logs to build an incident timeline

# Step 1: Merge all logs into one sorted stream
cat server-logs/app-*.log | sort > merged-sorted.log
head -5 merged-sorted.log

# Step 2: Extract only errors and warnings, save with tee
cat merged-sorted.log | grep -E "\[(ERROR|WARN|CRITICAL)\]" | tee issues.log | wc -l

# Step 3: Count issues per severity level
cat issues.log | grep -oE "\[(ERROR|WARN|CRITICAL)\]" | sort | uniq -c | sort -rn

# Step 4: Find the time window when most errors occurred
cat issues.log | cut -d ' ' -f 1,2 | cut -d ':' -f 1,2 | sort | uniq -c | sort -rn | head -3

# Step 5: Generate a summary report using here document + pipeline results
cat <<EOF > incident-report.txt
=================================
  INCIDENT REPORT
  Generated: $(date)
=================================

Total log lines analyzed: $(wc -l < merged-sorted.log)
Total issues found: $(wc -l < issues.log)

Breakdown by severity:
$(cat issues.log | grep -oE "\[(ERROR|WARN|CRITICAL)\]" | sort | uniq -c | sort -rn)

Peak issue windows:
$(cat issues.log | cut -d ' ' -f 1,2 | cut -d ':' -f 1,2 | sort | uniq -c | sort -rn | head -3)

=================================
EOF
cat incident-report.txt
```

---

### Exercise 10: Challenge — Full Redirection Mastery

```bash
# Use EVERY concept from today in this exercise:
# - stdout redirection (> and >>)
# - stderr redirection (2> and 2>>)
# - stdin redirection (<)
# - Pipes (|)
# - tee
# - Here documents (<<EOF)
# - /dev/null
# - Combined redirection (2>&1)

# Task: Build a complete log processing system that:
# 1. Merges all server logs, suppressing any file-not-found errors
# 2. Filters for ERROR and CRITICAL entries
# 3. Saves the filtered results AND passes them on
# 4. Extracts just timestamps and messages
# 5. Sorts everything chronologically
# 6. Generates a report with a header (using here document)
# 7. Appends a summary with line counts
# 8. Reads the numbers.txt file and adds a "total events per number-of-servers" stat

# --- Try solving it before looking below ---
```

<details>
<summary>Click to reveal solution</summary>

```bash
# Step 1: Merge all logs, suppress errors about missing files
cat server-logs/app-*.log nonexistent.log 2> /dev/null | sort > merged.log

# Step 2-3: Filter for serious issues, save with tee
cat merged.log | grep -E "\[(ERROR|CRITICAL)\]" | tee serious-issues.log | wc -l

# Step 4-5: Extract timestamps and messages, sort chronologically
cat serious-issues.log | cut -d ' ' -f 1,2,4- | sort > timeline.log

# Step 6: Generate report header with a here document
cat <<EOF > final-report.txt
==============================================
  DAILY LOG ANALYSIS REPORT
  Date: $(date)
  Servers analyzed: 3
  Log files processed: $(ls server-logs/app-*.log | wc -l)
==============================================

EOF

# Step 7: Append the timeline and summary
echo "--- ISSUE TIMELINE ---" >> final-report.txt
cat timeline.log >> final-report.txt
echo "" >> final-report.txt
echo "--- SUMMARY ---" >> final-report.txt
echo "Total log lines: $(wc -l < merged.log)" >> final-report.txt
echo "Serious issues: $(wc -l < serious-issues.log)" >> final-report.txt
echo "" >> final-report.txt

# Severity breakdown using a pipeline with tee
echo "Severity breakdown:" >> final-report.txt
cat serious-issues.log | grep -oE "\[(ERROR|CRITICAL)\]" | sort | uniq -c | sort -rn >> final-report.txt
echo "" >> final-report.txt

# Step 8: Use stdin redirection to read numbers and add a stat
echo "Numbers file stats:" >> final-report.txt
echo "  Count: $(wc -l < numbers.txt)" >> final-report.txt
echo "  Sum: $(sort -n < numbers.txt | paste -sd+ | bc)" >> final-report.txt
echo "  Min: $(sort -n < numbers.txt | head -1)" >> final-report.txt
echo "  Max: $(sort -n < numbers.txt | tail -1)" >> final-report.txt

# View the final report (all stdout, no clutter)
cat final-report.txt 2> /dev/null

# Clean up temp files silently
rm -f merged.log serious-issues.log timeline.log 2> /dev/null
```

</details>

---

## Quick Reference

| Syntax | What It Does |
|--------|-------------|
| `command > file` | Redirect stdout to file (overwrite) |
| `command >> file` | Redirect stdout to file (append) |
| `command 2> file` | Redirect stderr to file (overwrite) |
| `command 2>> file` | Redirect stderr to file (append) |
| `command &> file` | Redirect both stdout and stderr to file |
| `command > file 2>&1` | Redirect both (POSIX way) |
| `command > out.txt 2> err.txt` | stdout and stderr to separate files |
| `command < file` | Feed file as stdin |
| `cmd1 \| cmd2` | Pipe stdout of cmd1 into stdin of cmd2 |
| `cmd \| tee file` | Write to file AND pass through |
| `cmd \| tee -a file` | Append to file AND pass through |
| `cmd <<EOF ... EOF` | Here document (multi-line stdin) |
| `cmd <<'EOF' ... EOF` | Here document (no variable expansion) |
| `cmd <<< "string"` | Here string (single-line stdin) |
| `command > /dev/null` | Discard stdout |
| `command 2> /dev/null` | Discard stderr |
| `command &> /dev/null` | Discard all output |

---

## Checklist

- [ ] I understand the three standard streams: stdin (0), stdout (1), stderr (2)
- [ ] I can redirect stdout to a file with `>` (overwrite) and `>>` (append)
- [ ] I can redirect stderr separately with `2>` and `2>>`
- [ ] I can redirect both streams with `&>` or `> file 2>&1`
- [ ] I can send stdout and stderr to different files
- [ ] I can feed a file as stdin using `<`
- [ ] I can chain commands with pipes `|` to build multi-step pipelines
- [ ] I can use `tee` to save intermediate output while continuing a pipeline
- [ ] I can create multi-line input with here documents (`<<EOF`)
- [ ] I can use here strings (`<<<`) for quick one-line input
- [ ] I can use `/dev/null` to discard unwanted output
- [ ] I can combine all redirection concepts in a single workflow

---

> **Tomorrow (Day 7)**: Your First Shell Script — variables, arguments, shebang, and making scripts executable.
