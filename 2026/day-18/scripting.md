# Day 18 – Shell Scripting: Functions & Intermediate Concepts

## Objective

- Learn how to create and use **functions**.
- Understand **strict mode** with `set -euo pipefail`.
- Learn **return values** and **local variables**.
- Build a practical **system information script**.

---

## Task 1 – Basic Functions

Created `functions.sh` to practice creating, calling, and passing arguments to functions.

```bash
#!/bin/bash

greet() {
    echo "Hello, $1!"
}

add() {
    echo $(( $1 + $2 ))
}

greet "Jackson"
add 10 20
```

**How it works:**
- `greet()` → a function to print a greeting.
- `$1` → the first argument passed to the function.
- `add()` → a function that adds two numbers.
- `$1` and `$2` → first and second arguments.
- `greet "Jackson"` and `add 10 20` → calling the functions.

**Output:**
```text
Hello, Jackson!
30
```

<img width="463" height="226" alt="Meg-1" src="https://github.com/user-attachments/assets/a7d9ee3e-b7b6-4bf6-8cdd-1050402ce2bd" />

---

## Task 2 – Functions with System Checks

Created `disk_check.sh` using separate functions to check disk usage and memory usage.

```bash
#!/bin/bash

check_disk() {
    df -h /
}

check_memory() {
    free -h
}

echo "=== Disk Usage ==="
check_disk

echo "=== Memory Usage ==="
check_memory
```

**How it works:**
- `check_disk()` → checks disk usage of `/`.
- `check_memory()` → checks available memory.
- `df -h /` → disk usage in human-readable format.
- `free -h` → memory usage in human-readable format.
- The functions are called from the main part of the script.

**Output:**

<img width="587" height="338" alt="Meg-2" src="https://github.com/user-attachments/assets/54b8232b-77ce-493e-a82f-574f69bbbc09" />

---

## Task 3 – Strict Mode

Practiced Bash strict mode using three separate scripts.

### 1. `set -u` – undefined variables

```bash
#!/bin/bash

set -u

echo "Starting script"
echo "$name"
echo "Script finished"
```

`set -u` treats an undefined variable as an error and stops the script.

<img width="438" height="182" alt="Meg-3" src="https://github.com/user-attachments/assets/3422df68-86a8-4649-810f-0b8c36e0657a" />

### 2. `set -e` – command failure

```bash
#!/bin/bash

set -e

echo "Step 1"
ls /this-does-not-exist
echo "Step 2"
```

`set -e` stops the script when an unhandled command fails.

<img width="490" height="209" alt="Meg-4" src="https://github.com/user-attachments/assets/c9128ea3-5542-47c8-96dd-0e6cd7b8b591" />

### 3. `set -o pipefail` – pipeline failures

```bash
#!/bin/bash

set -o pipefail

echo "Testing pipe"
ls /wrong-path | wc -l
echo "Script finished"
```

`pipefail` makes the pipeline's exit status non-zero if any command inside it fails. On its own, it does **not** stop the script.

<img width="434" height="310" alt="Meg-5" src="https://github.com/user-attachments/assets/83fe50bf-1c11-4443-84ef-a63a8df19806" />

### Strict mode combined

These three are commonly combined:

```bash
set -euo pipefail
```

- `-e` → stop on command failure
- `-u` → catch undefined variables
- `pipefail` → detect failures inside pipelines

---

## Task 4 – Local Variables

Practiced the difference between `local` variables and regular variables inside functions.

### 1. Using `local`

```bash
#!/bin/bash

name="Jackson"

show_local() {
    local name="Alice"
    echo "Inside function: $name"
}

show_local

echo "Outside function: $name"
```

**Output:**
```text
Inside function: Alice
Outside function: Jackson
```

`local` keeps the variable inside the function only.

### 2. Without `local`

```bash
#!/bin/bash

name="Jackson"

show_regular() {
    name="Alice"
    echo "Inside function: $name"
}

show_regular

echo "Outside function: $name"
```

**Output:**
```text
Inside function: Alice
Outside function: Alice
```

Without `local`, the function changes the existing outer variable.

**Key point:**
- `local` → variable belongs only to the function.
- No `local` → the function can change the variable outside itself too.

<img width="445" height="224" alt="Meg-6" src="https://github.com/user-attachments/assets/89511091-e176-4a70-982b-b83b6dc46e14" />

---

## Task 5 – System Information Reporter

Created `system_info.sh` to collect useful information from a Linux server.

```bash
#!/bin/bash

set -euo pipefail

show_system_info() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "OS: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2)"
}

show_uptime() {
    echo
    echo "=== Uptime ==="
    uptime
}

show_disk_usage() {
    echo
    echo "=== Top 5 Disk Usage ==="
    du -xh / | sort -h | tail -5
}

show_memory_usage() {
    echo
    echo "=== Memory Usage ==="
    free -h
}

show_cpu_processes() {
    echo
    echo "=== Top 5 CPU Processes ==="
    ps -eo pid,comm,%cpu --sort=-%cpu | head -6
}

main() {
    show_system_info
    show_uptime
    show_disk_usage
    show_memory_usage
    show_cpu_processes
}

main
```

**What it checks:**
- **Hostname & OS** → identifies the server.
- **Uptime** → how long the system has been running.
- **Disk usage** → top 5 largest disk usage entries.
- **Memory** → RAM usage.
- **CPU processes** → top 5 processes by CPU usage.
- **Strict mode** (`set -euo pipefail`) → makes the script safer.
- **Functions** → keep each check separate and reusable.

---

## What I Learned

- Functions make Bash scripts cleaner, reusable, and easier to manage.
- `local` variables prevent functions from accidentally changing variables outside themselves.
- `set -euo pipefail` makes scripts safer and easier to troubleshoot.

## Key Takeaways

- Use functions to organize or reuse the same type of task.
- Use `local` for variables that should only exist inside a function.
- `-e` → stop when a command fails
- `-u` → catch undefined variables
- `pipefail` → detect failures inside pipelines and change the pipeline's exit status
- `$1`, `$2`, etc. → access function arguments
- `$?` → check the exit status of the previous command
