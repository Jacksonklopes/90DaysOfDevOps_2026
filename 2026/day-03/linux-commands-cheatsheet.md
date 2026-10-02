# Linux Command Cheat Sheet

A basic Linux command reference for my DevOps learning journey.

## 1. System & User Commands

| Command  | Meaning                                    |
| -------- | ------------------------------------------ |
| `clear`  | Clears the terminal screen                 |
| `whoami` | Shows the currently logged-in user         |
| `pwd`    | Shows the current working directory        |
| `date`   | Shows the current date and time            |
| `uptime` | Shows how long the system has been running |

## 2. File System Commands

| Command  | Meaning                                           |
| -------- | ------------------------------------------------- |
| `ls`     | Lists files and directories                       |
| `ls -a`  | Lists all files, including hidden files           |
| `ls -la` | Lists all files with detailed information         |
| `cd`     | Changes the current directory                     |
| `mkdir`  | Creates a new directory                           |
| `touch`  | Creates a new empty file                          |
| `cp`     | Copies files or directories                       |
| `mv`     | Moves or renames files/directories                |
| `rm`     | Removes files or directories                      |
| `cat`    | Displays the contents of a file                   |
| `less`   | Views file contents one screen at a time          |
| `head`   | Displays the first lines of a file                |
| `tail`   | Displays the last lines of a file                 |
| `find`   | Searches for files and directories                |
| `file`   | Shows the type of a file                          |
| `df -h`  | Shows disk space usage in a human-readable format |

## 3. Process Management

| Command   | Meaning                                            |
| --------- | -------------------------------------------------- |
| `ps`      | Shows running processes for the current shell      |
| `ps aux`  | Shows detailed information about running processes |
| `top`     | Monitors running processes and resource usage      |
| `Kill -9 <pid>`    | kill -9 <PID>    # Forcefully terminate the process using SIGKILL (signal 9)                        |
| `free -h` | Shows RAM/memory usage in a human-readable format  |

## 4. Networking & Troubleshooting

| Command   | Meaning                                                       |
| --------- | ------------------------------------------------------------- |
| `ping`    | Tests network connectivity to a host                          |
| `ip addr` | Shows network interfaces and IP addresses                     |
| `curl`    | Makes HTTP requests and can be used to test HTTP connectivity |
| `dig`     | Checks DNS information and performs DNS queries               |

## Quick Reference

| Category               | Commands                                                                                            |
| ---------------------- | --------------------------------------------------------------------------------------------------- |
| **System & User**      | `clear`, `whoami`, `pwd`, `date`, `uptime`                                                          |
| **File System**        | `ls`, `cd`, `mkdir`, `touch`, `cp`, `mv`, `rm`, `cat`, `less`, `head`, `tail`, `find`, `file`, `df` |
| **Process Management** | `ps`, `ps aux`, `top`, `kill`, `free`                                                               |
| **Networking**         | `ping`, `ip addr`, `curl`, `dig`                                                                    |
