# Day 5: Text Processing -- Part 2

## Goal
Master `sed` and `awk` to transform, reformat, and calculate data directly from the command line -- the power tools that turn you from a log reader into a log surgeon.

---

## Core Concepts

Day 4 covered tools that **search** and **filter** text (`grep`, `cut`, `sort`, `uniq`). Today's tools go further -- they **transform** text.

| Tool | What It Does |
|------|-------------|
| `sed` | **Stream Editor** -- find-and-replace, delete lines, insert text, all without opening a file in an editor. Works line by line. |
| `awk` | **Column-Oriented Processor** -- splits each line into fields and lets you print, filter, and calculate on them. Think of it as a mini programming language for tabular data. |

**When to use which:**
- Need to find/replace text, delete or insert lines? Use `sed`.
- Need to extract columns, do math, or produce formatted reports? Use `awk`.
- Need both? Pipe one into the other.

---

## Commands to Learn

### 1. `sed` -- Stream Editor

**Basic substitution** (`s/old/new/`):
```bash
sed 's/error/ERROR/' file.txt           # Replace first "error" on each line
sed 's/error/ERROR/g' file.txt          # Replace ALL occurrences on each line (global)
sed 's/error/ERROR/gi' file.txt         # Global + case-insensitive (GNU sed)
sed 's/http:/https:/' urls.txt          # Fix protocol in URLs
```

**In-place editing** (`-i`):
```bash
sed -i 's/old/new/g' file.txt           # Edit the file directly (no output)
sed -i.bak 's/old/new/g' file.txt       # Edit in place, keep a .bak backup
```
> **Warning**: `-i` modifies the file permanently. Always test without `-i` first, or use `-i.bak` to keep a backup.

**Deleting lines** (`d`):
```bash
sed '5d' file.txt                       # Delete line 5
sed '1d' file.txt                       # Delete the first line (header)
sed '$d' file.txt                       # Delete the last line
sed '/^#/d' file.txt                    # Delete all comment lines
sed '/^$/d' file.txt                    # Delete all blank lines
sed '3,7d' file.txt                     # Delete lines 3 through 7
```

**Address ranges** (apply commands to specific lines):
```bash
sed '1,5s/foo/bar/g' file.txt           # Replace only on lines 1-5
sed '/server/s/80/443/g' config.conf    # Replace 80 with 443 only on lines containing "server"
sed '10,20d' file.txt                   # Delete lines 10-20
sed '/^$/,/^$/d' file.txt              # Delete blocks of blank lines
```

**Inserting and appending text**:
```bash
sed '1i\# This is a new header' file.txt      # Insert before line 1
sed '$a\# End of file' file.txt                # Append after last line
sed '/location/a\    # Added by automation' f  # Append after lines matching "location"
```

**Printing specific lines** (`-n` + `p`):
```bash
sed -n '5p' file.txt                    # Print only line 5
sed -n '10,20p' file.txt                # Print lines 10 through 20
sed -n '/error/p' file.txt              # Print lines matching "error" (like grep)
```

**Multiple commands** (`-e` or semicolons):
```bash
sed -e 's/foo/bar/' -e 's/baz/qux/' file.txt   # Two substitutions
sed 's/foo/bar/; s/baz/qux/' file.txt           # Same thing with semicolons
```

### 2. `awk` -- Column-Oriented Processing

`awk` splits every line into fields by whitespace (default). Fields are `$1`, `$2`, `$3`, etc. `$0` is the entire line.

**Printing fields**:
```bash
awk '{print $1}' file.txt               # Print the first field of each line
awk '{print $1, $3}' file.txt           # Print fields 1 and 3 (space-separated)
awk '{print $NF}' file.txt              # Print the last field on each line
```

**Custom field separator** (`-F`):
```bash
awk -F ',' '{print $1, $3}' data.csv    # Use comma as delimiter
awk -F ':' '{print $1}' /etc/passwd     # Colon-delimited (like cut)
awk -F ',' '{print $2 " costs " $4}' report.csv  # Build custom output
```

