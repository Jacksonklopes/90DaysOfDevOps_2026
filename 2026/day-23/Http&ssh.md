# GitHub HTTPS & SSH

Git can connect my local repository to GitHub using **HTTPS or SSH**.

---

## 1. HTTPS

I connected my local repository to GitHub using the GitHub HTTPS URL.

### Add GitHub Repository

```bash
git remote add origin https://github.com/Jacksonklopes/devops-git-practice.git
```

**Meaning:**

* `git remote add` → adds a remote connection
* `origin` → name given to the GitHub repository
* `https://...` → HTTPS address of my GitHub repository

Now my local Git repository knows where my GitHub repository is.

### Check Remote

```bash
git remote -v
```

**Meaning:**
Shows the GitHub URL connected to my local repository.

Output:

```text
origin  https://github.com/Jacksonklopes/devops-git-practice.git (fetch)
origin  https://github.com/Jacksonklopes/devops-git-practice.git (push)
```

### Push Using HTTPS

```bash
git push
```

**Meaning:**
Sends my local commits to GitHub.

Because I was using HTTPS, GitHub asked for my:

```text
Username
Personal Access Token (PAT)
```

---

# 2. SSH

SSH is another way to authenticate with GitHub.

Instead of using a username and PAT, SSH uses an **SSH key**.

### Create SSH Key

```bash
ssh-keygen -t ed25519 -C "my-github-email"
```

**Meaning:**

* `ssh-keygen` → creates an SSH key
* `-t ed25519` → uses the ED25519 key type
* `-C` → adds a comment/label to the key

It created:

```text
~/.ssh/id_ed25519
```

**Private key — keep secret**

```text
~/.ssh/id_ed25519.pub
```

**Public key — added to GitHub**

### Test SSH

```bash
ssh -T git@github.com
```

**Meaning:**
Tests whether my EC2 machine can authenticate with GitHub using SSH.

GitHub responded:

```text
Hi Jacksonklopes! You've successfully authenticated,
but GitHub does not provide shell access.
```

This confirmed that my SSH authentication works.

---

## 3. HTTPS URL vs SSH URL

Both URLs can point to the **same GitHub repository**.

### HTTPS

```text
https://github.com/Jacksonklopes/devops-git-practice.git
```

### SSH

```text
git@github.com:Jacksonklopes/devops-git-practice.git
```

The difference is **how Git authenticates with GitHub**.

```text
HTTPS → Username + PAT

SSH   → SSH key
```

---

## 4. Change HTTPS Remote to SSH

My repository was initially using HTTPS.

I can change it to SSH:

```bash
git remote set-url origin git@github.com:Jacksonklopes/devops-git-practice.git
```

**Meaning:**
Changes the `origin` URL from HTTPS to SSH.

Check the new URL:

```bash
git remote -v
```

Now it should show:

```text
origin  git@github.com:Jacksonklopes/devops-git-practice.git (fetch)
origin  git@github.com:Jacksonklopes/devops-git-practice.git (push)
```

---

## Simple Memory

```text
HTTPS
↓
https://github.com/...
↓
Username + PAT
```

```text
SSH
↓
git@github.com:...
↓
SSH key
```

### Commands I Practiced

```bash
git remote add origin <HTTPS-URL>
git remote -v
git push

ssh-keygen -t ed25519 -C "my-github-email"
ssh -T git@github.com

git remote set-url origin <SSH-URL>
```

**Main thing I learned:**
The GitHub repository stays the same. I can choose **HTTPS or SSH as the way Git connects to it**.
