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
./backup.sh /home/ubuntu/Sell_script /home/ubuntu/barkups
```

### Verification

```bash
ls -lh /home/ubuntu/barkups
```

<img width="645" height="110" alt="don-2" src="https://github.com/user-attachments/assets/c8ff212d-d515-40e0-b8c6-639ff96d2d91" />

---

## Task 3 – Crontab

**Cron** → a Linux scheduler that