**Pattern matching** (only process lines that match):
```bash
awk '/error/' file.txt                  # Print lines containing "error" (like grep)
awk '/error/ {print $1, $4}' file.txt   # Print fields 1 and 4 from error lines
awk '$3 > 100' data.txt                 # Print lines where field 3 > 100
awk '$5 == "North"' data.csv            # Lines where field 5 equals "North"
awk 'NR > 1' data.csv                   # Skip the header row (line number > 1)
```

**Built-in variables**:

| Variable | Meaning |
|----------|---------|
| `NR` | Current line number (Number of Records) |
| `NF` | Number of fields on the current line |
| `$0` | The entire current line |
| `$1`..`$N` | Individual fields |
| `FS` | Field separator (default: whitespace) |
| `OFS` | Output field separator (default: space) |

```bash
awk '{print NR, $0}' file.txt           # Add line numbers
awk '{print NF}' file.txt               # How many fields per line
awk 'NR==5' file.txt                    # Print only line 5
awk 'NR>=10 && NR<=20' file.txt         # Print lines 10-20
```

**Calculations**:
```bash
awk '{sum += $3} END {print sum}' data.txt                # Sum of field 3
awk '{sum += $3; count++} END {print sum/count}' data.txt # Average of field 3
awk '{if ($3 > max) max=$3} END {print max}' data.txt     # Max of field 3
```

**BEGIN and END blocks** (run before/after processing):
```bash
awk 'BEGIN {print "=== Report ==="} {print $0} END {print "=== Done ==="}' file.txt

# More practical — CSV report with header
awk -F ',' 'BEGIN {print "Product | Qty"} NR>1 {print $2 " | " $3}' data.csv
```

**Formatted output with `printf`**:
```bash
awk -F ',' 'NR>1 {printf "%-15s %5d %8.2f\n", $2, $3, $4}' data.csv
```

---

## Hands-On Exercises

### Setup: Use the Sample Data
Sample files are included in the `sample-data/` directory -- no need to create anything.

```bash
cd sample-data/
ls -la
```

**Files included:**
| File | What It Simulates | Lines |
|------|-------------------|-------|
| `server-config.conf` | Nginx-style web server configuration | 70+ |
| `sales-report.csv` | Daily product sales with regions | 28 |
| `auth.log` | Authentication log (SSH + web app) | 30 |
| `messy-data.txt` | Poorly formatted name records | 22 |

> All exercises below assume you are inside the `sample-data/` directory.

---

### Exercise 1: Basic sed Substitution

```bash
# Replace "example.com" with "mysite.io" in the config (preview, not saved)
sed 's/example.com/mysite.io/g' server-config.conf

# Replace "warn" log level with "notice" in the config
sed 's/warn/notice/' server-config.conf

# Change the keepalive_timeout from 65 to 120
sed 's/keepalive_timeout  65/keepalive_timeout  120/' server-config.conf

# Replace "localhost:3000" with "app-server:8080"
sed 's/localhost:3000/app-server:8080/g' server-config.conf

# Change the client_max_body_size from 10m to 50m
sed 's/client_max_body_size 10m/client_max_body_size 50m/' server-config.conf
```

**What you should see**: Each command prints the full file with substitutions applied, but the original file is unchanged. This is how you test before using `-i`.

---

### Exercise 2: sed Deletion and Line Selection

```bash
# Remove all comment lines from the config
sed '/^[[:space:]]*#/d' server-config.conf

# Remove all blank lines
sed '/^$/d' server-config.conf

# Remove both comments and blank lines at once
sed '/^[[:space:]]*#/d; /^$/d' server-config.conf

# Show only lines 35-55 (the server block)
sed -n '35,55p' server-config.conf

# Delete the first 4 lines (the comment header)
sed '1,4d' server-config.conf

# Show only lines containing "proxy"
sed -n '/proxy/p' server-config.conf
```

---

### Exercise 3: sed for Config Management

