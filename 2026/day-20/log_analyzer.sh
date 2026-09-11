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
