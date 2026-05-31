# Day 2: File Operations

## Goal
Master creating, copying, moving, deleting, and viewing files from the command line.

---

## Commands to Learn

### 1. `touch` — Create Empty Files / Update Timestamps
```bash
touch file.txt                  # Create an empty file (or update its timestamp)
touch file1.txt file2.txt       # Create multiple files
touch -t 202501011200 file.txt  # Set a specific timestamp (YYYYMMDDhhmm)
```

### 2. `cp` — Copy Files and Directories
```bash
cp source.txt dest.txt          # Copy a file
cp source.txt /tmp/             # Copy to another directory (keeps original name)
cp -r dir1/ dir2/               # Copy a directory recursively (-r is required for dirs)
cp -i source.txt dest.txt       # Interactive — prompts before overwriting
cp -v file.txt /tmp/            # Verbose — shows what's being copied
cp file1.txt file2.txt dir/     # Copy multiple files into a directory
cp -p source.txt dest.txt       # Preserve permissions, ownership, and timestamps
```

### 3. `mv` — Move or Rename Files
```bash
mv old.txt new.txt              # Rename a file
mv file.txt /tmp/               # Move to another directory
mv file.txt /tmp/renamed.txt    # Move and rename in one step
mv -i file.txt /tmp/            # Interactive — prompts before overwriting
mv dir1/ dir2/                  # Rename a directory (no -r needed unlike cp)
mv *.log /var/log/archive/      # Move all .log files
```

### 4. `rm` — Remove Files and Directories
```bash
rm file.txt                     # Delete a file (gone forever — no trash can)
rm -i file.txt                  # Interactive — asks for confirmation
rm -r directory/                # Delete a directory and everything inside it
rm -f file.txt                  # Force — no prompts, no errors if file doesn't exist
rm -rf directory/               # Force-delete a directory recursively
```
> **Warning**: `rm` is permanent. There is no undo. Always double-check before running `rm -rf`.

### 5. `cat` — Display File Contents
```bash
cat file.txt                    # Print entire file to screen
cat file1.txt file2.txt         # Concatenate and print multiple files
cat -n file.txt                 # Show line numbers
cat > newfile.txt               # Create a file by typing (Ctrl+D to save)
cat >> file.txt                 # Append to an existing file
```

### 6. `head` and `tail` — View Start or End of a File
```bash
head file.txt                   # First 10 lines (default)
head -n 5 file.txt              # First 5 lines
head -c 100 file.txt            # First 100 bytes

tail file.txt                   # Last 10 lines (default)
tail -n 20 file.txt             # Last 20 lines
tail -f /var/log/syslog         # Follow — live stream new lines as they're written
tail -f -n 50 /var/log/syslog   # Follow, starting with last 50 lines
```
> `tail -f` is essential for monitoring logs in real time. `Ctrl+C` to stop.

### 7. `less` and `more` — Paginate Through Files
```bash
less file.txt                   # Scroll through a file (q to quit)
more file.txt                   # Similar but simpler (only scrolls forward)
```
**`less` navigation:**
| Key | Action |
|-----|--------|
| `Space` / `f` | Page forward |
| `b` | Page backward |
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` | Next search result |
| `g` / `G` | Jump to start / end |
| `q` | Quit |

### 8. `wc` — Word Count
```bash
wc file.txt                     # Lines, words, characters
wc -l file.txt                  # Line count only
wc -w file.txt                  # Word count only
wc -c file.txt                  # Byte count
wc -l *.txt                     # Line count for multiple files
```

### 9. `diff` — Compare Files
```bash
diff file1.txt file2.txt        # Show differences between two files
diff -u file1.txt file2.txt     # Unified format (like git diff)
diff -y file1.txt file2.txt     # Side-by-side comparison
```

### 10. `ln` — Create Links
```bash
ln -s /path/to/original link_name   # Create a symbolic (soft) link
ln /path/to/original link_name      # Create a hard link
ls -l link_name                     # Verify — symlinks show -> target
```
> Symlinks are used everywhere in DevOps — linking configs, binaries, log directories.

---

## Hands-On Exercises

### Exercise 1: File CRUD Basics
```bash
cd /tmp && mkdir day02-lab && cd day02-lab