```bash
# Uncomment the gzip line (enable gzip compression)
sed 's/#gzip  on/gzip  on/' server-config.conf

# Uncomment tcp_nopush
sed 's/#tcp_nopush     on/tcp_nopush     on/' server-config.conf

# Comment out the server_tokens line (security hardening)
sed 's/server_tokens on/# server_tokens on/' server-config.conf

# Enable the HTTPS redirect (uncomment it)
sed 's/# return 301/return 301/' server-config.conf

# Change the rate limit from 10r/s to 50r/s
sed 's/rate=10r\/s/rate=50r\/s/' server-config.conf

# Change the static file expiry from 30d to 7d
sed 's/expires 30d/expires 7d/' server-config.conf

# Chain multiple config changes together
sed 's/#gzip  on/gzip  on/; s/server_tokens on/server_tokens off/; s/keepalive_timeout  65/keepalive_timeout  30/' server-config.conf
```

---

### Exercise 4: Basic awk Field Extraction

```bash
# Print just the product names from the sales report (field 2)
awk -F ',' 'NR>1 {print $2}' sales-report.csv

# Print date and quantity sold
awk -F ',' 'NR>1 {print $1, $3}' sales-report.csv

# Print product and total line value (quantity * unit_price)
awk -F ',' 'NR>1 {print $2, $3 * $4}' sales-report.csv

# Print formatted: product name padded to 12 chars, then revenue
awk -F ',' 'NR>1 {printf "%-12s $%8.2f\n", $2, $3 * $4}' sales-report.csv

# Print only sales from the North region
awk -F ',' '$5 == "North"' sales-report.csv

# Print high-quantity orders (more than 15 units)
awk -F ',' 'NR>1 && $3 > 15 {print $1, $2, $3}' sales-report.csv
```

---

### Exercise 5: awk Calculations

```bash
# Total units sold across all rows
awk -F ',' 'NR>1 {sum += $3} END {print "Total units sold:", sum}' sales-report.csv

# Total revenue across all rows
awk -F ',' 'NR>1 {sum += ($3 * $4)} END {printf "Total revenue: $%.2f\n", sum}' sales-report.csv

# Average quantity per order
awk -F ',' 'NR>1 {sum += $3; count++} END {printf "Avg quantity: %.1f\n", sum/count}' sales-report.csv

# Revenue per product
awk -F ',' 'NR>1 {rev[$2] += ($3 * $4)} END {for (p in rev) printf "%-12s $%8.2f\n", p, rev[p]}' sales-report.csv

# Total units sold per region
awk -F ',' 'NR>1 {units[$5] += $3} END {for (r in units) print r, units[r]}' sales-report.csv

# Count of orders per product
awk -F ',' 'NR>1 {count[$2]++} END {for (p in count) print p, count[p], "orders"}' sales-report.csv

# Find the single largest order by revenue
awk -F ',' 'NR>1 {rev = $3 * $4; if (rev > max) {max = rev; line = $0}} END {print "Biggest order:", line, "-> $" max}' sales-report.csv
```

---

### Exercise 6: Parsing the Auth Log with sed and awk

```bash
# Extract just the timestamps and messages (remove PID details)
sed 's/\[[0-9]*\]//' auth.log

# Show only failed login lines
awk '/Failed/' auth.log

# Extract IPs from failed SSH attempts
awk '/Failed password/ {print $11}' auth.log

# Count failed SSH attempts per source IP
awk '/Failed password/ {print $11}' auth.log | sort | uniq -c | sort -rn

# Extract webapp login failures — show user and IP
awk '/WARN.*Login failed/ {for(i=1;i<=NF;i++) if($i ~ /^user=/) print $i, $(i+1)}' auth.log

# Show all fail2ban actions
awk '/fail2ban/ {print $1, $2, $5, $6, $7}' auth.log

# Count successful vs failed logins for the web app
echo "Successful logins:"
awk '/Login successful/' auth.log | wc -l
echo "Failed logins:"
awk '/Login failed/' auth.log | wc -l

# Get a timeline: just the hour and event type
awk '{split($2, t, ":"); hour=t[1]} /Accepted|successful/ {ok[hour]++} /Failed|failed/ {fail[hour]++} END {for (h in ok) printf "%s:00 - OK: %d, FAIL: %d\n", h, ok[h], fail[h]+0}' auth.log
```

