# 30 Days of Shell Scripting, Linux Commands & Python

A structured 30-day learning plan covering Linux commands, Bash shell scripting, and Python — tailored for DevOps engineers.

---

## Week 1: Linux Commands & Bash Basics (Days 1–7)

### Day 1 — Linux Filesystem & Navigation
- Commands: `pwd`, `ls`, `cd`, `mkdir`, `rmdir`, `tree`
- Understand the Linux directory structure (`/etc`, `/var`, `/home`, `/tmp`, `/opt`)
- Practice: Navigate and create a nested folder structure

### Day 2 — File Operations
- Commands: `touch`, `cp`, `mv`, `rm`, `cat`, `head`, `tail`, `less`, `more`
- File timestamps and metadata: `stat`, `file`
- Practice: Create, copy, move, and inspect files

### Day 3 — File Permissions & Ownership
- Commands: `chmod`, `chown`, `chgrp`, `umask`
- Understand symbolic (`rwx`) and numeric (`755`) permission modes
- Practice: Set permissions for a shared project directory

### Day 4 — Text Processing (Part 1)
- Commands: `grep`, `sort`, `uniq`, `wc`, `cut`, `tr`
- Regular expression basics with `grep -E`
- Practice: Parse a log file — extract error lines, count occurrences

### Day 5 — Text Processing (Part 2)
- Commands: `awk`, `sed`, `diff`, `comm`
- `awk` field processing and `sed` find-and-replace
- Practice: Transform a CSV file and compare two config files

### Day 6 — I/O Redirection & Piping
- Concepts: `stdin`, `stdout`, `stderr`
- Operators: `>`, `>>`, `<`, `2>`, `2>&1`, `|`, `tee`
- Practice: Chain commands with pipes to build a mini data pipeline

### Day 7 — First Bash Script
- Shebang (`#!/bin/bash`), script execution, `chmod +x`
- Variables, `echo`, `read`, comments
- Practice: Write a script that takes a username and creates a welcome message

---

## Week 2: Shell Scripting Deep Dive (Days 8–14)

### Day 8 — Conditionals
- `if`, `elif`, `else`, `fi`
- Test operators: `-f`, `-d`, `-z`, `-n`, `-eq`, `-gt`, `-lt`
- String and file comparisons
- Practice: Script to check if a file/directory exists and report its type

### Day 9 — Loops
- `for`, `while`, `until` loops
- `break`, `continue`, loop over files and command output
- Practice: Script to rename all `.txt` files in a directory to `.bak`

### Day 10 — Functions & Return Values
- Defining and calling functions
- Local variables, passing arguments (`$1`, `$2`, `$@`, `$#`)
- Return codes and `$?`
- Practice: Write a library of utility functions (logging, validation)

### Day 11 — Arrays & String Manipulation
- Indexed arrays, associative arrays
- String length, substring, replacement, pattern matching
- Practice: Script to parse a list of servers and ping each one

### Day 12 — Process Management
- Commands: `ps`, `top`, `htop`, `kill`, `killall`, `nohup`, `&`, `jobs`, `fg`, `bg`
- Process IDs, signals (`SIGTERM`, `SIGKILL`, `SIGHUP`)
- Practice: Script to monitor a process and restart it if it dies

### Day 13 — Scheduling & Automation
- `cron`, `crontab -e`, cron syntax
- `at` for one-time scheduling
- Practice: Schedule a daily log cleanup script

### Day 14 — Networking Commands
- Commands: `ping`, `curl`, `wget`, `netstat`/`ss`, `dig`, `nslookup`, `traceroute`, `ip`, `ifconfig`
- Practice: Script to check health of a list of URLs and send a report

---

## Week 3: Python Fundamentals (Days 15–21)

### Day 15 — Python Setup & Basics
- Install Python, `pip`, virtual environments (`venv`)
- Variables, data types (`int`, `float`, `str`, `bool`)
- `input()`, `print()`, f-strings
- Practice: Script to take user input and perform basic calculations

### Day 16 — Control Flow in Python
- `if`, `elif`, `else`
- `for` and `while` loops
- `range()`, `enumerate()`, `zip()`
- Practice: FizzBuzz and a number guessing game

### Day 17 — Data Structures
- Lists, tuples, sets, dictionaries
- List comprehensions, dictionary comprehensions
- Common methods: `append`, `extend`, `pop`, `get`, `keys`, `values`
- Practice: Script to count word frequency in a text file

### Day 18 — Functions & Modules
- Defining functions, `*args`, `**kwargs`, default parameters
- Importing modules, creating your own module
- `os`, `sys`, `math` built-in modules
- Practice: Build a CLI calculator as a module

### Day 19 — File Handling
- `open()`, `read()`, `write()`, `readlines()`
- Context managers (`with` statement)
- Working with CSV: `csv` module
- Practice: Read a CSV of servers, write a filtered report

