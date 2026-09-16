# Day 22 – Introduction to Git

## Objective

Learn the basics of Git by creating a local repository, making commits, viewing changes, and understanding the Git workflow.

---

## What is Git?

Git is a distributed version control system used to track changes in files and manage the history of a project.

It allows me to:

- Track changes made to files
- Save different versions of my work
- See what changed between versions
- Go back to an earlier version when needed
- Work with others on the same project

## Git Setup

```bash
git --version
git config --global user.name "jacksonlop"
git config --global user.email "lopesjackson636@gmail.com"
git config --global --list
```

<img width="584" height="74" alt="fak-1" src="https://github.com/user-attachments/assets/fe1bfd34-65f5-4b5e-be8c-3158eaf882b5" />

---

## Repository Setup

```bash
mkdir devops-git-practice
cd devops-git-practice
git init
git status
ls -la .git
```

<img width="445" height="237" alt="fak-2" src="https://github.com/user-attachments/assets/666a44d2-a62b-44a7-be85-cd7bf4c106ad" />

`git init` creates a new Git repository by creating the `.git` directory — this is what turns a normal folder into one Git tracks.

---

## Basic Git Workflow

Created `spider.txt` and practiced:

```bash
git status
git add spider.txt
git diff
git diff --staged
git restore --staged spider.txt
git commit -m "Add spider practice file"
```

<img width="716" height="422" alt="fak-3" src="https://github.com/user-attachments/assets/f7314759-2fee-4db0-8642-e28ec025afe7" />

Also made additional changes and created multiple commits to build a commit history.

---

## Viewing History

```bash
git log
git log --oneline
```

<img width="539" height="406" alt="fak-4" src="https://github.com/user-attachments/assets/10d31f87-cd97-4fc1-9ce9-1332d4e6aee8" />

`git log --oneline` displays commits in a short, compact format — one line per commit, useful for quickly scanning history.

---

## The Git Workflow

```text
Working Directory
       ↓
    git add
       ↓
Staging Area
       ↓
   git commit
       ↓
   Repository
```

**Working Directory** — the files currently being created or edited.

**Staging Area** — the changes selected with `git add`, waiting to go into the next commit.

**Repository** — the Git database containing committed changes and full project history.

---

## Important Commands

| Command | Meaning |
|---------|---------|
| `git init` | Creates a new Git repository |
| `git status` | Shows the current Git state |
| `git add` | Stages changes |
| `git diff` | Shows unstaged changes |
| `git diff --staged` | Shows staged changes |
| `git commit` | Saves staged changes as a commit |
| `git log` | Shows commit history |
| `git log --oneline` | Shows compact commit history |
| `git restore --staged` | Removes a file from the staging area (undoes `git add`, keeps the actual content) |
| `git restore` | Discards changes in the working directory (only works on already-tracked files) |

---

## What I Learned

- Git tracks changes to files through commits.
- `git add` moves changes into the staging area.
- `git commit` saves staged changes into the repository.
- `git diff` shows changes that are NOT staged yet.
- `git diff --staged` shows changes that ARE staged.
- The `.git` directory contains the internal data Git needs to track the repository.
- Multiple commits build a history that can be viewed with `git log`.

---

## Hint

Always check:
```bash
git status
```
before and after important Git commands — it tells you what's modified, staged, untracked, or ready to commit.

---

## Files Created

```text
devops-git-practice/
├── .git/
├── git-commands.md
├── day-22-notes.md
└── spider.txt
```

## Git Workflow to Remember

```text
Edit → git status → git add → git diff --staged → git commit → git log
```
