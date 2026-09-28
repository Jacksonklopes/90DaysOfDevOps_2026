# Day 25 – Git Reset vs Revert & Branching Strategies

## Objective

Learn how to undo mistakes in Git using `git reset` and `git revert`, and understand the common branching strategies used by real teams.

---

# Task 1 – Git Reset

`git reset` moves the current branch back to an earlier commit. What happens to the changes from the removed commit depends on the option used.

I created three commits:

```text
Commit A → Commit B → Commit C
```

## 1. Soft Reset

```bash
# Move HEAD back from Commit C to Commit B, keep Commit C changes staged
git reset --soft HEAD~1

# Check the status
git status

# Check the file contents
cat reset.txt
```

**Observation:** Commit C was removed from the branch history, but its changes stayed **staged**, ready to be committed again.

<img width="688" height="271" alt="bra-1" src="https://github.com/user-attachments/assets/ea1bbb66-1033-4d66-9c3d-92caaffbc9a7" />

<img width="530" height="208" alt="bra-2" src="https://github.com/user-attachments/assets/a8ef8ed6-987d-4a3e-84ce-399024a286ac" />

---

## 2. Mixed Reset

```bash
# Move HEAD back to Commit B using its commit ID, keep changes but unstage them
git reset --mixed 68ea4f5

# Check the status
git status

# Check the commit history
git log --oneline
```

**Observation:** Commit C was removed from the branch history, but its changes stayed in the file as **unstaged** changes. `--mixed` is the default mode of `git reset`.

<img width="540" height="256" alt="bra-3" src="https://github.com/user-attachments/assets/42df1f98-0e1d-4a51-97df-f8c02a465afe" />

---

## 3. Hard Reset

```bash
# Move HEAD back to Commit B and remove Commit C changes from the working directory
git reset --hard 68ea4f5

# Check the status
git status

# Check the commit history
git log --oneline
```

**Observation:** Commit C was removed from the branch history and its changes were also removed from the working directory.

<img width="482" height="167" alt="bra-4" src="https://github.com/user-attachments/assets/c7ba38e6-c159-4090-b453-91d8f3880aa5" />

---

## Reset Options

| Option | Commit removed from history? | Changes |
| --- | --- | --- |
| `--soft` | Yes | Stay staged |
| `--mixed` | Yes | Stay in files, unstaged |
| `--hard` | Yes | Removed from working directory |

### Which one is destructive?

`--hard`. It deletes the changes from your files, so any uncommitted work is lost.

### When would I use each?

- **Soft:** Redo a commit (fix the message or add more changes) while keeping everything staged.
- **Mixed:** Undo a commit but keep the changes so I can edit and re-stage them.
- **Hard:** Completely throw away a commit and its changes.

### Should I use reset on pushed commits?

No. Reset rewrites branch history, so anyone who already pulled those commits will have a different history from mine. Use `git revert` for pushed commits.

### Safety net

`git reflog` shows every position `HEAD` has been at, so a commit removed by reset can usually still be found and recovered.

---

# Task 2 – Git Revert

`git revert` undoes a commit by creating a **new commit** that reverses its changes. The original commit stays in history.

I created three commits, each creating a separate file:

```text
Commit X → Commit Y → Commit Z
```

## Revert Commit Y (the middle commit)

```bash
# Create a new commit that undoes Commit Y
git revert f9bc4e7

# Check the commit history
git log --oneline

# Check the files
ls

# Check the working tree
git status
```

**Observation:**
- Git created a new commit: `Revert "commit Y"`.
- The file created by Commit Y was removed.
- Commit Y is **still in the history**.
- There was no conflict because each commit touched a different file.

**Extra note:** If a later commit changes the same lines as the commit being reverted, Git can show a conflict during revert. It is resolved the same way as a merge conflict: edit the file, `git add`, then `git revert --continue`.

<img width="671" height="240" alt="bra-5" src="https://github.com/user-attachments/assets/00f70db2-8264-4dad-b035-ba19bf4f69cf" />

<img width="562" height="212" alt="bra-6" src="https://github.com/user-attachments/assets/fc1aa62e-a6ab-4f2d-823c-89215d6d28ee" />

