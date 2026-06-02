# Day 4: Text Processing — Part 1

## Goal
Learn to search, filter, sort, and count text in files — essential skills for reading logs, parsing configs, and building pipelines.

---

## Core Concepts

Text processing in Linux follows a simple philosophy: small tools that each do one thing well, connected with pipes (`|`). You rarely write a program to parse a log file — you chain `grep`, `cut`, `sort`, and `uniq` together.

| Tool | Job |
|------|-----|
| `grep` | Find lines matching a pattern |
| `cut` | Extract columns/fields from each line |
| `sort` | Sort lines |
| `uniq` | Remove or count duplicate lines |
| `wc` | Count lines, words, characters |
| `head` / `tail` | View the first or last N lines |
| `tr` | Translate or delete characters |

---

## Commands to Learn

### 1. `grep` — Search for Patterns in Text
```bash
grep "error" logfile.log            # Find lines containing "error"
grep -i "error" logfile.log         # Case-insensitive search
grep -n "error" logfile.log         # Show line numbers
grep -c "error" logfile.log         # Count matching lines
grep -v "debug" logfile.log         # Invert — show lines NOT matching
grep -r "TODO" /path/to/project/   # Search recursively in a directory
grep -l "password" *.conf           # List only filenames that match
grep -w "fail" logfile.log          # Match whole word only (not "failure")
grep -A 3 "error" logfile.log      # Show 3 lines After each match
grep -B 2 "error" logfile.log      # Show 2 lines Before each match
grep -C 2 "error" logfile.log      # Show 2 lines of Context (before + after)
```

**Basic regex with `grep -E` (extended regex):**
```bash
grep -E "error|warning" logfile.log       # Match "error" OR "warning"
grep -E "^2024-01-15" logfile.log         # Lines starting with a date
grep -E "failed$" logfile.log             # Lines ending with "failed"
grep -E "[0-9]{1,3}\.[0-9]{1,3}" log.txt # Match IP-like patterns
```

### 2. `cut` — Extract Fields/Columns
```bash
cut -d ':' -f 1 /etc/passwd        # Field 1, colon-delimited (usernames)
cut -d ':' -f 1,3 /etc/passwd      # Fields 1 and 3 (username, UID)
cut -d ',' -f 2 data.csv           # Field 2 from a CSV
cut -d ' ' -f 1 access.log         # First space-delimited field (IP addresses)
cut -c 1-10 file.txt               # Characters 1 through 10 of each line
cut -c 5- file.txt                 # From character 5 to end of line
```

### 3. `sort` — Sort Lines
```bash
sort file.txt                       # Sort alphabetically
sort -n numbers.txt                 # Sort numerically
sort -r file.txt                    # Reverse sort
sort -u file.txt                    # Sort and remove duplicates
sort -t ',' -k 2 data.csv          # Sort CSV by 2nd column
sort -t ',' -k 3 -n data.csv       # Sort CSV by 3rd column, numerically
sort -h sizes.txt                   # Sort human-readable sizes (1K, 2M, 3G)
```

### 4. `uniq` — Remove/Count Duplicate Lines
```bash
sort file.txt | uniq                # Remove adjacent duplicates (sort first!)
sort file.txt | uniq -c             # Count occurrences of each line
sort file.txt | uniq -d             # Show only duplicated lines
sort file.txt | uniq -u             # Show only unique lines (no duplicates)
```
> **Important**: `uniq` only removes *adjacent* duplicates. Always `sort` first.

### 5. `wc` — Word, Line, Character Counts
```bash
wc file.txt                         # Lines, words, characters
wc -l file.txt                      # Line count only
wc -w file.txt                      # Word count only
wc -c file.txt                      # Byte count
wc -m file.txt                      # Character count (handles multi-byte)
wc -l *.log                         # Count lines in all log files
```

### 6. `head` and `tail` — View Start or End of Files
```bash
head file.txt                       # First 10 lines (default)
head -n 5 file.txt                  # First 5 lines
head -n 20 file.txt                 # First 20 lines

tail file.txt                       # Last 10 lines (default)
tail -n 5 file.txt                  # Last 5 lines
tail -f /var/log/syslog             # Follow — live stream new lines (Ctrl+C to stop)
tail -n +5 file.txt                 # Everything from line 5 onwards
```

