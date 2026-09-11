# Day 19 – Log Rotation, Backup & Cron Automation

## Task 1 – Log Rotation Script

### Objective

Create a script that:
- Compresses `.log` files older than 7 days using `gzip`
- Deletes `.gz` files older than 30 days
- Shows the number of compressed and deleted files
- Exits if the log directory does not exist

### Script

```bash
#!/bin/bash

# Get the log directory from the first argument
log_dir=$1

# Check if the directory exists
if [ ! -d "$log_dir" ]; then
    echo "Directory does not exist"
    exit 1
fi

# Find .log files older than 7 days
logs=($(find "$log_dir" -name "*.log" -mtime +7))

# Count the log files found
compressed_count=${#logs[@]}

# Compress each old log file
for log in "${logs[@]}"
do
    gzip "$log"
done

# Show the number of compressed files
echo "Compressed: $compressed_count files"

# Find .gz files older than 30 days
deleted_files=($(find "$log_dir" -name "*.gz" -mtime +30))

# Count the files found
deleted_count=${#deleted_files[@]}

# Delete each old compressed file
for file in "${deleted_files[@]}"
do
    rm -f "$file"
done

# Show the number of deleted files
echo "Deleted: $deleted_count files"
```

### Run the script

```bash
sudo ./log_rotate.sh /var/log/myapp
```

### Verification

```bash
ls -l /var/log/myapp
```

<img width="516" height="62" alt="don-1" src="https://github.com/user-attachments/assets/fe073890-863f-4dd5-bb77-68c5abdcaa86" />

---

## Task 2 – Server Backup Script

### Objective

Create a backup script that:
- Takes a source directory and backup destination as arguments
- Creates a timestamped `.tar.gz` backup
- Verifies that the backup was created
- Displays the backup name and size
- Deletes backups older than 14 days
- Exits if the source directory does not exist

### Script

```bash
#!/bin/bash

# Get source and backup directories from arguments
source_dir=$1
backup_dir=$2

# Check if the source directory exists
if [ ! -d "$source_dir" ]; then
    echo "Source directory does not exist"
    exit 1
fi

# Create the backup directory if it does not exist
mkdir -p "$backup_dir"

# Create a unique timestamp
timestamp=$(date +%Y-%m-%d-%H-%M-%S)

# Set the backup file name
backup_file="$backup_dir/backup-$timestamp.tar.gz"

# Create the compressed backup
tar -czf "$backup_file" "$source_dir"

# Check if the backup was created successfully
if [ ! -f "$backup_file" ]; then
    echo "Backup failed"
    exit 1
fi

# Display the backup name and size
echo "Backup created: $backup_file"
echo "Backup size: $(du -h "$backup_file" | cut -f1)"

# Delete backups older than 14 days
find "$backup_dir" -name "backup-*.tar.gz" -mtime +14 -delete

# Confirm old backups were removed
echo "Old backups deleted successfully"
```

### Run

```bash
./backup.sh /home/ubuntu/day-19 /home/ubuntu/backups
```

### Verification

```bash
ls -lh /home/ubuntu/backups
```

<img width="645" height="110" alt="don-2" src="https://github.com/user-attachments/assets/c8ff212d-d515-40e0-b8c6-639ff96d2d91" />

---

## Task 3 – Crontab

**Cron** → a Linux scheduler that runs commands/scripts automatically at set times.

### 1. Check existing cron jobs

```bash
crontab -l
```

If there are none, you'll see:
```text
no crontab for ubuntu
```

### 2. Open the crontab editor

```bash
crontab -e
```

The first time, Linux may ask you to choose an editor — I selected Vim.

### 3. Where to add cron entries

Cron entries are written inside the crontab editor, one per line. Example:

```cron
0 2 * * * /home/ubuntu/day-19/log_rotate.sh /var/log/myapp
```

Save and exit: `Esc` → `:wq` → `Enter`

### 4. Cron syntax

```text
* * * * * command
│ │ │ │ │
│ │ │ │ └── Day of week (0-7)
│ │ │ └──── Month (1-12)
│ │ └────── Day of month (1-31)
│ └──────── Hour (0-23)
└────────── Minute (0-59)
```

