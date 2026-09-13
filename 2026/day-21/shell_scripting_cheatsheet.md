# Shell Scripting Cheat Sheet

A practical quick-reference guide covering Bash basics, conditionals, loops, functions, text processing, DevOps one-liners, and error handling — built from hands-on practice.

---

## Quick Reference Table

| Topic | Key Syntax | Example |
|-------|-----------|---------|
| Shebang | `#!/bin/bash` | first line of every script |
| Make executable | `chmod +x file.sh` | `chmod +x script.sh` |
| Run script | `./file.sh` | `./script.sh` |
| Comment | `# comment` | `echo "Hi" # inline comment` |
| Variable | `VAR="value"` | `NAME="DevOps"` |
| Use variable | `$VAR` / `"$VAR"` | `echo "$NAME"` |
| Read input | `read -p "text" VAR` | `read -p "Name: " NAME` |
| Arguments | `$0 $1 $# $@ $?` | `./script.sh arg1` |
| String compare | `[ "$a" = "$b" ]` | `[ -z "$a" ]` |
| Integer compare | `[ $a -gt 10 ]` | `[ $num -eq 5 ]` |
| File test | `[ -f file ]` | `[ -d /home ]` |
| If condition | `if [ cond ]; then` | `if [ -f file ]; then echo OK; fi` |
| Case statement | `case $v in ... esac` | `case $1 in start) echo run ;; esac` |
| AND / OR | `cmd1 && cmd2` / `cmd1 \|\| cmd2` | `mkdir test && cd test` |
| For loop | `for i in list; do` | `for i in 1 2 3; do echo $i; done` |
| C-style for | `for ((i=1;i<=3;i++))` | `for ((i=0;i<5;i++)); do echo $i; done` |
| While loop | `while [ cond ]; do` | `while [ $a -lt 5 ]; do echo $a; done` |
| Until loop | `until [ cond ]; do` | `until [ $a -gt 5 ]; do echo $a; done` |
| Break / Continue | `break` / `continue` | `if [ $i -eq 5 ]; then break; fi` |
| Function | `name() { ... }` | `greet(){ echo "Hi"; }` |
| Function return | `echo value` / `return 0` | `result=$(add 5 10)` |
| Local variable | `local var=value` | `local count=10` |
| grep | `grep pattern file` | `grep -i "error" log.txt` |
| awk | `awk '{print $1}' file` | `awk -F: '{print $1}' /etc/passwd` |
| sed | `sed 's/a/b/g' file` | `sed -i 's/foo/bar/g' file.txt` |
| cut | `cut -d: -f1 file` | `cut -d: -f1 /etc/passwd` |
| sort / uniq | `sort file \| uniq -c` | `sort -n numbers.txt` |
| tr | `tr 'a-z' 'A-Z'` | `echo hi \| tr 'a-z' 'A-Z'` |
| wc | `wc -l file` | `wc -w file.txt` |
| head / tail | `head -n 5 file` | `tail -f app.log` |
| Exit code | `$?` | `exit 0` / `exit 1` |
| Strict mode | `set -euo pipefail` | first lines after shebang |
| Debug mode | `set -x` / `set +x` | shows each command before running |
| Cleanup on exit | `trap cleanup EXIT` | runs `cleanup` no matter how script ends |

---

## 1. Basics

### Shebang
Tells the system which interpreter to use to run the script. Must be the very first line.
```bash
#!/bin/bash
```

### Running a script
```bash
chmod +x script.sh   # make it executable
./script.sh          # run it directly
bash script.sh       # or force it to run with bash, even without chmod
```

### Comments
```bash
# this is a single-line comment
echo "hello"   # this is an inline comment
```

### Variables
```bash
NAME="Jackson"        # declare
echo $NAME             # use (unquoted - risky with spaces)
echo "$NAME"           # use (quoted - safe, recommended)
echo '$NAME'           # single quotes - prints literally, no expansion
```

### Reading user input
```bash
read -p "Enter your name: " NAME
echo "Hello, $NAME"
```

### Command-line arguments
```bash
$0    # script name itself
$1    # first argument
$#    # total number of arguments
$@    # all arguments
$?    # exit code of the last command
```

---

## 2. Operators and Conditionals