### 7. `tr` — Translate or Delete Characters
```bash
echo "hello" | tr 'a-z' 'A-Z'      # Convert lowercase to uppercase
echo "hello" | tr 'l' 'r'          # Replace l with r → "herro"
echo "a::b::c" | tr -s ':'         # Squeeze repeated colons → "a:b:c"
echo "hello 123" | tr -d '0-9'     # Delete all digits → "hello "
echo "one two three" | tr ' ' '\n' # Replace spaces with newlines
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
| File | What It Simulates | Lines |
|------|-------------------|-------|
| `access.log` | Nginx/Apache web server access log | 30 |
| `app.log` | Node.js application log with modules | 36 |
| `syslog.log` | System log from web + database servers | 30 |
| `deploy-history.log` | CI/CD deployment history | 18 |
| `employees.csv` | HR dataset with 20 employees | 21 |

> All exercises below assume you are inside the `sample-data/` directory.

---

### Exercise 1: Log Searching with `grep`
```bash
# Find all error lines in the app log
grep "ERROR" app.log

# Count how many errors occurred
grep -c "ERROR" app.log

# Find all non-INFO lines (warnings + errors)
grep -v "INFO" app.log

# Find failed login attempts with 2 lines of context
grep -B 1 -A 1 "failed" app.log

# Find lines with either ERROR or WARN
grep -E "ERROR|WARN" app.log

# Find all 500 status codes in the access log
grep " 500 " access.log

# Find all non-200 responses (potential problems)
grep -v " 200 " access.log

# Search for a specific IP across all log files
grep -l "10.0.0.5" *.log
```

**What you should see**: `grep` makes it trivial to pull specific events from logs — no scrolling, no guessing.

---

### Exercise 2: Extracting Fields with `cut`
```bash
# Extract just the IP addresses from the access log (field 1, space-delimited)
cut -d ' ' -f 1 access.log

# Extract the HTTP method and path (fields 6-7)
cut -d ' ' -f 6,7 access.log

# Extract status codes (field 8)
cut -d ' ' -f 8 access.log

# Extract names from the CSV (field 1, comma-delimited)
cut -d ',' -f 1 employees.csv

# Extract name and salary
cut -d ',' -f 1,3 employees.csv

# Extract the timestamp from the app log (fields 1-2, space-delimited)
cut -d ' ' -f 1,2 app.log

# Extract the log level (field 3)
cut -d ' ' -f 3 app.log
```

---

### Exercise 3: Sorting and Counting
```bash
# Get a sorted list of unique IP addresses from the access log
cut -d ' ' -f 1 access.log | sort -u

# Count requests per IP address
cut -d ' ' -f 1 access.log | sort | uniq -c | sort -rn

# Find the most common status codes
cut -d ' ' -f 8 access.log | sort | uniq -c | sort -rn

# Count log entries per level
cut -d ' ' -f 3 app.log | sort | uniq -c | sort -rn

# Sort employees by salary (3rd field, numeric, comma-delimited)
sort -t ',' -k 3 -n employees.csv

# Find unique departments
cut -d ',' -f 2 employees.csv | tail -n +2 | sort -u

# Count employees per department
cut -d ',' -f 2 employees.csv | tail -n +2 | sort | uniq -c | sort -rn

# Count employees per city
cut -d ',' -f 4 employees.csv | tail -n +2 | sort | uniq -c | sort -rn
```

---

### Exercise 4: Combining Tools — Real Analysis
```bash
# Q: Which IP address made the most requests?
cut -d ' ' -f 1 access.log | sort | uniq -c | sort -rn | head -1

# Q: How many unique IPs hit the server?
cut -d ' ' -f 1 access.log | sort -u | wc -l

# Q: What pages had errors (status 500)?
grep " 500 " access.log | cut -d ' ' -f 7

# Q: How many times did each page get requested?
cut -d ' ' -f 7 access.log | sort | uniq -c | sort -rn

# Q: What are the database errors?
grep "database" app.log

# Q: Find all IPs that got 401 (unauthorized) responses
grep " 401 " access.log | cut -d ' ' -f 1 | sort -u

# Q: Get a timeline of errors only (timestamp + message)
grep "ERROR" app.log | cut -d ' ' -f 1,2,4-