### 5. Cron entries for this project

**Log rotation – every day at 2 AM**
```cron
0 2 * * * /home/ubuntu/day-19/log_rotate.sh /var/log/myapp
```

**Backup – every Sunday at 3 AM**
```cron
0 3 * * 0 /home/ubuntu/day-19/backup.sh /home/ubuntu/day-19 /home/ubuntu/backups
```

**Health check – every 5 minutes**
```cron
*/5 * * * * /home/ubuntu/day-19/health_check.sh
```
> Note: this entry is documented for the challenge, but `health_check.sh` has not been created yet.

### 6. Verify cron jobs

```bash
crontab -l
```
Shows the cron jobs currently configured for the user.

**What each entry means:**
- `0 2 * * *` → every day at 2:00 AM
- `0 3 * * 0` → every Sunday at 3:00 AM
- `*/5 * * * *` → every 5 minutes

<img width="594" height="368" alt="dont-3" src="https://github.com/user-attachments/assets/69b04c99-04fd-48be-942a-3da4bb701d13" />

### Testing the backup cron job

For testing, temporarily changed the backup schedule to run every minute:

```cron
* * * * * /home/ubuntu/day-19/backup.sh /home/ubuntu/day-19 /home/ubuntu/backups
```

Checked the backup directory while waiting:

```bash
watch ls -l /home/ubuntu/backups/
```

This confirms a new `.tar.gz` backup was created on schedule.

After testing, changed the cron schedule back to the required Sunday 3 AM slot:

```cron
0 3 * * 0 /home/ubuntu/day-19/backup.sh /home/ubuntu/day-19 /home/ubuntu/backups
```

<img width="632" height="104" alt="don-4" src="https://github.com/user-attachments/assets/0fa1a553-774f-4d20-ae58-fded7c657c27" />

---

## Task 4 – Combine: Scheduled Maintenance Script

### Objective

Create a maintenance script that:
- Runs the backup script
- Logs maintenance activity to `/var/log/maintenance.log`
- Adds timestamps to the log
- Runs automatically through cron

### Script

```bash
#!/bin/bash

# File where maintenance output will be stored
LOG_FILE="/var/log/maintenance.log"

# Log when maintenance starts
echo "$(date): Maintenance started" >> "$LOG_FILE"

# Run the backup script
echo "$(date): Running backup" >> "$LOG_FILE"
/home/ubuntu/day-19/backup.sh /home/ubuntu/day-19 /home/ubuntu/backups >> "$LOG_FILE" 2>&1

# Log when maintenance finishes
echo "$(date): Maintenance completed" >> "$LOG_FILE"
```

### Make the script executable

```bash
chmod +x maintenance.sh
```

### Run the maintenance script

```bash
sudo ./maintenance.sh
```

### Check the maintenance log

```bash
sudo cat /var/log/maintenance.log
```

The log records when maintenance started, when the backup ran, and when maintenance completed.

### Check the backup

```bash
ls -lh /home/ubuntu/backups/
```

Confirms the maintenance script triggered the backup and created the `.tar.gz` archive.

### Cron entry

Run maintenance every day at 1 AM:

```cron
0 1 * * * /home/ubuntu/day-19/maintenance.sh
```

<img width="523" height="116" alt="don-5" src="https://github.com/user-attachments/assets/cbec2bae-0294-46ab-829e-8d132fd35437" />

---

## What I Learned

- Practiced automating log cleanup by compressing old logs and removing very old compressed logs.
- Learned how a backup script can create timestamped `.tar.gz` archives and remove outdated backups.
- Practiced using cron to schedule scripts automatically at specific times.
- Learned how to test a cron job by temporarily changing its schedule to run every minute and checking the backup directory.
- Understood how a maintenance script can combine a backup task with timestamped logging.
- Practiced checking script permissions, testing scripts manually, and verifying their output.
- Got more practical experience with script arguments, `find`, `gzip`, `tar`, cron scheduling, and error handling.

## Hint

When automating scripts with cron, always verify the script path, arguments, permissions, and output location before scheduling it.
