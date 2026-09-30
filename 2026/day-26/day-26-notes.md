# Day 26 – GitHub CLI: Manage GitHub from Your Terminal

## Objective

Learn to use GitHub CLI (`gh`) to manage GitHub directly from the terminal — repos, issues, PRs, and more — without switching to the browser for every operation.

---

## Task 1 – Install and Authenticate

```bash
gh --version          # check gh is installed
gh auth login          # authenticate with GitHub
gh auth status         # check which account is active
```

**Observation:** Authenticated successfully, Git operations configured to use SSH.

**Answer — What authentication methods does `gh` support?**
- Browser-based login (opens GitHub to authorize)
- Personal Access Token (paste directly in the terminal)

---

## Task 2 – Working with Repositories

```bash
gh repo create my-test-repo --public --add-readme   # create a new public repo with README
gh repo clone <owner>/<repo>                          # clone a repo using gh
gh repo view                                           # view current repo details
gh repo view <owner>/<repo>                            # view a specific repo
gh repo list                                           # list my repositories
gh repo view --web                                     # open the repo in the browser
gh repo delete <owner>/<repo>                          # delete the test repo (destructive — be careful)
```

**Observation:** Created `my-test-repo`, viewed and listed my repos, then deleted the test repo when done.

---

## Task 3 – Issues

```bash
gh issue create --title "Application Bug" --body "App is not starting" --label bug   # create an issue
gh issue list                    # list open issues
gh issue view <number>            # view a specific issue
gh issue close <number>           # close an issue
```

**Observation:** Created, viewed, and closed a test issue.

**Answer — How could `gh issue` be used in a script or automation?**
A monitoring or health-check script could run `gh issue create` automatically the moment it detects a failure — e.g. auto-open a GitHub issue when a production service goes down, without a human having to do it manually.

---

## Task 4 – Pull Requests

```bash
git checkout -b feature-test                    # create a feature branch
echo "GitHub CLI practice" >> test.txt           # make a change
git add . && git commit -m "adding GitHub CLI practice"
git push -u origin feature-test                  # push the branch

gh pr create --fill                              # create a PR, auto-filled from commits
gh pr list                                       # list open PRs
gh pr view <number>                               # view PR details
gh pr checks <number>                             # check CI status
gh pr merge <number> --squash --delete-branch     # merge and delete branch
```

**Observation:** Created a full PR entirely from the terminal — branch, commit, push, PR, merge — no browser needed.

**Answer — What merge methods does `gh pr merge` support?**
- `--merge` → standard merge commit
- `--squash` → combines all PR commits into one commit
- `--rebase` → replays PR commits on top of the base branch, no merge commit

**Answer — How would you review someone else's PR using `gh`?**
```bash
gh pr view <number>              # see description, status, reviewers
gh pr checks <number>            # see if CI checks passed
gh pr diff <number>              # see the actual code changes
gh pr review <number> --approve  # approve directly from the terminal
```

---

## Task 5 – GitHub Actions & Workflows (Preview)

```text
Workflow → instructions for automation
Run      → one execution of that workflow
Job      → a task performed during a run
```

```bash
gh run list --repo cli/cli                    # list workflow runs on a public repo
gh run view <run-id> --repo cli/cli             # view a specific run
gh workflow list                                # list workflows in a repo
```

**Observation:** Viewed a successful workflow run (Go Vulnerability Check) on `cli/cli`.

**Answer — How could `gh run` and `gh workflow` be useful in a CI/CD pipeline?**
- Check if a deployment succeeded or failed without opening the browser
- See what automations exist on a repo (`gh workflow list`)
- Debug failed pipelines quickly from the terminal
- Build scripts that check pipeline status before taking another action — e.g. "only deploy to prod if the last CI run passed"

---

## Task 6 – Useful `gh` Tricks

```bash
gh api user                              # get authenticated user info as JSON
gh api repos/<owner>/<repo>               # get info about a specific repo

gh gist create <file>                    # create a Gist from a file
gh gist                                  # show all gist commands

gh release list                          # list releases
gh release create <tag>                   # create a release

gh alias list                            # list saved aliases
gh alias set <alias> '<command>'          # create a shortcut

gh search repos "docker" --limit 5        # search GitHub repos from terminal
```

**Notes:**
- Gist = small snippet/file sharing; Repo = full project
- Release = a published version of a project (v1.0, v1.1, v2.0...)
- Alias = shortcut for a longer command (e.g. `co: pr checkout` → `gh co 5` runs `gh pr checkout 5`)

---

## Git vs GitHub CLI

| Git | GitHub CLI |
|---|---|
| Version control | GitHub platform operations |
| `git add` / `git commit` | `gh issue create` |
| `git push` | `gh pr create` |
| `git pull` | `gh run list` |
| Works with the repo itself | Works with GitHub features (PRs, issues, actions) |

---

## 🧠 Key Takeaways

- `gh` lets you manage GitHub entirely from the terminal — no browser needed for most tasks
- `gh pr` → create, view, check, and merge Pull Requests
- `gh issue` → create, view, and close Issues
- `gh run` / `gh workflow` → inspect GitHub Actions runs
- `gh api` → talk directly to GitHub's API
- Gists → small snippets, Releases → published versions, Aliases → shortcuts
- All of this fits naturally into scripts, automation, and CI/CD pipelines — the core reason it matters for DevOps

---

## Summary

```text
Git → GitHub → GitHub CLI (gh) → manage GitHub from the terminal
```

---

# Git Commands Reference Update (add to `git-commands.md`)

```bash
gh --version
gh auth login
gh auth status

gh repo create
gh repo clone
gh repo view
gh repo view --web
gh repo list
gh repo delete

gh issue create
gh issue list
gh issue view
gh issue close

gh pr create
gh pr create --fill
gh pr list
gh pr view
gh pr checks
gh pr diff
gh pr review --approve
gh pr merge
gh pr merge --squash
gh pr merge --rebase
gh pr merge --delete-branch

gh run list
gh run view
gh workflow list

gh api
gh gist create
gh release list
gh release create
gh alias list
gh alias set
gh search repos
```
