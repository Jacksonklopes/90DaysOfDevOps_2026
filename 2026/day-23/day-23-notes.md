# Day 23 – Git Branching & Working with GitHub

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

<img src="screenshots/01-init-commit.png" width="700"><br>
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

<img src="screenshots/02-create-feature1.png" width="500"><br>
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

<img src="screenshots/03-switch-feature1.png" width="500"><br>
*Successfully switched to feature-1.*

### Step 4 — Create feature-2 (from master)

```bash
git switch -c feature-2
git branch
```

<img src="screenshots/04-create-feature2.png" width="500"><br>
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

<img src="screenshots/05-feature1-commit.png" width="700"><br>
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

<img src="screenshots/06-verify-cleanup.png" width="700"><br>
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

<img src="screenshots/07-push-branches.png" width="700"><br>
*origin remote added, master and feature-1 both pushed to GitHub.*

<img src="screenshots/08-github-repo-view.png" width="700"><br>
*GitHub confirms the devops-git-practice repo with master and feature-1 branches, feature-1 showing a recent push.*

---

## Task 4 — Pull from GitHub

### Step 8 — Make a Change Directly on GitHub

Opened `spider.txt` on GitHub, edited it, and added the line:

```
Day 23 - Practicing git pull
```

Committed the change directly on