# Q: Which department has the highest average salary? (quick count)
# Engineering employees:
grep "Engineering" employees.csv | wc -l
# Marketing employees:
grep "Marketing" employees.csv | wc -l
```

---

### Exercise 5: Using `head`, `tail`, and `wc`
```bash
# How many lines in each log?
wc -l access.log app.log

# View the first 3 requests
head -n 3 access.log

# View the last 3 app log entries
tail -n 3 app.log

# View all lines except the CSV header
tail -n +2 employees.csv

# Count how many words in the app log
wc -w app.log

# Get lines 5-8 of the access log (head + tail combo)
head -n 8 access.log | tail -n 4

# Count unique IPs (pipe wc -l with sort -u)
cut -d ' ' -f 1 access.log | sort -u | wc -l
```

---

### Exercise 6: Character Translation with `tr`
```bash
# Convert log levels to lowercase
grep "ERROR" app.log | tr 'A-Z' 'a-z'

# Replace commas with tabs for easier reading
cat employees.csv | tr ',' '\t'

# Squeeze multiple spaces into one (common in messy logs)
echo "name     value     result" | tr -s ' '

# Strip out all digits from a string
echo "server-01.prod.us-east-1" | tr -d '0-9'

# Quick word frequency: split words onto separate lines, sort, count
cat app.log | tr ' ' '\n' | tr 'A-Z' 'a-z' | sort | uniq -c | sort -rn | head -10
```

---

### Exercise 7: Build a Mini Log Report
```bash
echo "===== ACCESS LOG REPORT ====="
echo ""

echo "Total requests:"
wc -l < access.log

echo ""
echo "Unique visitors (IPs):"
cut -d ' ' -f 1 access.log | sort -u | wc -l

echo ""
echo "Requests per IP:"
cut -d ' ' -f 1 access.log | sort | uniq -c | sort -rn

echo ""
echo "Status code breakdown:"
cut -d ' ' -f 8 access.log | sort | uniq -c | sort -rn

echo ""
echo "Failed requests (non-200):"
grep -v " 200 " access.log | wc -l

echo ""
echo "Top requested pages:"
cut -d ' ' -f 7 access.log | sort | uniq -c | sort -rn

echo ""
echo "===== APP LOG REPORT ====="
echo ""

echo "Errors:"
grep -c "ERROR" app.log

echo "Warnings:"
grep -c "WARN" app.log

echo ""
echo "Error details:"
grep "ERROR" app.log | cut -d ' ' -f 4-

echo ""
echo "===== REPORT COMPLETE ====="
```

---

### Exercise 8: Analyzing the Syslog
```bash
# The syslog has entries from multiple servers and services.

# Which servers appear in the log?
cut -d ' ' -f 4 syslog.log | sort -u

# Find all SSH-related entries
grep "sshd" syslog.log

# Which IP was trying to brute-force SSH?
grep "Failed password" syslog.log | grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | sort -u

# How many failed SSH attempts?
grep -c "Failed password" syslog.log

# Did fail2ban catch the attacker?
grep "fail2ban" syslog.log

# Find all database errors
grep "postgres" syslog.log | grep -i "error\|fatal"

# Check health check results
grep "health-check" syslog.log

# How many health checks passed vs failed?
grep "health-check" syslog.log | grep -c "OK"
grep "health-check" syslog.log | grep -c "FAIL"
```

---

### Exercise 9: Deployment History Analysis
```bash
# How many deployments total?
wc -l < deploy-history.log

# How many failed vs succeeded?
grep -c "status=success" deploy-history.log
grep -c "status=failed" deploy-history.log

# Who deployed the most?
cut -d ' ' -f 6 deploy-history.log | cut -d '=' -f 2 | sort | uniq -c | sort -rn

# How many rollbacks happened?
grep -c "rollback" deploy-history.log

# Which versions failed?
grep "status=failed" deploy-history.log | cut -d ' ' -f 4

# Deployments per environment
cut -d ' ' -f 5 deploy-history.log | cut -d '=' -f 2 | sort | uniq -c

# Find the longest deployment (sort by duration)
grep "status=success" deploy-history.log | grep -oE "duration=[0-9]+s" | sort -t '=' -k 2 -n
```

---

### Exercise 10: Challenge — Investigate a Security Incident
```bash
# Scenario: You're the on-call engineer. You got paged at 10:20 AM.
# Someone reports suspicious activity. Use ALL the log files to piece together what happened.
# Use ONLY the tools from today to answer these questions.

