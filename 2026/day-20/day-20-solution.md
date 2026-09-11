# Day 20 – Bash Scripting Challenge: Log Analyzer and Report Generator

## Objective

Write a Bash script (`log_analyzer.sh`) that analyzes a log file and generates a daily summary report — counting errors, listing critical events, finding the most common error messages, and saving everything to a report file.

---

## Final Script – `log_analyzer.sh`

```bash
#!/bin/bash

# Task 1: Input and Validation

if [ $# -eq 0 ]; then
    echo "Error: No log file path provided."
    exit 1
fi

log_file=$1

if [[ ! -f "$log_file" ]]; then
    echo "Error: File does not exist."
    exit 1
fi

echo "Log file found: $log_file"

# Task 2: Error Count

error_count=$(grep -E "ERROR|Failed" "$log_file" | wc -l)

echo "Total errors found: $error_count"

# Task 3: Critical Events

echo ""
echo "--- Critical Events ---"
grep -n "CRITICAL" "$log_file"

# Task 4: Top Error Messages

echo ""
echo "--- Top 5 Error Messages ---"
grep "ERROR" "$log_file" | awk '{$1=$2=$3=""; print}' | sort | uniq -c | sort -rn | head -5

# Task 5: Summary Report

report_date=$(date +%Y-%m-%d)
report_file="log_report_$report_date.txt"

{
    echo "Log Analysis Report"
    echo "Date: $report_date"
    echo "Log file: $log_file"
    echo ""
    echo "Total lines processed: $(wc -l < "$log_file")"
    echo "Total errors found: $error_count"
    echo ""
    echo "--- Top 5 Error Messages ---"
    grep "ERROR" "$log_file" | awk '{$1=$2=$3=""; print}' | sort | uniq -c | sort -rn | head -5
    echo ""
    echo "--- Critical Events ---"
    grep -n "CRITICAL" "$log_file"
} > "$report_file"

echo ""
echo "Report saved to: $report_file"
```

---

## How It Works, Task by Task

**Task 1 – Input and Validation**
- `$#` → number of arguments passed to the script; `-eq 0` checks if none were given
- `-f "$log_file"` → checks the given path is a real file

**Task 2 – Error Count**
- `grep -E "ERROR|Failed"` → finds lines with either word (`-E` enables `|` as OR)
- `wc -l` → counts the matching lines
- `$(...)` → captures that count into a variable

**Task 3 – Critical Events**
- `grep -n "CRITICAL"` → finds lines with CRITICAL, `-n` adds line numbers

**Task 4 – Top Error Messages**
- `grep "ERROR"` → gets all ERROR lines
- `awk '{$1=$2=$3=""; print}'` → erases the date, time, and "ERROR" label (fields 1-3), leaving just the message
- `sort` → groups identical messages together (required before `uniq` works)
- `uniq -c` → removes duplicates, adds a count of how many times each appeared
- `sort -rn` → sorts by that count, highest first
- `head -5` → shows only the top 5

**Task 5 – Summary Report**
- `date +%Y-%m-%d` → gets today's date in `YYYY-MM-DD` format
- `report_file="log_report_$report_date.txt"` → builds the report's filename (just text, no file yet)
- `{ commands } > "$report_file"` → groups multiple commands together and redirects their combined output into the report file, creating it in the process

---

## Sample Output

Running against a log file with repeated errors:

```text
Log file found: sample_log.log
Total errors found: 8

--- Critical Events ---
6:2026-02-11 08:19:33 CRITICAL Disk space below threshold
11:2026-02-11 08:24:12 CRITICAL Database connection lost

--- Top 5 Error Messages ---
      4    Connection timed out
      2    File not found
      1    Permission denied
```

Generated report file (`log_report_2026-09-11.txt`):
```text
Log Analysis Report
Date: 2026-09-11
Log file: sample_log.log

Total lines processed: 15
Total errors found: 8

--- Top 5 Error Messages ---
      4    Connection timed out
      2    File not found
      1    Permission denied

--- Critical Events ---
6:2026-02-11 08:19:33 CRITICAL Disk space below threshold
11:2026-02-11 08:24:12 CRITICAL Database connection lost
```

---

## Commands/Tools Used

- `grep` — search for lines matching a pattern (`-E`, `-n`)
- `awk` — split lines into fields and edit/print specific ones
- `sort` — arrange lines alphabetically or numerically (`-r`, `-n`)
- `uniq` — remove duplicate lines, count occurrences (`-c`)
- `wc` — count lines/words in text
- `date` — get the current date in a custom format

---

## What I Learned

1. `grep -E "A|B"` lets you match multiple keywords in one search instead of running separate greps.
2. Piping `sort | uniq -c | sort -rn` is a common pattern for "count how often each item repeats, most frequent first" — sort must always come before `uniq` since `uniq` only removes duplicates that are next to each other.
3. Wrapping multiple commands in `{ ... } > file` redirects all their combined output into one file at once, instead of adding `> file` after every single line.
