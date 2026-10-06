# Day 28 – Revision Day

## What I Did Today

Today I revised the topics I learned from **Day 1 to Day 27**.

I mainly revised:

* Linux
* Shell Scripting
* Networking
* Git & GitHub
* GitHub CLI

---

## Topics I Need to Revise More

### Linux

* Processes and services
* File permissions
* LVM
* Networking commands
* CIDR and subnets

### Shell Scripting

* Loops
* Functions
* `grep`, `awk`, `sed`
* Error handling
* Crontab

### Git & GitHub

* Rebase
* Cherry-pick
* Squash
* Reset vs Revert
* Git branching strategies
* GitHub CLI

---

## Quick Revision

### Linux

Some important commands I revised:

```bash
ls                         # List files
cd /path                   # Change directory
ps aux                     # Show running processes
top                        # Monitor processes
df -h                      # Check disk space
free -h                    # Check memory
systemctl status ssh       # Check service status
chmod 755 script.sh        # Change file permissions
chown user file.txt        # Change file owner
```

### Networking

```bash
ping google.com            # Test connectivity
curl google.com            # Test HTTP connection
ss -tulnp                  # Check listening ports
dig google.com             # Check DNS
```

I also revised:

* IP addresses
* DNS
* CIDR
* Subnets
* Common ports like 22, 53, 80 and 443

---

## Shell Scripting

I revised:

* Variables
* Conditions
* Loops
* Functions
* Arguments
* `grep`, `awk`, `sed`
* Error handling
* `crontab`

Example:

```bash
set -euo pipefail           # Make the script stop on common errors
```

---

## Git & GitHub

I revised:

* `git add`
* `git commit`
* `git push`
* `git pull`
* Branching
* Merge
* Rebase
* Stash
* Cherry-pick
* Squash
* Reset
* Revert
* GitHub Flow
* GitHub CLI

### Important Revision

**Reset** changes the existing Git history.

**Revert** creates a new commit to undo an earlier commit.

```bash
git reset --soft HEAD~1     # Undo commit, keep changes staged

git reset HEAD~1            # Undo commit, keep changes unstaged

git reset --hard HEAD~1     # Undo commit and remove changes

git revert <commit-id>      # Create a new commit to undo a commit
```

---

## Quick Questions I Revised

### chmod 755

```text
Owner   → read + write + execute
Group   → read + execute
Others  → read + execute
```

### Process vs Service

**Process** → a running program.

**Service** → a program managed by the system, usually using systemd.

### git fetch vs git pull

**fetch** → downloads changes.

**pull** → downloads and integrates changes.

### git stash

Temporarily saves my uncommitted changes.

```bash
git stash                   # Save changes temporarily
git stash pop               # Bring changes back
```

### Cron

Run a script every day at 3 AM:

```cron
0 3 * * * /path/to/script.sh
```

---

## What I Learned

Revision helped me find the topics I need to practice more.

I also understood that remembering commands is not enough. I should understand **what the command does and when to use it**.

I will continue to practice the topics I find difficult.

**Consistency over perfection.**