---

### Exercise 7: Cleaning Messy Data with sed

```bash
# Look at the mess first
cat messy-data.txt

# Step 1: Remove leading whitespace
sed 's/^[[:space:]]*//' messy-data.txt

# Step 2: Remove trailing whitespace
sed 's/[[:space:]]*$//' messy-data.txt

# Step 3: Squeeze multiple spaces into one
sed 's/  */ /g' messy-data.txt

# Step 4: Remove blank lines
sed '/^[[:space:]]*$/d' messy-data.txt

# Step 5: Standardize the label to "Name:" (mixed case "name:", "NAME:", etc.)
sed 's/^[[:space:]]*[Nn][Aa][Mm][Ee]:/Name:/' messy-data.txt

# Combine all cleanup steps into one pipeline
sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s/  */ /g; /^$/d; s/^[Nn][Aa][Mm][Ee]:/Name:/' messy-data.txt
```

**What you should see**: The final combined command produces clean, consistent lines -- no extra whitespace, no blank lines, uniform "Name:" labels.

---

### Exercise 8: Formatted Reports with awk

```bash
# Full sales report with headers and totals
awk -F ',' '
BEGIN {
    printf "%-12s %-12s %6s %10s %10s\n", "Date", "Product", "Qty", "Price", "Revenue"
    printf "%-12s %-12s %6s %10s %10s\n", "----", "-------", "---", "-----", "-------"
}
NR > 1 {
    rev = $3 * $4
    total += rev
    printf "%-12s %-12s %6d %10.2f %10.2f\n", $1, $2, $3, $4, rev
}
END {
    printf "%-12s %-12s %6s %10s %10s\n", "----", "-------", "---", "-----", "-------"
    printf "%-12s %-12s %6s %10s %10.2f\n", "", "", "", "TOTAL:", total
}' sales-report.csv

# Auth log summary report
awk '
BEGIN {print "===== Authentication Report =====\n"}
/Accepted|successful/ {ok++}
/Failed|failed/ {fail++}
/fail2ban.*Ban/ {bans++}
/Session expired/ {expired++}
END {
    print "Successful authentications:", ok
    print "Failed attempts:", fail
    print "IPs banned by fail2ban:", bans
    print "Sessions expired:", expired
    print "\n===== End Report ====="
}' auth.log
```

---

### Exercise 9: Combining sed and awk

```bash
# Clean the messy data with sed, then format it with awk
sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s/  */ /g; /^$/d; s/^[Nn][Aa][Mm][Ee]:/Name:/' messy-data.txt | \
  awk -F ':' '{gsub(/^[ ]+/, "", $2); print NR ". " $2}'

# Extract proxy settings from config (sed to find, awk to format)
sed -n '/location \/api/,/}/p' server-config.conf | \
  sed 's/^[[:space:]]*//' | \
  awk 'NF > 0 {print "  -> " $0}'

# From auth.log: get failed login users, clean up with sed, count with awk
grep "Login failed" auth.log | \
  sed 's/.*user=\([^ ]*\).*/\1/' | \
  sort | uniq -c | sort -rn | \
  awk '{printf "User %-10s had %d failed attempts\n", $2, $1}'

# Generate a clean CSV from the messy data file
sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s/  */ /g; /^$/d; s/^[Nn][Aa][Mm][Ee]://' messy-data.txt | \
  awk '{
    first = toupper(substr($1,1,1)) tolower(substr($1,2))
    last  = toupper(substr($2,1,1)) tolower(substr($2,2))
    printf "%s,%s\n", first, last
  }'
```

---

### Exercise 10: Challenge -- Build a Daily Sales Dashboard

