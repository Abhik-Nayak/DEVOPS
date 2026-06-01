# Day 3: Permissions & Ownership

## Goal
Understand Linux file permissions, ownership, and how to control who can read, write, or execute files.

---

## Core Concepts

### How Linux Permissions Work

Every file and directory has three permission groups:
| Group | Who |
|-------|-----|
| **Owner (u)** | The user who owns the file |
| **Group (g)** | Users in the file's group |
| **Others (o)** | Everyone else |

Each group can have three permission types:
| Symbol | Permission | On Files | On Directories |
|--------|-----------|----------|----------------|
| `r` | Read | View contents | List contents (`ls`) |
| `w` | Write | Modify contents | Create/delete files inside |
| `x` | Execute | Run as program | Enter directory (`cd`) |

### Reading Permission Strings
```
-rwxr-xr--  1  alice  devops  4096  Jan 15 10:30  deploy.sh
│├──┤├──┤├──┤     │      │
│  u    g    o   owner  group
│
└── File type: - = file, d = directory, l = symlink
```
- `rwx` = owner can read + write + execute
- `r-x` = group can read + execute (no write)
- `r--` = others can only read

### Numeric (Octal) Notation
Each permission is a bit: `r=4`, `w=2`, `x=1`. Add them up per group.

| Symbolic | Numeric | Meaning |
|----------|---------|---------|
| `rwx` | 7 | Read + Write + Execute |
| `rw-` | 6 | Read + Write |
| `r-x` | 5 | Read + Execute |
| `r--` | 4 | Read only |
| `---` | 0 | No permissions |

**Common patterns:**
| Numeric | Symbolic | Typical Use |
|---------|----------|-------------|
| `755` | `rwxr-xr-x` | Scripts, executables, directories |
| `644` | `rw-r--r--` | Regular files (configs, docs) |
| `700` | `rwx------` | Private scripts, `.ssh/` directory |
| `600` | `rw-------` | Private keys, secrets |
| `777` | `rwxrwxrwx` | **Avoid!** Everyone can do everything |

---

## Commands to Learn

### 1. `chmod` — Change File Permissions
**Symbolic mode:**
```bash
chmod u+x script.sh                # Add execute for owner
chmod g-w file.txt                 # Remove write for group
chmod o-rwx secret.key             # Remove all permissions for others
chmod u+rwx,g+rx,o+r file.txt     # Set multiple at once
chmod a+r file.txt                 # Add read for all (a = all = u+g+o)
chmod +x script.sh                 # Add execute for all (shorthand)
```

**Numeric mode:**
```bash
chmod 755 script.sh                # rwxr-xr-x — standard for scripts
chmod 644 config.yaml              # rw-r--r-- — standard for config files
chmod 600 id_rsa                   # rw------- — private keys
chmod 700 .ssh/                    # rwx------ — private directories
```

**Recursive:**
```bash
chmod -R 755 project/              # Apply to directory and everything inside
chmod -R g+w shared/               # Add group write recursively
```

### 2. `chown` — Change File Ownership
```bash
chown alice file.txt               # Change owner to alice
chown alice:devops file.txt        # Change owner and group
chown :devops file.txt             # Change group only
chown -R alice:devops project/     # Change ownership recursively
```
> **Note**: `chown` requires `sudo` unless you're the root user.

### 3. `chgrp` — Change Group Ownership
```bash
chgrp devops file.txt              # Change group to devops
chgrp -R devops project/           # Change group recursively
```
> `chgrp` is a shortcut — `chown :devops file.txt` does the same thing.

### 4. `umask` — Set Default Permissions for New Files
```bash
umask                              # Show current umask (e.g., 0022)
umask 022                          # New files: 644, new dirs: 755 (default)
umask 077                          # New files: 600, new dirs: 700 (strict)
umask 002                          # New files: 664, new dirs: 775 (group-friendly)
```
**How umask works:**
- Files start at `666` (no execute by default), directories at `777`
- Umask is *subtracted*: `666 - 022 = 644`, `777 - 022 = 755`

### 5. `stat` — View Detailed File Info
```bash
stat file.txt                      # Full details: permissions, owner, timestamps
stat -c "%a %U %G %n" file.txt    # Custom format: numeric-perms owner group name
```

### 6. `id` — View User & Group Info
```bash
id                                 # Your user ID, group ID, and groups
id alice                           # Check another user's info
groups                             # List groups you belong to
```

---

## Hands-On Exercises

### Exercise 1: Understanding Permission Strings
```bash
cd /tmp && mkdir day03-lab && cd day03-lab

# Create files and observe default permissions
touch regular-file.txt
mkdir new-directory
cat > script.sh << 'EOF'
#!/bin/bash
echo "Hello from script!"
EOF

# Inspect permissions
ls -la
stat -c "%a %A %n" regular-file.txt new-directory script.sh

# Notice: files default to 644, directories to 755 (with umask 022)
```