# 1. Which IP had repeated failed logins in the access log?
#    (hint: grep 401, extract IPs, count)

# 2. The same IP was also trying to brute-force SSH — find evidence in syslog.log

# 3. How many total failed login attempts (web + SSH combined) from that IP?

# 4. Did fail2ban eventually block them? What happened?

# 5. Did the attacker manage to log into the web app before being banned?
#    (hint: check access.log for that IP + status 200)

# 6. What did the attacker try to do after logging in?

# 7. Were there server-side problems happening at the same time?
#    (hint: check all logs for ERROR, 500, FATAL)

# 8. Was the database the root cause? Find the specific DB errors across all logs.

# --- Try solving each before looking below ---
```

<details>
<summary>Click to reveal solutions</summary>

```bash
# 1. IPs with repeated 401s in access.log
grep " 401 " access.log | cut -d ' ' -f 1 | sort | uniq -c | sort -rn
# Answer: 10.0.0.8 had 5 failed logins, 10.0.0.5 had 2

# 2. Same IP brute-forcing SSH
grep "10.0.0.8" syslog.log
# Answer: 3 failed SSH passwords for root, 2 for admin

# 3. Total failed attempts from 10.0.0.8
grep "10.0.0.8" access.log | grep " 401 " | wc -l   # 5 web
grep "10.0.0.8" syslog.log | grep "Failed" | wc -l   # 5 SSH
# Answer: 10 total failed login attempts

# 4. fail2ban response
grep "fail2ban" syslog.log
# Answer: Yes — banned 10.0.0.8 for 3600 seconds at 10:20

# 5. Did they get into the web app?
grep "10.0.0.8" access.log | grep " 200 "
# Answer: Yes — POST /api/login returned 200 at 10:20:30

# 6. What did they do after logging in?
grep "10.0.0.8" access.log | grep -v " 401 "
# Answer: Tried DELETE /api/user/12 and DELETE /api/user/8 (both got 403)

# 7. Server errors happening at the same time?
grep " 500 " access.log
grep "ERROR" app.log
grep "ERROR\|FATAL" syslog.log
# Answer: Multiple 500s on /api/data, DB timeouts, connection pool exhausted

# 8. Root cause — database errors across all logs
grep -h "database\|postgres\|db" app.log syslog.log | grep -i "error\|fatal\|timeout"
# Answer: Connection timeouts, "too many connections", deadlock, and pool exhaustion
```

</details>

---

## Quick Reference

| Command | What It Does |
|---------|-------------|
| `grep "pattern" file` | Find lines matching a pattern |
| `grep -i` | Case-insensitive search |
| `grep -c` | Count matches |
| `grep -v` | Invert (exclude matches) |
| `grep -r` | Search recursively |
| `grep -E "a\|b"` | Extended regex (OR, etc.) |
| `cut -d ',' -f 1,3` | Extract fields 1 and 3 |
| `sort -n` | Sort numerically |
| `sort -rn` | Reverse numeric sort |
| `sort -t ',' -k 2` | Sort by field 2 |
| `uniq -c` | Count duplicates (sort first!) |
| `wc -l` | Count lines |
| `head -n 5` | First 5 lines |
| `tail -n 5` | Last 5 lines |
| `tail -f` | Follow a file (live stream) |
| `tr 'a-z' 'A-Z'` | Translate characters |

---

## Checklist

- [ ] I can use `grep` to search files for patterns (with `-i`, `-v`, `-c`, `-n`, `-r`)
- [ ] I can use basic regex with `grep -E` for OR patterns and anchors
- [ ] I can use `cut` to extract specific fields from delimited text
- [ ] I can use `sort` and `uniq -c` together to count occurrences
- [ ] I can chain multiple tools with pipes to answer real questions
- [ ] I can use `head` and `tail` to view parts of a file
- [ ] I can use `wc -l` to count lines in files or piped output
- [ ] I can use `tr` to translate or delete characters

---

> **Tomorrow (Day 5)**: Text Processing Part 2 — `sed`, `awk`, and building more powerful text pipelines.