```bash
# You are the data analyst. Using ONLY sed and awk (plus pipes),
# answer these questions from sales-report.csv:
#
# 1. What is the total revenue per region?
#
# 2. Which product generated the most revenue overall?
#
# 3. Which single day had the highest total sales?
#
# 4. Print a clean report showing: for each region, the total units,
#    total revenue, and average order value — formatted as a table.
#
# 5. BONUS: From auth.log, produce a "security score" for the day:
#    score = (successful_logins / total_attempts) * 100
#    Print it as a percentage.
#
# --- Try solving each before looking below ---
```

<details>
<summary>Click to reveal solutions</summary>

```bash
# 1. Total revenue per region
awk -F ',' 'NR>1 {rev[$5] += ($3 * $4)} END {for (r in rev) printf "%-8s $%10.2f\n", r, rev[r]}' sales-report.csv

# 2. Product with the most revenue
awk -F ',' 'NR>1 {rev[$2] += ($3 * $4)} END {for (p in rev) if (rev[p] > max) {max = rev[p]; best = p} print best, "$" max}' sales-report.csv

# 3. Day with the highest total sales
awk -F ',' 'NR>1 {rev[$1] += ($3 * $4)} END {for (d in rev) if (rev[d] > max) {max = rev[d]; best = d} printf "%s  $%.2f\n", best, max}' sales-report.csv

# 4. Region summary table
awk -F ',' '
BEGIN {
    printf "%-8s %8s %12s %12s\n", "Region", "Units", "Revenue", "Avg Order"
    printf "%-8s %8s %12s %12s\n", "------", "-----", "-------", "---------"
}
NR > 1 {
    units[$5] += $3
    rev[$5]   += ($3 * $4)
    count[$5]++
}
END {
    for (r in rev)
        printf "%-8s %8d %12.2f %12.2f\n", r, units[r], rev[r], rev[r]/count[r]
}' sales-report.csv

# 5. BONUS: Security score from auth.log
awk '
/Accepted|successful/ {ok++}
/Failed|failed/        {fail++}
END {
    total = ok + fail
    score = (ok / total) * 100
    printf "Security Score: %.1f%% (%d/%d successful)\n", score, ok, total
}' auth.log
```

</details>

---

## Quick Reference

| Command | What It Does |
|---------|-------------|
| `sed 's/old/new/' file` | Replace first occurrence per line |
| `sed 's/old/new/g' file` | Replace all occurrences per line |
| `sed -i 's/old/new/g' file` | Replace in-place (modifies the file) |
| `sed -i.bak 's/old/new/g' file` | Replace in-place with backup |
| `sed '/pattern/d' file` | Delete lines matching pattern |
| `sed '/^$/d' file` | Delete blank lines |
| `sed '/^#/d' file` | Delete comment lines |
| `sed -n '5,10p' file` | Print only lines 5-10 |
| `sed '1i\text' file` | Insert text before line 1 |
| `awk '{print $1}' file` | Print first field |
| `awk -F ',' '{print $2}' file` | Print field 2, comma-delimited |
| `awk '/pattern/' file` | Print lines matching pattern |
| `awk '$3 > 10' file` | Print lines where field 3 > 10 |
| `awk 'NR>1' file` | Skip the first line (header) |
| `awk '{sum+=$1} END {print sum}'` | Sum a column |
| `awk 'BEGIN{...} {...} END{...}'` | Pre-process, process, post-process |

---

## Checklist

- [ ] I can use `sed s/old/new/g` to find and replace text
- [ ] I can use `sed -i` for in-place editing (and know to test without it first)
- [ ] I can use `sed` to delete lines by pattern (`/pattern/d`) or by number
- [ ] I can use `sed` address ranges to target specific lines
- [ ] I can use `awk` to extract and print specific fields
- [ ] I can use `awk -F` to set custom field separators
- [ ] I can use `awk` pattern matching to filter rows
- [ ] I can use `awk` with `BEGIN`/`END` blocks and calculations
- [ ] I can combine `sed` and `awk` with pipes for multi-step transformations
- [ ] I can build formatted reports with `awk printf`

---

> **Tomorrow (Day 6)**: I/O Redirection -- stdin, stdout, stderr, pipes, and redirecting output to files.
