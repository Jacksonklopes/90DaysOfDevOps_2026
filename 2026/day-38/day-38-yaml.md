
# Day 38 – YAML Basics

## What is YAML?

YAML (YAML Ain't Markup Language) is a human-readable format used to store configuration data.

Common DevOps uses:
- Docker Compose
- Kubernetes
- GitHub Actions
- Ansible

## 1. Key-Value Pairs

```yaml
name: Jackson
role: Aspiring DevOps Engineer
experience_years: 1
learning: true
```

- `:` separates keys and values.
- Strings, numbers and booleans are supported.
- `true` is a boolean; `"true"` is a string.

## 2. Lists

YAML supports two list formats.

### Block style

```yaml
tools:
  - linux
  - git
  - docker
```

### Inline style

```yaml
tools: [linux, git, docker]
```

Both represent the same list.

## 3. Nested Objects

```yaml
server:
  name: web-server
  ip: 192.168.1.10
  port: 80

database:
  host: localhost
  name: devops_db
  credentials:
    user: admin
    password: secret123
```

Indentation defines parent-child relationships.

## 4. Multi-line Strings

### Literal block (|)

Preserves line breaks.

```yaml
startup_script: |
  echo "Starting server"
  echo "Checking services"
  echo "Server ready"
```

### Folded block (>)

Joins lines into a continuous string.

```yaml
description: >
  This is my DevOps practice server
  used for learning YAML.
```

## 5. YAML Validation

Installed yamllint:

```bash
sudo apt install yamllint -y
```

Validate files:

```bash
yamllint person.yaml
yamllint server.yaml
```

An indentation mistake produced:

`mapping values are not allowed here`

Fixed the indentation and validated again.

## 6. Important YAML Rules

- Use spaces, never tabs.
- Two spaces are commonly used for indentation.
- Indentation defines nesting.
- `-` represents a list item.
- `|` preserves newlines.
- `>` folds lines into spaces.
- `---` marks the beginning of a YAML document.

## 7. What I Learned

1. YAML uses indentation to define structure and relationships.
2. Lists can be written in block or inline style, and nested objects organize related data.
3. yamllint helps identify syntax and formatting mistakes.

