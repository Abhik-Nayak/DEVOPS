# Day 1: Linux Filesystem & Navigation

## Goal
Understand the Linux directory structure and master basic navigation commands.

---

## Theory: Linux Directory Structure

Linux follows the **Filesystem Hierarchy Standard (FHS)**. Everything starts from `/` (root).

```
/
├── bin/       → Essential user binaries (ls, cp, mv, cat)
├── sbin/      → System binaries (iptables, reboot, fdisk)
├── etc/       → Configuration files (nginx.conf, ssh config, crontab)
├── home/      → User home directories (/home/abhik, /home/devops)
├── root/      → Home directory for the root user
├── var/       → Variable data (logs, databases, mail, spool)
│   ├── log/   → System and application logs
│   └── tmp/   → Temporary files preserved between reboots
├── tmp/       → Temporary files (cleared on reboot)
├── opt/       → Optional/third-party software
├── usr/       → User programs and data
│   ├── bin/   → Non-essential user binaries
│   ├── lib/   → Libraries
│   └── local/ → Locally installed software
├── dev/       → Device files (disks, terminals)
├── proc/      → Virtual filesystem for process/kernel info
├── sys/       → Virtual filesystem for hardware/kernel info
├── mnt/       → Temporary mount points
├── media/     → Removable media (USB, CD-ROM)
└── boot/      → Boot loader files (kernel, grub)
```

### Key Directories to Remember for DevOps

| Directory | Why It Matters |
|-----------|---------------|
| `/etc/` | All config files live here — nginx, ssh, cron, network |
| `/var/log/` | Logs — first place to check when debugging |
| `/tmp/` | Temp storage — scripts often use this for scratch files |
| `/opt/` | Third-party tools (Terraform, Jenkins agents, etc.) |
| `/home/` | User workspace — your scripts and projects go here |

---

## Commands to Learn

### 1. `pwd` — Print Working Directory
Shows your current location in the filesystem.
```bash
pwd
# Output: /home/abhik
```

### 2. `ls` — List Directory Contents
```bash
ls              # Basic listing
ls -l           # Long format (permissions, owner, size, date)
ls -a           # Show hidden files (files starting with .)
ls -la          # Long format + hidden files
ls -lh          # Human-readable file sizes (KB, MB, GB)
ls -lt          # Sort by modification time (newest first)
ls -lS          # Sort by file size (largest first)
ls -R           # Recursive listing (show subdirectories)
```

**Reading `ls -l` output:**
```
-rw-r--r-- 1 abhik devops 4096 May 29 10:00 script.sh
│────┬────│ │  │     │     │        │          └── filename
│    │    │ │  │     │     │        └── last modified date
│    │    │ │  │     │     └── file size in bytes
│    │    │ │  │     └── group
│    │    │ │  └── owner
│    │    │ └── number of hard links
│    └────── permissions (owner/group/others)
└────────── file type (- = file, d = directory, l = symlink)
```

### 3. `cd` — Change Directory
```bash
cd /var/log         # Go to an absolute path
cd log              # Go to a relative path (subdirectory)
cd ..               # Go up one directory
cd ../..            # Go up two directories
cd ~                # Go to home directory
cd -                # Go to previous directory (toggle)
cd                  # Go to home directory (same as cd ~)
```

### 4. `mkdir` — Make Directory
```bash
mkdir projects                  # Create a single directory
mkdir -p a/b/c/d                # Create nested directories (-p = parents)
mkdir dir1 dir2 dir3            # Create multiple directories at once
mkdir -p project/{src,bin,docs} # Create multiple subdirectories
```

### 5. `rmdir` — Remove Empty Directory
```bash
rmdir emptydir          # Only works on EMPTY directories
rmdir -p a/b/c          # Remove nested empty directories
# For non-empty directories, use: rm -r dirname (careful!)
```

### 6. `tree` — Display Directory Tree
```bash
tree                    # Show full tree from current directory
tree -L 2              # Limit depth to 2 levels
tree -d                # Show only directories
tree -a                # Include hidden files
tree /etc -L 1         # Tree of a specific path
```
> Note: `tree` may need to be installed: `sudo apt install tree` (Ubuntu) or `sudo yum install tree` (Amazon Linux)

