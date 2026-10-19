# Day 31 – Dockerfile: Build Your Own Images

## Setup Note (do this first on a new instance)

When you create a new instance, add your user to the `docker` group so you can run Docker without `sudo`, then refresh the group membership in your current shell:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Verify with:

```bash
docker ps
```

---

## Goal

Learn how to create custom Docker images using Dockerfiles. Topics covered:

* Dockerfile instructions
* Building custom images
* `CMD` vs `ENTRYPOINT`
* Custom Nginx image and port mapping
* `.dockerignore` and build context
* Layer caching
* Verifying files inside containers

---

## Task 1 – Your First Dockerfile

**Objective:** Build an Ubuntu-based image that installs `curl`, sets a working directory, and prints a custom message on start.

### Project structure

```text
my-first-image/
└── Dockerfile
```

### Dockerfile

```dockerfile
FROM ubuntu

WORKDIR /app

RUN apt-get update && \
    apt-get install curl -y

CMD ["echo", "Hello from my custom image!"]
```

| Instruction | Purpose |
| ----------- | ------- |
| `FROM ubuntu` | Base image the new image is built on. Every Dockerfile needs one. |
| `WORKDIR /app` | Sets the working directory for later instructions and for the container. |
| `RUN ...` | Executes commands at **build time** (here, installs `curl`). |
| `CMD [...]` | Default command that runs when the container **starts**. |

### Build

```bash
docker build -t my-ubuntu:v1 .
```

### Run

```bash
docker run --name ubuntu-cont my-ubuntu:v1
```

Output:

```text
Hello from my custom image!
```

This confirms `CMD` runs when the container starts.

---

## Task 2 – Dockerfile Instructions

| Instruction | What it does | Example |
| ----------- | ------------ | ------- |
| `FROM` | Defines the base image | `FROM nginx:alpine` |
| `RUN` | Runs commands during image build; the result becomes part of the image | `RUN apt-get update && apt-get install curl -y` |
| `COPY` | Copies files from the build context into the image | `COPY index.html .` |
| `WORKDIR` | Sets the working directory | `WORKDIR /usr/share/nginx/html` |
| `EXPOSE` | Documents the port the app listens on | `EXPOSE 80` |
| `CMD` | Default command when the container starts | `CMD ["nginx", "-g", "daemon off;"]` |

> `EXPOSE` only documents the port. It does **not** publish it to the host. Use `docker run -p` for that.

---

## Task 3 – CMD vs ENTRYPOINT

### CMD

```dockerfile
CMD ["echo", "hello"]
```

* `docker run image` runs `echo hello`
* `docker run image <custom-command>` **replaces** the `CMD`

### ENTRYPOINT

`Dockerfile.entrypoint`:

```dockerfile
FROM ubuntu

WORKDIR /app

ENTRYPOINT ["echo"]
```

Build and run:

```bash
docker build -t ubuntu-entrypoint -f Dockerfile.entrypoint .
docker run --name entrypoint-cont ubuntu-entrypoint "Hello , this is entrypoint argument"
```

Output:

```text
Hello , this is entrypoint argument
```

The runtime argument was appended to the `ENTRYPOINT` command (`echo`).

### Comparison

| CMD | ENTRYPOINT |
| --- | ---------- |
| Provides a default command | Defines the main executable |
| Easily replaced at runtime | Runtime arguments are appended |
| Good for default behavior | Good when the container should act like a specific executable |
| Can supply default arguments | Keeps the executable fixed |

---

## Task 4 – Build a Simple Web App Image

### Static page

`index.html`:

```html
<h1>hello this is a testing file</h1>
```

### Project structure

```text
my-first-image/
├── Dockerfile
├── Dockerfile.entrypoint
├── Dockerfile.nginx
└── index.html
```

### Dockerfile.nginx

```dockerfile
FROM nginx:alpine

WORKDIR /usr/share/nginx/html

COPY index.html .

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

What it does:

1. Uses `nginx:alpine` as the base
2. Sets the working directory to the Nginx web root
3. Copies `index.html` into it
4. Documents port `80`
5. Starts Nginx in the foreground

### Build

```bash
docker build -t nginx-server -f Dockerfile.nginx .
```

Build output showed:

```text
[2/3] WORKDIR /usr/share/nginx/html
[3/3] COPY index.html .
```

### Tag

```bash
docker image tag nginx-server my-website:v1
```

### Run

```bash
docker run -d -p 80:80 my-website:v1
```

Port mapping shown by `docker ps`:

```text
0.0.0.0:80->80/tcp
```

Open `http://localhost` in a browser to see the page.

