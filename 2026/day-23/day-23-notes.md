# Day 23 – Git Branching & Working with GitHub
*DevOps Learning Notes*

## 🎯 Objective
Learn Git branching, switch between branches, push branches to GitHub, pull remote changes, and understand the difference between clone and fork.

---

## Task 1 — Understanding Branches

**1. What is a branch in Git?**
A branch is a separate line of development in Git. It allows me to work on changes separately without directly affecting another branch.

**2. Why use branches?**
Branches allow us to work on features, fixes, and experiments separately instead of putting everything directly on the main branch.

**3. What is `HEAD`?**
`HEAD` points to the branch/commit I am currently working on. I used:

```bash
git log --oneline
```

to see my commit history and current position.

**4. What happens when switching branches?**
Git changes the files in the working directory to match the branch I switch to.

---

## Task 2 — Creating & Switching Branches

### Step 1 — Create a Fresh Git Repo

```bash
cd ~
mkdir devops-git-practice
cd devops-git-practice

git init
```

Created one simple file, staged it, and committed it:

```bash
echo "Git Branching Practice" > spider.txt
git add spider.txt
git commit -m "Initial commit"
```

Checked the result:

```bash
git branch
git log --oneline --decorate -1
```

<img width="637" height="323" alt="bak-1" src="https://github.com/user-attachments/assets/368e59d9-07dc-4bba-9802-aa2cd3bf2d47" />

*Repo initialized, spider.txt committed as the initial commit on master.*

### Step 2 — Create feature-1

```bash
git branch feature-1
git branch
```

Expected output:
```
  feature-1
* master
```

<img width="482" height="59" alt="bak-2" src="https://github.com/user-attachments/assets/4d60e002-8c89-4cd5-ae11-2c15e42685ed" />

*feature-1 branch created, master still checked out (marked with \*).*

### Step 3 — Switch to feature-1

```bash
git switch feature-1
git branch
```

Expected output:
```
* feature-1
  master
```

<img width="488" height="76" alt="bak-3" src="https://github.com/user-attachments/assets/b62de3d4-ded9-42ed-8978-c1f3ae03caec" />

*Successfully switched to feature-1.*

### Step 4 — Create feature-2 (from master)

```bash
git switch -c feature-2
git branch
```

<img width="554" height="82" alt="bak-4" src="https://github.com/user-attachments/assets/b16c2512-51ab-48a2-8db5-e51223725424" />

*New branch feature-2 created and checked out, branched off master.*

### Step 5 — Add a File on feature-1

```bash
git switch feature-1
echo "This file belongs to feature-1" > feature1-only.txt
git add feature1-only.txt
git commit -m "Add file on feature-1"

git branch
git log --oneline
ls
```

<img width="749" height="404" alt="bak-5" src="https://github.com/user-attachments/assets/1716fcf2-4ca0-4143-b0ca-bf67fb1190ae" />

*feature1-only.txt committed only on feature-1 — confirms branches hold independent history.*

### Step 6 — Verify Isolation & Clean Up feature-2

```bash
# Verify master does not have the feature file
git switch master
ls
git log --oneline

# Switch to feature-1 and compare
git switch feature-1
ls
git log --oneline

# Delete feature-2 (not needed anymore)
git switch master
git branch -d feature-2

# Final branch check
git branch
```

<img width="504" height="280" alt="bak-6" src="https://github.com/user-attachments/assets/58efb678-e80f-4d84-8ab2-d822e0782f02" />

*master has no feature file, feature-1 does, and feature-2 was deleted after use.*

---

## Task 3 — Push Branches to GitHub

### Step 7 — Connect Local Repo to GitHub & Push

Created a new empty repository on GitHub named `devops-git-practice`, then linked it as the `origin` remote:

```bash
git remote add origin https://github.com/Jacksonklopes/devops-git-practice.git
git remote -v
```

Pushed both branches up to GitHub:

```bash
git push -u origin master
git push -u origin feature-1
git branch -r
```

Expected remote branches:
```
origin/HEAD -> origin/master
origin/feature-1
origin/master
```

<img width="890" height="448" alt="bak-7" src="https://github.com/user-attachments/assets/b8c24d03-ec21-492b-aa6f-488e7c385555" />

*origin remote added, master and feature-1 both pushed to GitHub.*

<img width="629" height="370" alt="bak-temp" src="https://github.com/user-attachments/assets/8bd55b7f-9c80-4a8e-b2f9-0c71eedff6d9" />

*GitHub confirms the devops-git-practice repo with master and feature-1 branches, feature-1 showing a recent push.*

---

## Task 4 — Pull from GitHub

### Step 8 — Make a Change Directly on GitHub

Opened `spider.txt` on GitHub, edited it, and added the line:

```
Day 23 - Practicing git pull
```

Committed the change directly on GitHub (no local screenshot needed for this step).

### Step 9 — Fetch, Diff & Pull

```bash
git fetch origin
git diff master origin/master
git pull
git log --oneline -3
```

<img width="613" height="391" alt="bak-8" src="https://github.com/user-attachments/assets/b1a6a8c0-b6be-4042-822f-4a8da3e15090" />

*git diff shows the incoming change from GitHub; git pull fast-forwards master to include it, confirmed by git log and a clean git status.*

---

## Task 5 — Clone vs Fork

### Step 10 — Verify Clone/Fork Setup

This was set up earlier using the `octocat/Spoon-Knife` repository:

- Cloned the original `octocat/Spoon-Knife` repo
- Forked it to my own GitHub account
- Changed `origin` to point to my fork
- Added `upstream` pointing to the original repository
- Ran `git fetch upstream`

Verified everything together:

```bash
cd ~/Spoon-Knife

git remote -v
git branch -r
```

<img width="557" height="226" alt="bak-9" src="https://github.com/user-attachments/assets/827108c4-7d28-4302-bcf3-a4c95ecea379" />

*origin points to my fork (Jacksonklopes/Spoon-Knife); upstream points to the original octocat/Spoon-Knife repo.*

### Step 11 — Keep the Fork in Sync (reference only)

Commands to remember for syncing a fork with the original repo — not run unless the fork actually needs updating:

```bash
git fetch upstream
git switch main
git merge upstream/main
git push origin main
```

- `fetch upstream` — get updates from the original repository.
- `merge upstream/main` — bring those updates into my local main.
- `push origin main` — send the updated branch to my fork.

---

## Summary — Day 23

- Created a new local Git repo and made an initial commit.
- Created, switched between, and deleted branches (feature-1, feature-2).
- Confirmed that each branch keeps its own independent file/commit history.
- Connected the local repo to a new GitHub repo and pushed multiple branches.
- Practiced fetching and pulling changes made directly on GitHub.
- Reviewed the difference between clone (origin) and fork (origin + upstream), and how to keep a fork in sync.