### String comparisons
```bash
[ "$a" = "$b" ]     # equal
[ "$a" != "$b" ]    # not equal
[ -z "$a" ]         # true if string is empty
[ -n "$a" ]         # true if string is NOT empty
```

### Integer comparisons
```bash
[ "$a" -eq "$b" ]   # equal
[ "$a" -ne "$b" ]   # not equal
[ "$a" -lt "$b" ]   # less than
[ "$a" -gt "$b" ]   # greater than
[ "$a" -le "$b" ]   # less than or equal
[ "$a" -ge "$b" ]   # greater than or equal
```

### File test operators
```bash
[ -f file ]    # is a regular file
[ -d dir ]     # is a directory
[ -e path ]    # exists (file OR directory)
[ -r file ]    # is readable
[ -w file ]    # is writable
[ -x file ]    # is executable
[ -s file ]    # exists AND is not empty
```

### if / elif / else
```bash
if [ "$num" -gt 0 ]; then
    echo "Positive"
elif [ "$num" -lt 0 ]; then
    echo "Negative"
else
    echo "Zero"
fi
```

### Logical operators
```bash
[ "$a" -gt 0 ] && [ "$a" -lt 100 ]   # AND - both must be true
[ "$a" = "yes" ] || [ "$a" = "y" ]   # OR - either can be true
[ ! -f file ]                         # NOT - reverses true/false
```

### Case statements
```bash
case "$choice" in
    y)
        echo "You said yes"
        ;;
    n)
        echo "You said no"
        ;;
    *)
        echo "Invalid choice"
        ;;
esac
```

---

## 3. Loops

### for loop - list-based
```bash
for fruit in apple banana mango
do
    echo "$fruit"
done
```

### for loop - C-style
```bash
for (( i=0; i<5; i++ ))
do
    echo "$i"
done
```

### while loop
```bash
count=1
while [ "$count" -le 5 ]
do
    echo "$count"
    count=$((count + 1))
done
```

