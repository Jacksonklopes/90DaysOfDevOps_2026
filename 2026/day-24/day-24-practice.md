# Day 24 – Advanced Git: Merge, Rebase, Stash & Cherry-pick

## 🎯 Objective

Today I practiced advanced Git concepts using hands-on repositories.

Topics covered:
- Git Merge (fast-forward, conflicts, conflict resolution)
- Git Rebase (and rebase conflicts)
- Squash Merge
- Git Stash
- Git Cherry-pick

The goal was to understand how these operations affect branches, commits, files, and history.

---

## Task 1 – Git Merge

### What is Git Merge?

`git merge` combines changes from another branch into the current branch.

```text
master
   \
    feature
```

After merging, the feature branch's changes become part of the current branch.

### 1.1 Fast-Forward Merge

A fast-forward merge happens when the current branch has no new commits since the feature branch was created — Git simply moves the branch pointer forward.

```bash
cd ~/git-advance
pwd
git branch

git checkout feature-login
git add .
git commit -m "Add login feature"

git checkout master
git merge feature-login
git log --oneline
```

In a fast-forward merge, Git doesn't need to create a separate merge commit.

<img width="620" height="370" alt="sak-1" src="https://github.com/user-attachments/assets/4856f665-bddb-4bb8-a675-59919f8fb4b7" />
<img width="686" height="226" alt="sak-2" src="https://github.com/user-attachments/assets/d7344ea6-3467-457b-bb1b-8b0d8db8dc45" />

### 1.2 Merging Another Feature Branch

```bash
git checkout feature-signup
git add .
git commit -m "Add signup validation"

git checkout master
git merge feature-signup
git log --oneline
```

Branches let features be developed separately and combined into `master` later.

<img width="503" height="243" alt="sak-3" src="https://github.com/user-attachments/assets/f2b461a2-e944-44ec-ba99-32c45efb8e2f" />
<img width="701" height="242" alt="sak-4" src="https://github.com/user-attachments/assets/07d2840a-2a0b-47b8-ae55-7173373e44a3" />

### 1.3 Intentional Merge Conflict

I created conflicting changes in `README.md` on two branches:

```bash
git checkout -b conflict-test
vim README.md
git add README.md
git commit -m "Update README on feature branch"

git checkout master
vim README.md
git add README.md
git commit -m "Update README on master"

git merge conflict-test
```

Git couldn't decide which version to keep, and showed conflict markers:

```text
<<<<<<< HEAD
Master version
=======
Feature version
>>>>>>> conflict-test
```

- `<<<<<<< HEAD` → current branch's version
- `=======` → separator between the two versions
- `>>>>>>> conflict-test` → incoming branch's version

<img width="683" height="169" alt="sak-5" src="https://github.com/user-attachments/assets/107cac74-0953-4241-a0f7-0915f01ba620" />

### 1.4 Resolving the Merge Conflict

```bash
vim README.md          # manually fix the conflict
git add README.md      # mark as resolved
git commit -m "Resolve README merge conflict"
git log --oneline
```

`git add` marks the conflict resolved; `git commit` records the resolution.

<img width="464" height="203" alt="sak-6" src="https://github.com/user-attachments/assets/7d11b796-7c90-46cf-94ff-2611944cce84" />
<img width="764" height="353" alt="sak-7" src="https://github.com/user-attachments/assets/fa1b5bc5-c7d5-4df4-bf38-803969054f16" />
<img width="824" height="421" alt="sak-8" src="https://github.com/user-attachments/assets/cb45e61a-1da3-4f59-8809-084946aecf36" />

---

## Task 2 – Git Rebase

### What is Rebase?

Rebase takes commits from one branch and replays them on top of another branch.

Before rebase:
```text
A → B → C → D → E
     \
      F
```

After rebasing the feature branch onto `master`:
```text
A → B → F → C' → D' → E'
```

### 2.1 Setup

Repository: `~/rebase-practice`

Feature branch (`feature-dashboard`): `A → B → C → D → E`

Advanced `master` with Commit F:

```bash
cd ~/rebase-practice
git checkout master
echo "F" >> file.txt
git add file.txt && git commit -m "Commit F"
git log --oneline
```

`master`:
```text
b1603c6 Commit F
7fa6211 Commit B
ed31d1d Commit A
```