### Day 20 — Error Handling & Logging
- `try`, `except`, `finally`, `raise`
- Custom exceptions
- `logging` module: levels, formatters, handlers
- Practice: Add robust error handling and logging to a previous script

### Day 21 — Working with JSON & APIs
- `json` module: `loads()`, `dumps()`, `load()`, `dump()`
- `requests` library: `GET`, `POST`, status codes, headers
- Practice: Fetch weather data from a public API and display it

---

## Week 4: DevOps Integration & Projects (Days 22–28)

### Day 22 — Python + OS Automation
- `os` module: `os.path`, `os.listdir()`, `os.walk()`, `os.makedirs()`
- `shutil` module: copy, move, archive
- `subprocess` module: run shell commands from Python
- Practice: Script to organize files in a directory by extension

### Day 23 — Shell + Python: Log Analyzer
- Parse logs with both Bash (`grep`, `awk`) and Python
- Compare approaches: when to use shell vs Python
- Practice: Build a log analyzer that extracts top errors and generates a summary

### Day 24 — Python + AWS (Boto3 Basics)
- Install and configure `boto3`
- List S3 buckets, EC2 instances
- Upload/download files to S3
- Practice: Script to list all running EC2 instances and their details

### Day 25 — Shell Script: Server Setup Automation
- Automate package installation, user creation, firewall setup
- Use functions, error handling, and logging in Bash
- Practice: Write a server bootstrap script for a fresh Ubuntu/Amazon Linux instance

### Day 26 — Python: Infrastructure Reporter
- Use `boto3` or `subprocess` to gather infra data
- Generate a Markdown or HTML report
- Practice: Build a daily infrastructure health report generator

### Day 27 — CI/CD Helper Scripts
- Shell scripts for build, test, deploy pipelines
- Python script to parse and report test results
- Practice: Write a deployment script that pulls code, runs tests, and deploys

### Day 28 — Docker + Scripting
- Docker CLI commands: `build`, `run`, `exec`, `logs`, `ps`, `stop`
- Shell script to build and push Docker images
- Python script to interact with Docker via `subprocess` or `docker` SDK
- Practice: Automate Docker image build, tag, and push workflow

---

## Days 29–30: Capstone Projects

### Day 29 — Capstone: Automated System Monitor
Build a complete monitoring solution using both Bash and Python:
- **Bash component**: Collect CPU, memory, disk usage; check running services
- **Python component**: Parse collected data, detect anomalies, send alerts
- Generate a daily HTML report
- Schedule via cron

### Day 30 — Capstone: DevOps Toolkit
Build a CLI toolkit that combines everything learned:
- **Bash scripts**: Server health check, log rotator, backup script
- **Python scripts**: AWS resource auditor, deployment automator, config validator
- Organize with proper project structure, README, and usage docs
- Push to GitHub as a portfolio project

---

## Folder Structure

```
30-Days-Shell-Python/
├── README.md
├── week-1-linux-bash-basics/
│   ├── day-01-filesystem/
│   ├── day-02-file-operations/
│   ├── day-03-permissions/
│   ├── day-04-text-processing-1/
│   ├── day-05-text-processing-2/
│   ├── day-06-io-redirection/
│   └── day-07-first-script/
├── week-2-shell-scripting/
│   ├── day-08-conditionals/
│   ├── day-09-loops/
│   ├── day-10-functions/
│   ├── day-11-arrays-strings/
│   ├── day-12-process-mgmt/
│   ├── day-13-scheduling/
│   └── day-14-networking/
├── week-3-python/
│   ├── day-15-python-basics/
│   ├── day-16-control-flow/
│   ├── day-17-data-structures/
│   ├── day-18-functions-modules/
│   ├── day-19-file-handling/
│   ├── day-20-error-handling/
│   └── day-21-json-apis/
├── week-4-devops-projects/
│   ├── day-22-os-automation/
│   ├── day-23-log-analyzer/
│   ├── day-24-boto3/
│   ├── day-25-server-setup/
│   ├── day-26-infra-reporter/
│   ├── day-27-cicd-scripts/
│   └── day-28-docker/
└── capstone/
    ├── day-29-system-monitor/
    └── day-30-devops-toolkit/
```

---

## Resources

| Topic | Resource |
|-------|----------|
| Bash | [GNU Bash Manual](https://www.gnu.org/software/bash/manual/) |
| Linux Commands | [Linux Command Library](https://linuxcommandlibrary.com/) |
| Python | [Python Official Docs](https://docs.python.org/3/) |
| Boto3 (AWS) | [Boto3 Documentation](https://boto3.amazonaws.com/v1/documentation/api/latest/) |
| Shell Scripting | [ShellCheck](https://www.shellcheck.net/) — lint your scripts |
| Practice | [OverTheWire Bandit](https://overthewire.org/wargames/bandit/) — Linux CLI challenges |

---

> **Tip**: Create a script or notes file in each day's folder. Commit daily to track your progress.