### until loop
Opposite of while - runs UNTIL the condition becomes true (keeps looping while it's false).
```bash
count=1
until [ "$count" -gt 5 ]
do
    echo "$count"
    count=$((count + 1))
done
```

### break and continue
```bash
for i in 1 2 3 4 5
do
    if [ "$i" -eq 3 ]; then
        break        # stops the loop completely
    fi
    echo "$i"
done

for i in 1 2 3 4 5
do
    if [ "$i" -eq 3 ]; then
        continue     # skips just this one round, keeps looping
    fi
    echo "$i"
done
```

### Looping over files
```bash
for file in *.log
do
    echo "Found: $file"
done
```

### Looping over command output
```bash
cat names.txt | while read line
do
    echo "Name: $line"
done
```

---

## 4. Functions

### Defining a function
```bash
greet() {
    echo "Hello, $1!"
}
```

### Calling a function
```bash
greet "Jackson"
```

### Passing arguments to functions
Inside a function, `$1`, `$2` etc. refer to the arguments given to the FUNCTION, not the script.
```bash
add() {
    echo $(( $1 + $2 ))
}

add 5 10   # prints 15
```

### return vs echo
- `return` → only works with NUMBERS (0-255), meant to signal success/failure (like an exit code), NOT to send back a usable value.
- `echo` → the standard way to "return" a real value from a function - capture it with `$(...)`.

```bash
# return - only good for a status/exit code (breaks above 255!)
check_even() {
    if [ $(( $1 % 2 )) -eq 0 ]; then
        return 0   # 0 = success/true in bash
    else
        return 1   # 1 = failure/false
    fi
}

check_even 4
echo $?     # prints 0 (success, since 4 is even)

# echo - use this when you actually want the VALUE back
add() {
    echo $(( $1 + $2 ))
}

result=$(add 200 100)
echo "$result"   # prints 300 (correct, no matter how big the number is)
```

### Local variables
```bash
name="Jackson"

show_local() {
    local name="Alice"    # only exists inside this function
    echo "Inside: $name"
}

show_local
echo "Outside: $name"    # still "Jackson", untouched
```

---

## 5. Text Processing Commands

### grep - search for patterns
```bash
grep "error" file.txt        # find lines containing "error"
grep -i "error" file.txt     # ignore case
grep -r "error" folder/      # search recursively through a folder
grep -c "error" file.txt     # count matching lines
grep -n "error" file.txt     # show line numbers
grep -v "error" file.txt     # show lines that DON'T match
grep -E "error|fail" file.txt # match either word (extended regex)
```

### awk - process columns
```bash
awk '{print $1}' file.txt              # print the 1st column
awk -F: '{print $1}' /etc/passwd       # use : as the column separator instead of space
awk '/error/ {print $0}' file.txt      # only process lines matching "error"
awk 'BEGIN {print "Start"} {print} END {print "Done"}' file.txt   # run something before/after processing
```

### sed - find and replace text
```bash
sed 's/old/new/' file.txt        # replace FIRST match per line (preview only)
sed 's/old/new/g' file.txt       # replace ALL matches per line (preview only)
sed '2d' file.txt                # delete line number 2 (preview only)
sed -i 's/old/new/g' file.txt    # edit the file directly (in-place), instead of just previewing
```
Note: without `-i`, `sed`/`grep`/`awk` only PREVIEW changes - the real file stays untouched.

### cut - extract specific columns
```bash
cut -d: -f1 /etc/passwd     # -d sets the separator (:), -f1 picks column 1
cut -d, -f2,3 file.csv      # pick columns 2 and 3 from a CSV
```

### sort - order lines
```bash
sort file.txt          # alphabetical order
sort -n file.txt        # numerical order
sort -r file.txt         # reverse order
sort -u file.txt         # sort AND remove duplicates
```

### uniq - deduplicate
```bash
sort file.txt | uniq         # remove duplicate lines (must sort first!)
sort file.txt | uniq -c      # also count how many times each line appeared
```

### tr - translate or delete characters
```bash
echo "hello" | tr 'a-z' 'A-Z'     # lowercase to uppercase
echo "h e l l o" | tr -d ' '      # delete all spaces
```

### wc - count lines/words/characters
```bash
wc -l file.txt      # count lines
wc -w file.txt       # count words
wc -c file.txt       # count characters/bytes
```

### head / tail - show first or last lines
```bash
head -5 file.txt       # show first 5 lines
tail -5 file.txt        # show last 5 lines
tail -f file.txt         # "follow" mode - keep watching the file live as new lines get added (great for logs)
```

---

## 6. Useful Patterns and One-Liners

### Find and delete files older than N days
```bash
find /var/log/myapp -name "*.log" -mtime +30 -delete
```

### Count lines in all .log files
```bash
wc -l *.log
```

### Replace a string across multiple files
```bash
sed -i 's/old_value/new_value/g' *.txt
```

### Check if a service is running
```bash
systemctl is-active --quiet nginx && echo "Running" || echo "Not running"
```

### Monitor disk usage with an alert
```bash
usage=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
if [ "$usage" -gt 80 ]; then
    echo "Warning: disk usage is at ${usage}%"
fi
```

### Find the most common error message in a log
```bash
grep "ERROR" app.log | awk '{$1=$2=$3=""; print}' | sort | uniq -c | sort -rn | head -5
```

### Tail a log and filter for errors in real time
```bash
tail -f app.log | grep --line-buffered "ERROR"
```

### Count how many times a service failed today
```bash
grep "$(date +%Y-%m-%d)" app.log | grep -c "Failed"
```

---

## 7. Error Handling and Debugging

### Exit codes
```bash
some_command
echo $?          # 0 = success, anything else = failure

exit 0           # explicitly exit with success
exit 1           # explicitly exit with failure
```

### set -e - stop on any command failure
```bash
set -e
```

### set -u - stop if using an undefined variable
```bash
set -u
```

### set -o pipefail - catch failures inside a pipe (|)
```bash
set -o pipefail
```

### All three combined (common at the top of real scripts)
```bash
set -euo pipefail
```

### set -x - debug mode (show each command as it runs)
```bash
set -x
echo "hello"
set +x    # turn debug mode back off
```
Every line starting with `+` in the output is bash showing the actual command it's about to run, with variables already filled in - useful for figuring out where a script is going wrong.

### trap - run a command automatically on exit
```bash
cleanup() {
    echo "Cleaning up before exit..."
    rm -f /tmp/tempfile
}

trap cleanup EXIT
```
Meaning: "when the script is about to end (X), automatically run `cleanup` (Y)" - no matter whether the script succeeds, fails, or is interrupted with Ctrl+C. Note: `trap` guarantees cleanup runs, but does NOT change or hide the script's real exit code.