### 7. Bonus Navigation Commands
```bash
which python3           # Find where a command is located
whoami                  # Show current username
hostname                # Show machine hostname
uname -a                # Show system information
clear                   # Clear the terminal screen (or Ctrl+L)
```

---

## Hands-On Exercises

### Exercise 1: Explore the Filesystem
Run each command and observe the output:
```bash
pwd
cd /
ls -la
cd /etc
ls | head -20
cd /var/log
ls -lt | head -10
cd ~
pwd
```

### Exercise 2: Create a Project Structure
Build the following structure using only `mkdir`:
```
~/devops-lab/
├── scripts/
│   ├── bash/
│   └── python/
├── configs/
│   ├── nginx/
│   └── docker/
├── logs/
└── backups/
```

**Solution:**
```bash
#This creates the devops-lab structure inside whatever directory you're currently in.
mkdir -p devops-lab/{scripts/{bash,python},configs/{nginx,docker},logs,backups}
tree devops-lab

#This creates the devops-lab structure in root folder.
mkdir -p ~/devops-lab/{scripts/{bash,python},configs/{nginx,docker},logs,backups}
tree ~/devops-lab
```

### Exercise 3: Navigation Challenge
```bash
# Start from home
cd ~

# Go to /var/log — check what's there
cd /var/log
ls -lt | head -5

# Go back to home in ONE command
cd ~

# Create a temp workspace and navigate into it
mkdir -p /tmp/day01-practice
cd /tmp/day01-practice

# Go back to the PREVIOUS directory (should be home)
cd -

# Verify
pwd
```

### Exercise 4: Write Your First Script (Preview)
Create a simple script that displays system info:
```bash
# Create the script
cat > ~/devops-lab/scripts/bash/system-info.sh << 'EOF'
#!/bin/bash
echo "===== System Information ====="
echo "User     : $(whoami)"
echo "Hostname : $(hostname)"
echo "Directory: $(pwd)"
echo "Date     : $(date)"
echo "OS Info  : $(uname -a)"
echo "=============================="
EOF

# Make it executable
chmod +x ~/devops-lab/scripts/bash/system-info.sh

# Run it
~/devops-lab/scripts/bash/system-info.sh
```

---

## Quick Reference Cheat Sheet

| Command | What It Does |
|---------|-------------|
| `pwd` | Print current directory |
| `ls -la` | List all files with details |
| `ls -lh` | List with human-readable sizes |
| `cd /path` | Go to absolute path |
| `cd ..` | Go up one level |
| `cd ~` | Go to home directory |
| `cd -` | Toggle to previous directory |
| `mkdir -p a/b/c` | Create nested directories |
| `rmdir dir` | Remove empty directory |
| `tree -L 2` | Show directory tree (2 levels) |
| `which cmd` | Find command location |
| `whoami` | Show current user |

---

## Checklist

- [ ] I can explain what `/etc`, `/var/log`, `/tmp`, `/opt`, and `/home` are used for
- [ ] I can navigate the filesystem using `cd` with absolute and relative paths
- [ ] I can use `cd -` to toggle between two directories
- [ ] I can read and understand `ls -l` output (permissions, owner, size, date)
- [ ] I can create nested directory structures with `mkdir -p`
- [ ] I can use brace expansion: `mkdir -p project/{src,bin,docs}`
- [ ] I ran the system-info script successfully

---

## Tips

- **Tab completion**: Press `Tab` to auto-complete file/directory names — saves time and avoids typos
- **Up arrow**: Press `Up` to recall previous commands
- **Ctrl+R**: Reverse search through command history
- **Ctrl+L**: Clear screen (same as `clear`)
- **Ctrl+A / Ctrl+E**: Jump to start / end of the command line

---

> **Tomorrow (Day 2)**: File operations — `touch`, `cp`, `mv`, `rm`, `cat`, `head`, `tail` and more.