### How is revert different from reset?

Reset moves the branch backward and removes commits from history. Revert keeps the history and adds a new commit that undoes the change.

### Why is revert safer for shared branches?

It does not rewrite existing history. It only adds a new commit on top, so everyone who already pulled the branch stays in sync.

### When to use which?

- **Revert:** the commit is already pushed or shared.
- **Reset:** the commit is only local and nobody else has it.

---

# Task 3 – Reset vs Revert

| | `git reset` | `git revert` |
| --- | --- | --- |
| What it does | Moves the branch back to an earlier commit | Creates a new commit that undoes an earlier commit |
| Removes commit from history? | Yes, after the reset point | No, the original commit stays |
| Safe for shared/pushed branches? | No, avoid it | Yes, generally safer |
| When to use | Local/private history | Shared/pushed history |

**Easy way to remember:**
- **Reset** → move the branch backward
- **Revert** → keep history and undo the changes with a new commit

---

# Task 4 – Branching Strategies

## 1. GitFlow

**How it works:**
- Two long-lived branches: `master` (production) and `develop` (integration).
- New work happens on `feature/*` branches created from `develop`.
- A `release/*` branch is created from `develop` for final testing, then merged into `master` and back into `develop`.
- A `hotfix/*` branch is created from `master` for urgent production fixes, then merged into both `master` and `develop`.

```text
master   ----o-----------o-----o---
                \       /     /
release          o-----o     /
                /      \    /
develop  ----o----o----o---o----
              \  /
feature        o
```

**Used for:** Projects with scheduled or versioned releases.

**Pros:** Clear structure, safe hotfix path, good for large teams.
**Cons:** Many branches to manage, slower to ship.

---

## 2. GitHub Flow

**How it works:**
- Only one long-lived branch: `master`.
- Every change gets its own short-lived branch.
- Push the branch → open a Pull Request → review → merge into `master` → deploy.

```text
master   ----o------o------o----
              \    /  \    /
feature        o--o    o--o
                PR      PR
```

**Used for:** Startups, web apps, and teams that deploy frequently.

**Pros:** Simple and fast.
**Cons:** No separate release branch, needs good automated testing.

---

## 3. Trunk-Based Development

**How it works:**
- Everyone integrates into one main branch (the trunk) very frequently.
- Branches, if used, live only hours.
- Unfinished work is hidden behind feature flags instead of long branches.

```text
Developer A ─┐
Developer B ─┼──► master (trunk)
Developer C ─┘
```

**Used for:** CI/CD environments with strong automated testing.

**Pros:** Few merge conflicts, fast integration.
**Cons:** Needs strong CI and feature flags.

---

## Comparison

| | GitHub Flow | Trunk-Based | GitFlow |
| --- | --- | --- | --- |
| Branch from | `master` | `master` | `develop` |
| Branch lifespan | Days | Hours | Days to weeks |
| Merges into | `master` | `master` | `develop` → `release` → `master` |
| Best for | Fast, simple delivery | Very frequent integration | Scheduled releases |

## Strategy Questions

**Which strategy for a startup shipping fast?**
GitHub Flow. It is simple (feature → Pull Request → master) and supports frequent delivery.

**Which strategy for a large team with scheduled releases?**
GitFlow. Separate `develop` and `release` branches let the team stabilize a release while new work continues.

**Which strategy does an open-source project use?**
Kubernetes uses a main development branch, contributor branches with Pull Requests, and separate release branches for supported releases.

---

# Key Learnings

- `git reset` changes branch history.
- `git revert` keeps history and creates an undo commit.
- `--soft` keeps changes staged, `--mixed` keeps them unstaged, `--hard` removes them.
- `git reflog` can help recover commits after a reset.
- GitHub Flow uses a simple branch → Pull Request → merge workflow.
- GitFlow uses `develop`, `feature`, `release`, and `hotfix` branches.
- Trunk-Based Development focuses on frequent integration into the main branch.

## Final Observation

Reset and revert both undo changes, but they work differently. **Reset changes the branch history, while revert keeps the history and adds a new commit to undo the previous changes.**