---

## Task 5 – `.dockerignore`

A `.dockerignore` file lists files and folders that should **not** be sent in the build context. It helps to:

* Reduce build context size
* Keep unnecessary files out of the image
* Keep secrets such as `.env` out of the build context
* Speed up builds

### Patterns used in the practical

```text
*.env
*.txt
```

### Build context

The build output showed the size of what was sent to Docker:

```text
transferring context: 173B
```

### Verify inside the container

```bash
docker exec -it <container-id> sh
ls -la
```

Output in `/app` (no project files were copied in):

```text
/app # ls -la
total 8
drwxr-xr-x    2 root     root     4096 ...
drwxr-xr-x    1 root     root     4096 ...
```

### Common exclusions for real projects

```text
node_modules
.git
*.md
.env
```

---

## Task 6 – Build Context and Layer Caching

### Build context

The `.` at the end of a build command is the **build context** (the current directory):

```bash
docker build -t dockerignore-prac .
```

Files used by `COPY` and `ADD` must be inside the build context and not excluded by `.dockerignore`.

### Layer caching

Docker caches each layer. When an instruction and its inputs haven't changed, the layer is reused:

```text
CACHED [2/3] WORKDIR /app
```

### Why instruction order matters

If an early layer changes, every layer after it is rebuilt. Put stable, slow steps first and frequently changing steps last:

```dockerfile
FROM ubuntu

RUN apt-get update && apt-get install curl -y

COPY application-files .

CMD ["..."]
```

If only the application files change, Docker reuses the cached dependency-install layer.

---

## Best Practices Learned

1. **Pick a suitable base image.** Smaller images such as `nginx:alpine` reduce the final size when they meet your needs.
2. **Combine related commands** so the package index is updated in the same layer as the install, and you avoid extra layers:

   ```dockerfile
   RUN apt-get update && \
       apt-get install curl -y
   ```

3. **Use `.dockerignore`** to exclude unnecessary files from the build context.
4. **Order instructions carefully**, with stable steps first and frequently changing steps last, to get the most out of caching.

---

## Key Concepts

**Image workflow**

```text
Dockerfile → docker build → Image → docker run → Container
```

**RUN vs CMD**

* `RUN` executes at **build time** (`RUN apt-get update`)
* `CMD` executes at **container start** (`CMD ["echo", "Hello"]`)

**COPY** transfers files from the build context into the image.

**EXPOSE** documents the port; publishing is done with `docker run -p 80:80 image`.

**WORKDIR** sets the working directory inside the image/container.

**.dockerignore** keeps unneeded files out of the build context, so builds are smaller, faster, and cleaner.

---

## Command Cheat Sheet

### Build

```bash
docker build -t my-ubuntu:v1 .
docker build -t ubuntu-entrypoint -f Dockerfile.entrypoint .
docker build -t nginx-server -f Dockerfile.nginx .
docker build -t dockerignore-prac .
```

### Run

```bash
docker run --name ubuntu-cont my-ubuntu:v1
docker run --name entrypoint-cont ubuntu-entrypoint "Hello , this is entrypoint argument"
docker run -d -p 80:80 my-website:v1
```

### Tag

```bash
docker image tag nginx-server my-website:v1
```

### Exec and inspect

```bash
docker exec -it <container> sh      # or bash
docker ps
```

---

## Final Project Structure

```text
day-31/
├── my-first-image/
│   ├── Dockerfile
│   ├── Dockerfile.entrypoint
│   ├── Dockerfile.nginx
│   └── index.html
└── day-31-dockerfile.md
```

---

## Conclusion

Day 31 moved me from running existing images to building my own. I wrote Dockerfiles using `FROM`, `RUN`, `COPY`, `WORKDIR`, `EXPOSE`, `CMD`, and `ENTRYPOINT`, built an Ubuntu image and an Nginx static-site image, practiced port mapping, used `.dockerignore`, and saw layer caching in action.

The key takeaway: a Dockerfile builds an image layer by layer, so good instruction ordering and a proper `.dockerignore` make builds faster and more efficient.