### Exercise 2: Making Scripts Executable
```bash
# Try to run the script — fails without execute permission
./script.sh

# Add execute permission
chmod +x script.sh

# Now it works
./script.sh

# Check the change
ls -l script.sh
# Should show: -rwxr-xr-x
```

### Exercise 3: Securing Sensitive Files
```bash
# Create files representing secrets
echo "DB_PASSWORD=super_secret" > .env
echo "-----BEGIN RSA PRIVATE KEY-----" > id_rsa
echo "api_key: abc123xyz" > credentials.yaml

# Check current permissions — too open!
ls -l .env id_rsa credentials.yaml

# Lock them down
chmod 600 .env id_rsa credentials.yaml

# Verify — only owner can read/write
ls -l .env id_rsa credentials.yaml

# Try as "others" would see it — stat shows numeric perms
stat -c "File: %n | Perms: %a | Owner: %U" .env id_rsa credentials.yaml
```

### Exercise 4: Shared Project Directory
```bash
# Simulate a shared team project
mkdir -p shared-project/{src,docs,deploy}
touch shared-project/src/{app.py,utils.py}
touch shared-project/docs/README.md
touch shared-project/deploy/deploy.sh

# Make deploy script executable
chmod 755 shared-project/deploy/deploy.sh

# Set permissions for collaboration
# Source code: owner read/write, group read, others none
chmod -R 640 shared-project/src/
# Docs: everyone can read
chmod -R 644 shared-project/docs/
# Directories need execute to be accessible
chmod 750 shared-project/src/
chmod 755 shared-project/docs/
chmod 750 shared-project/deploy/

# Review the full tree
ls -lR shared-project/
```

### Exercise 5: Umask Experimentation
```bash
# Check current umask
umask

# Create a file with default umask
touch default-perms.txt
ls -l default-perms.txt

# Set strict umask
umask 077

# Create another file
touch strict-perms.txt
ls -l strict-perms.txt

# Compare — strict file should be 600, default should be 644
ls -l default-perms.txt strict-perms.txt

# Set group-friendly umask
umask 002
touch group-friendly.txt
ls -l group-friendly.txt
# Should be 664

# Reset to default
umask 022

# Clean up
cd /tmp && rm -rf day03-lab
```

---

## Real-World DevOps Scenarios

### SSH Key Permissions
```bash
# SSH is strict about permissions — wrong perms = connection refused
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa            # Private key — owner only
chmod 644 ~/.ssh/id_rsa.pub        # Public key — readable by all
chmod 600 ~/.ssh/authorized_keys   # Who can log in
chmod 644 ~/.ssh/config            # SSH client config
```

### Web Server File Permissions
```bash
# Typical web server setup
chmod -R 755 /var/www/html/        # Web root: readable + executable
chmod -R 644 /var/www/html/*.html  # HTML files: readable
chmod 600 /var/www/html/.htaccess  # Config: owner only
```

### Fixing "Permission Denied" — A Troubleshooting Checklist
```bash
# 1. Check the file's permissions
ls -la /path/to/file

# 2. Check who you are
whoami
id

# 3. Check the full path — every parent directory needs 'x'
namei -l /path/to/file

# 4. Fix as needed
chmod +x script.sh                 # If you need to run it
chmod +r config.yaml               # If you need to read it
sudo chown $USER file.txt          # If ownership is wrong
```

---

## Quick Reference

| Command | What It Does |
|---------|-------------|
| `chmod 755 file` | Set rwxr-xr-x (numeric) |
| `chmod u+x file` | Add execute for owner (symbolic) |
| `chmod -R 644 dir/` | Set permissions recursively |
| `chown user:group file` | Change owner and group |
| `chgrp group file` | Change group only |
| `umask 022` | Set default perms (files: 644, dirs: 755) |
| `stat file` | View detailed file info |
| `id` | Show your user/group info |
| `ls -la` | List files with permissions |
| `namei -l /path` | Check permissions along entire path |

---

## Checklist

- [ ] I can read a permission string like `-rwxr-xr--` and explain what it means
- [ ] I understand numeric notation (`755`, `644`, `600`) and can convert between symbolic and numeric
- [ ] I can use `chmod` to change permissions (both symbolic and numeric modes)
- [ ] I understand why `chmod 600` is critical for SSH keys and secrets
- [ ] I know how `umask` controls default permissions for new files
- [ ] I can troubleshoot "Permission denied" errors
- [ ] I understand the difference between `chown` and `chgrp`

---

> **Tomorrow (Day 4)**: Users, groups, and the superuser — `useradd`, `groupadd`, `sudo`, and `/etc/passwd`.