`feature-dashboard`:
```text
0f1a49c Commit E
b6f29da Commit D
538f765 Commit C
7fa6211 Commit B
ed31d1d Commit A
```

<img width="731" height="448" alt="sak-9" src="https://github.com/user-attachments/assets/52c38d6e-b0ff-4930-b6bf-5ad9e375350a" />
<img width="636" height="139" alt="sak-10" src="https://github.com/user-attachments/assets/b3f34d16-ca2b-4100-a47b-1a7ad5354b6f" />

### 2.2 Starting the Rebase

```bash
git checkout feature-dashboard
git rebase master
```

Git tried to replay Commit C on top of Commit F and hit a conflict:

```text
Auto-merging file.txt
CONFLICT (content): Merge conflict in file.txt
error: could not apply 538f765 ... Commit C
```

<img width="666" height="392" alt="sak-11" src="https://github.com/user-attachments/assets/d2c54607-5b4b-40e2-a640-5b924878c261" />

### 2.3 Rebase Conflict

```text
A
B
<<<<<<< HEAD
F
=======
C
>>>>>>> 538f765
```

Git couldn't automatically decide how to combine the change from `master` with Commit C.

<img width="627" height="210" alt="sak-12" src="https://github.com/user-attachments/assets/c589b46c-b293-49bc-8ddc-89d521aeb7a4" />

### 2.4 Resolving the Rebase Conflict

```bash
vim file.txt           # resolve the conflict
git add file.txt
git rebase --continue
```

```text
[detached HEAD c472150] Commit C
1 file changed, 1 insertion(+)
Successfully rebased and updated refs/heads/feature-dashboard.
```

**Important:** during a rebase conflict, use `git add` + `git rebase --continue` — never `git commit` manually to create the replayed commit.

<img width="541" height="101" alt="sak-13" src="https://github.com/user-attachments/assets/fb1f8f0a-f03b-4b41-9f0f-ead697cf69bd" />

### 2.5 What Rebase Did

Before: `A → B → C → D → E` (feature) branching off `A → B`
After: `A → B → F → C' → D' → E'`

The feature commits were replayed on top of Commit F, so Git generated new commit hashes.

**Simple explanation:** rebase tells Git — "take my feature commits and replay them as if my work started from the latest master."

### Merge vs Rebase

| Merge | Rebase |
|---|---|
| Combines branch histories | Replays commits |
| Can create a merge commit | Creates a more linear history |
| Keeps existing commit history | Recreates commits |
| Doesn't rewrite existing commits | Changes commit hashes |
| Safer for shared history | Better for private/local work |

**Rule:** avoid rebasing commits that have already been pushed and are being used by others, since rebase rewrites history.

---

## Task 3 – Squash Merge

### What is Squash?

A squash merge combines multiple feature commits into a single new commit.

```text
Feature: A → B → C → D
After squash on master: A → X   (X = combined changes of B, C, D)
```

### 3.1 Setup

Repository: `~/squash-practice`

```bash
git init
echo "A" > file.txt
git add file.txt && git commit -m "Commit A"

git checkout -b feature
echo "B" >> file.txt
git add file.txt && git commit -m "Commit B"

echo "C" >> file.txt
git add file.txt && git commit -m "Commit C"

echo "D" >> file.txt
git add file.txt && git commit -m "Commit D"

git log --oneline
```

```text
5d013d2 Commit D
954ce1b Commit C
0462476 Commit B
33cb516 Commit A
```

<img width="668" height="348" alt="sak-14" src="https://github.com/user-attachments/assets/f334c287-5797-4bbd-9bb9-ece271fd23c8" />

### 3.2 Squash Merge

```bash
git checkout master
git merge --squash feature
git status
git commit -m "Add feature changes"
git log --oneline
```

**Important:** `git merge --squash` only stages the combined changes — it doesn't create the final commit. You still need to run `git commit` afterward.

<img width="620" height="338" alt="sak-15" src="https://github.com/user-attachments/assets/1e0cbefa-812a-41de-a0e9-9f1e32df11ab" />

---

## Task 4 – Git Stash

### What is Git Stash?

Git stash temporarily saves uncommitted changes — useful for switching branches or getting a clean working directory without committing unfinished work.

### 4.1 Practice