# Create files
touch app.log config.yaml deploy.sh notes.txt

# Verify
ls -l

# Copy
cp config.yaml config.yaml.bak

# Rename
mv notes.txt README.md

# Delete
rm app.log

# Check what's left
ls -l
```

### Exercise 2: Working with File Content
```bash
# Create a file with content
cat > servers.txt << 'EOF'
web-01  192.168.1.10  nginx
web-02  192.168.1.11  nginx
db-01   192.168.1.20  postgres
db-02   192.168.1.21  postgres
cache-01 192.168.1.30 redis
EOF

# View it
cat -n servers.txt

# First 2 lines
head -n 2 servers.txt

# Last 2 lines
tail -n 2 servers.txt

# Count lines
wc -l servers.txt
```

### Exercise 3: Bulk File Operations
```bash
mkdir -p project/{src,config,logs,backups}

# Create files
touch project/src/{main.py,utils.py,test_main.py}
touch project/config/{dev.yaml,prod.yaml}
touch project/logs/app.log

# Copy the entire project as a backup
cp -r project/ project-backup/

# Move all config files to backups
cp project/config/*.yaml project/backups/

# Compare the two directories
diff -r project/ project-backup/

# Clean up
rm -rf project/ project-backup/
```

### Exercise 4: Log Monitoring Simulation
```bash
# Create a fake log generator script
cat > log-gen.sh << 'EOF'
#!/bin/bash
for i in $(seq 1 20); do
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Request $i processed" >> app.log
    sleep 0.5
done
EOF
chmod +x log-gen.sh

# In one terminal, start the log generator
./log-gen.sh &

# In the same terminal, watch the log in real time
tail -f app.log
# Press Ctrl+C to stop watching

# Check total lines written
wc -l app.log

# View last 5 entries
tail -n 5 app.log

# Clean up
rm app.log log-gen.sh
```

### Exercise 5: Symlinks in Practice
```bash
mkdir -p /tmp/symlink-lab/{v1,v2}
echo "app version 1" > /tmp/symlink-lab/v1/app.conf
echo "app version 2" > /tmp/symlink-lab/v2/app.conf

# Point "current" to v1
ln -s /tmp/symlink-lab/v1 /tmp/symlink-lab/current
cat /tmp/symlink-lab/current/app.conf

# "Deploy" v2 — just switch the symlink
rm /tmp/symlink-lab/current
ln -s /tmp/symlink-lab/v2 /tmp/symlink-lab/current
cat /tmp/symlink-lab/current/app.conf

# This is exactly how tools like Capistrano and many deploy systems work
ls -l /tmp/symlink-lab/current

# Clean up
rm -rf /tmp/symlink-lab
```

---

## Quick Reference

| Command | What It Does |
|---------|-------------|
| `touch file` | Create empty file / update timestamp |
| `cp src dest` | Copy file |
| `cp -r dir1 dir2` | Copy directory |
| `mv old new` | Move or rename |
| `rm file` | Delete file |
| `rm -rf dir` | Delete directory recursively |
| `cat file` | Print file contents |
| `cat > file` | Write to file (Ctrl+D to save) |
| `head -n N file` | First N lines |
| `tail -n N file` | Last N lines |
| `tail -f file` | Follow file in real time |
| `less file` | Paginate through file |
| `wc -l file` | Count lines |
| `diff f1 f2` | Compare two files |
| `ln -s target link` | Create symlink |

---

## Checklist

- [ ] I can create, copy, move, and delete files and directories
- [ ] I know the difference between `cp` and `mv`
- [ ] I can use `cat`, `head`, and `tail` to view file contents
- [ ] I can monitor a log file in real time with `tail -f`
- [ ] I understand `rm -rf` and why it's dangerous
- [ ] I can create and use symbolic links
- [ ] I can compare files with `diff`

---

> **Tomorrow (Day 3)**: Permissions & ownership — `chmod`, `chown`, `chgrp`, and understanding `rwx`.
