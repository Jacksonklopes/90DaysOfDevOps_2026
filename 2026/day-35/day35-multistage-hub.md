# Day 35 – Multi-Stage Builds & Docker Hub (Quick Notes)

**In one line:** Build the app in a big image, copy only the finished program into a tiny image, then publish that tiny image to Docker Hub.

**Result:** 374 MB (single-stage) → **18.9 MB** (multi-stage). About 95% smaller.

---

## 1. The problem

A Go app needs the **compiler** to build, but not to run. In a single-stage image the compiler stays inside, so the image is huge and has extra tools an attacker could use.

## 2. Single-stage (the "before")

```dockerfile
FROM golang:1.25-alpine
WORKDIR /app
COPY app/main.go .
RUN go build -o myapp main.go
CMD ["./myapp"]
```

```bash
docker build -f Dockerfile.single -t day35-single:v1 .
docker images          # 374 MB
```

## 3. Multi-stage (the "after")

```dockerfile
# Stage 1: build (big image, thrown away at the end)
FROM golang:1.25-alpine AS builder
WORKDIR /app
COPY app/main.go .
RUN go build -o myapp main.go

# Stage 2: run (tiny image, this is what gets shipped)
FROM alpine:3.20
WORKDIR /app
RUN adduser -D appuser                  # normal user, not root
COPY --from=builder /app/myapp .        # take ONLY the compiled file
USER appuser
CMD ["./myapp"]
```

```bash
docker build -t jacksonlopes/day35-multi-stage:v1 .
docker run --rm jacksonlopes/day35-multi-stage:v1
```

**Why it is smaller:** every `FROM` starts a fresh image. Only what `COPY --from=builder` brings across is kept. The Go compiler and build tools stay in stage 1 and are discarded.

## 4. Push to Docker Hub

Image name format: `username/repo:tag`

```bash
docker login -u jacksonlopes
docker tag jacksonlopes/day35-multi-stage:v1 jacksonlopes/day35-multi-stage:latest
docker push jacksonlopes/day35-multi-stage:v1
docker push jacksonlopes/day35-multi-stage:latest
```

**Verify:** delete it locally, then run it again from the internet.

```bash
docker rmi jacksonlopes/day35-multi-stage:v1
docker run --rm --pull=always jacksonlopes/day35-multi-stage:v1
```

Repo: https://hub.docker.com/r/jacksonlopes/day35-multi-stage

## 5. Tags

| Tag | Meaning |
|---|---|
| `v1` | a fixed version |
| `latest` | just a name. Docker does **not** update it automatically. I must tag and push it myself. |
| `single-stage` | the big "before" image, kept for comparison |

Pull a specific tag (`:v1`) to get exactly that version. Pull without a tag and Docker assumes `:latest`.

## 6. Best practices

1. **Small base image:** `alpine` instead of a full OS.
2. **Multi-stage:** build tools never reach the final image.
3. **Don't run as root:** `RUN adduser -D appuser` + `USER appuser`.
4. **Fewer layers:** combine related commands, e.g. `RUN apk update && apk add --no-cache curl`.
5. **Pin versions:** `alpine:3.20`, not `alpine:latest`.

Check the user: `docker run --rm --entrypoint id jacksonlopes/day35-multi-stage:v1` → `uid=1000(appuser)`

## 7. Things that confused me (and the answers)

- **The container exits right after printing.** A container lives only as long as its main process (PID 1). `myapp` prints and finishes, so the container stops. `Exited (0)` means success.
- **`docker exec <id> exit` fails** with "executable file not found". `exit` is a shell built-in, not a program file. `exec` runs programs directly, with no shell.
- **`docker exec` does not type into the running shell.** It starts a new, separate process. Use `docker attach <id>` to connect to the original main process.
- **`sh -c "./myapp"` closes by itself.** `sh -c` runs one command and exits. `CMD ["./myapp"]` does the same thing with one less process.

## 8. Interview one-liners

- **What is a multi-stage build?** Several `FROM` stages in one Dockerfile. Build in one, copy only the output to a small final image.
- **Why use it?** Smaller images, faster pulls, fewer tools to attack.
- **Is `latest` the newest image?** No. It is only a tag name that someone has to push.
- **Why not root?** If the app is hacked, the attacker gets a limited user, not full control of the container.

## 9. Command cheat sheet

```bash
docker build -t name:tag .                 # build
docker build -f Dockerfile.single -t n:t . # build from another file name
docker images                              # list images and sizes
docker tag src dest                        # add another name to an image
docker push user/repo:tag                  # upload
docker pull user/repo:tag                  # download
docker run --rm image                      # run, then delete the container
```

**Files:** `Dockerfile` (multi-stage), `Dockerfile.single`, `app/main.go`

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