```bash
echo "Unfinished work" >> file.txt
git status

git stash push -m "unfinished feature work"
git status

git stash list
git stash apply stash@{0}
git status

git stash drop stash@{0}
git status
```

| Command | Meaning |
|---|---|
| `git stash` | Temporarily saves changes |
| `git stash list` | Shows saved stashes |
| `git stash apply` | Restores changes but keeps the stash |
| `git stash pop` | Restores changes and removes the stash |
| `git stash drop` | Deletes a stash |

<img width="586" height="448" alt="sak-16" src="https://github.com/user-attachments/assets/520ef51e-6a24-424e-ab5f-b53ceec4b62b" />

---

## Task 5 – Git Cherry-pick

### What is Cherry-pick?

Cherry-pick applies the changes from one specific commit onto the current branch — useful when you want just one commit without merging the whole feature branch.

### 5.1 Initial Practice (with conflict)

Repository: `~/cherry-pick-practice`

```bash
echo "A" > file.txt
git add file.txt && git commit -m "Commit A"

git checkout -b feature-hotfix
echo "B" >> file.txt
git add file.txt && git commit -m "Commit B"

echo "C" >> file.txt
git add file.txt && git commit -m "Commit C"

echo "D" >> file.txt
git add file.txt && git commit -m "Commit D"

git log --oneline
```

```text
0b5d3b3 Commit D
222d58d Commit C
91ea11c Commit B
21e52ca Commit A
```

<img width="664" height="337" alt="sak-17" src="https://github.com/user-attachments/assets/de4b94d4-3964-48d9-ae41-26cc26182f22" />

```bash
git checkout master
git cherry-pick 222d58d
```

Since Commit C depended on changes from B (not present on `master`), it produced a conflict:

```text
A
<<<<<<< HEAD
=======
B
C
>>>>>>> 222d58d
```

Cherry-pick applies the change from one commit — it does **not** automatically bring its parent commits along, which is why this conflicted.

### 5.2 Clean Cherry-pick Practice

Repository: `~/cherry-pick-clean`

Feature branch (`feature-hotfix`): `A → B → C → D`, where Commit D creates a new file, `hotfix.txt`.

```bash
git checkout master
git cherry-pick <D-HASH>

git log --oneline
ls
cat file.txt
cat hotfix.txt
```

This cherry-pick succeeded because Commit D's change could be applied cleanly to `master`.

<img width="527" height="430" alt="sak-18" src="https://github.com/user-attachments/assets/419931f1-a443-451b-a08f-39a29244ee46" />

### Does Cherry-pick Always Cause a Conflict?

No. A conflict only happens when Git can't cleanly apply the selected commit's changes to the current branch — it doesn't depend on how many commits are on the feature branch. For example, D can be cherry-picked cleanly without B and C if D's change stands on its own.

---

## 🧠 What I Learned Today

- **Merge** — combines changes from another branch into the current branch.
- **Merge conflict** — happens when Git can't auto-combine changes; resolve manually, then `git add <file>` + `git commit`.
- **Rebase** — replays commits on top of another branch. On conflict: `git add <file>` + `git rebase --continue` (never commit manually).
- **Squash** — combines multiple feature commits into one: `git merge --squash feature` + `git commit -m "..."`.
- **Stash** — temporarily saves unfinished changes: `git stash`.
- **Cherry-pick** — applies one specific commit: `git cherry-pick <commit-hash>`.

---

## 🔑 Important Commands

```bash
# Merge
git merge <branch>
git merge --squash <branch>

# Rebase
git rebase <branch>
git rebase --continue
git rebase --abort
git rebase --skip

# Stash
git stash
git stash push -m "message"
git stash list
git stash apply stash@{0}
git stash pop
git stash drop stash@{0}

# Cherry-pick
git cherry-pick <commit-hash>
git cherry-pick --continue
git cherry-pick --abort

# General
git log --oneline
git status
```

---

## 📌 Final Summary

```text
Merge       → Combine branch histories
Rebase      → Replay commits on a new base
Squash      → Combine multiple feature changes into one commit
Stash       → Temporarily save unfinished work
Cherry-pick → Apply one specific commit
```

The key takeaway: these aren't just different ways to run Git — they change how history and commits are organized.

**Learning workflow:** Learn → Practice → Revise → Document → Share
**Motto:** Consistency over perfection.
