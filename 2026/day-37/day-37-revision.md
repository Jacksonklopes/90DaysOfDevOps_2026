# Docker Revision Notes (Days 29–37)

One place to revise everything I learned about Docker. Written so I can understand it again after 100 days.

**Day 36 project code:** https://github.com/Jacksonklopes/Docker-projects/tree/main/day-36

---

## 1. The big picture

| Term | Meaning |
|---|---|
| **Image** | A read-only template (blueprint) used to create containers |
| **Container** | A running (or stopped) copy of an image. One image can make many containers |
| **Volume** | Storage managed by Docker that survives after a container is removed |
| **Bind mount** | A folder or file from the host mounted into a container |
| **Network** | A virtual network that lets containers talk to each other |
| **Registry** | A place to store images (Docker Hub) |

```
Dockerfile  --build-->  Image  --run-->  Container
                          |
                    docker push / pull
                          |
                      Docker Hub
```

A container is just a normal process on the host, isolated from other processes. It shares the host's kernel.

---

## 2. Container commands

| Command | Purpose |
|---|---|
| `docker run -it ubuntu bash` | Run interactively (you get a shell) |
| `docker run -d nginx` | Run in the background (detached) |
| `docker ps` | List running containers |
| `docker ps -a` | List all containers, including exited ones |
| `docker stop <name>` | Stop a container |
| `docker start <name>` | Start a stopped container |
| `docker restart <name>` | Restart a container |
| `docker rm <name>` | Remove a stopped container |
| `docker rm -f <name>` | Force remove (even if running) |
| `docker exec -it <name> sh` | Open a shell inside a **running** container |
| `docker logs <name>` | View logs |
| `docker logs -f <name>` | Follow logs live |
| `docker inspect <name>` | Detailed info (JSON) |

- `-it` = interactive + terminal. `-d` = detached (background).
- `docker exec` needs a running container. A container that already exited (like `hello-world`) can't be entered.
- `docker ps` hides exited containers. Use `docker ps -a`.

---

## 3. Image commands

| Command | Purpose |
|---|---|
| `docker pull nginx` | Download an image |
| `docker images` (or `docker image ls`) | List local images |
| `docker build -t myapp:v1 .` | Build an image from the Dockerfile in this folder |
| `docker tag myapp:v1 username/myapp:v1` | Add another name to an image |
| `docker push username/myapp:v1` | Upload to Docker Hub |
| `docker rmi myapp:v1` | Remove an image |
| `docker image inspect myapp:v1` | Inspect an image |

Image names look like `username/name:tag`. If you don't give a tag, Docker uses `latest`.

---

## 4. Dockerfile

### Instructions

| Instruction | Purpose |
|---|---|
| `FROM` | Base image to start from |
| `WORKDIR` | Set the working folder (created if missing) |
| `COPY` | Copy files from the host into the image |
| `ADD` | Like COPY, plus extract local tar files and download URLs |
| `RUN` | Run a command **while building** (install packages, etc.) |
| `ENV` | Set an environment variable |
| `ARG` | A variable available only during the build |
| `USER` | Run later instructions and the app as this user |
| `EXPOSE` | Documents which port the app listens on (does not publish it) |
| `VOLUME` | Declare a mount point |
| `CMD` | Default command when the container starts |
| `ENTRYPOINT` | The main executable of the container |

### COPY vs ADD
- `COPY` copies files and folders. Plain and predictable.
- `ADD` does the same, plus it **extracts local tar archives** (`.tar`, `.tar.gz`) and can download URLs. It does not extract `.zip`.
- Use `COPY` unless you specifically need the extra features.

### CMD vs ENTRYPOINT
- `CMD` = the default command. It is easy to override: `docker run image other-command`.
- `ENTRYPOINT` = the main program that always runs.
- They can work together: `ENTRYPOINT` is the program, `CMD` gives it default arguments.

### Image layers and build cache
- Each instruction that changes files creates a **layer**. Docker caches layers.
- If an instruction and its inputs haven't changed, Docker reuses the cached layer instead of running it again.
- Once one layer changes, every layer after it is rebuilt.

So put things that change **rarely** at the top, and things that change **often** at the bottom:

```dockerfile
FROM python:3.12-alpine
WORKDIR /app
COPY requirements.txt .            # changes rarely
RUN pip install -r requirements.txt  # reused from cache
COPY app.py .                      # changes often
CMD ["python", "app.py"]
```

If only `app.py` changes, the dependency install is reused and the rebuild is fast.

### Multi-stage builds
Use more than one `FROM`. Build in the first stage, and copy only the result into a small final stage.

```dockerfile
# Stage 1: builder (installs dependencies)
FROM python:3.12-slim AS builder
WORKDIR /app
COPY app/requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: runner (the final image)
FROM python:3.12-slim AS runner
WORKDIR /app
COPY --from=builder /install/ /usr/local
COPY app/ .
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser
EXPOSE 5000
CMD ["python", "app.py"]
```

- `AS builder` names a stage. `COPY --from=builder` copies from that stage. A plain `COPY` copies from the host.
- `--prefix=/install` makes pip install into a mini `/usr/local` layout (`lib/` and `bin/`). Copying `/install` into `/usr/local` puts everything where Python looks.
- Only the **last stage** becomes the final image. Build tools stay behind.
- **Why:** smaller, cleaner, and safer images. In Day 35, a Go app went from about **374 MB to 15.7 MB**.
- `COPY app/ .` copies the whole app folder (templates and static files too). Copying only `app.py` caused `TemplateNotFound`.

---

## 5. Volumes and bind mounts

| Command | Purpose |
|---|---|
| `docker volume create mydata` | Create a named volume |
| `docker volume ls` | List volumes |
| `docker volume inspect mydata` | Inspect a volume |
| `docker volume rm mydata` | Remove a volume |
| `docker volume prune` | Remove unused volumes |

```bash
docker run -d --name db -v mydata:/var/lib/postgresql/data postgres:16-alpine
```

- **Named volume:** Docker manages where it's stored. Use it for data you must keep (databases).
- **Bind mount:** you choose a host folder, for example `-v $(pwd):/app`. Handy for development.
- Data in the container's own writable layer is **lost** when the container is removed. Data in a named volume **stays**.

---

## 6. Networks

| Command | Purpose |
|---|---|
| `docker network create mynet` | Create a custom network |
| `docker network ls` | List networks |
| `docker network inspect mynet` | Inspect a network |
| `docker network connect mynet <container>` | Attach a container |
| `docker network disconnect mynet <container>` | Detach a container |
| `docker network rm mynet` | Remove a network |

- Containers on the same **custom** network reach each other **by name**. Docker provides the DNS.
- Never use `localhost` to reach another container. Each container has its own `localhost`.
- Example: a container named `db` is reachable at the host name `db`.

---

## 7. Ports

```bash
docker run -d -p 8080:80 nginx
```

Format: `-p HOST_PORT:CONTAINER_PORT`. Traffic to host port 8080 goes to container port 80.

On EC2, also open the **host** port in the security group. Don't publish database ports (3306, 5432) to the internet.

---

## 8. Docker Compose

Runs several containers from one YAML file.

| Command | Purpose |
|---|---|
| `docker compose up -d` | Create and start everything |
| `docker compose up --build -d` | Rebuild images, then start |
| `docker compose down` | Stop and remove containers and networks (keeps volumes) |
| `docker compose down -v` | Also remove the volumes (**deletes the data**) |
| `docker compose ps` | List containers |
| `docker compose logs <service>` | View logs |
| `docker compose logs -f <service>` | Follow logs |
| `docker compose build` | Build images |
| `docker compose pull` | Pull images |
| `docker compose restart` | Restart services |
| `docker compose config` | Validate and show the final config |

### Environment variables and `.env`
- A `.env` file next to `docker-compose.yml` holds values like the DB name and password.
- Compose substitutes `${MYSQL_PASSWORD}` in the YAML from `.env`.
- Never push `.env` to GitHub. Add it to `.gitignore`.
- Use the same variable for the app's password and the database's password, so they always match.
- MySQL and Postgres read the password only on the **first** start, when the volume is empty. If you change it later, run `docker compose down -v` first.

### Healthcheck and `depends_on`
- A **healthcheck** is a command Docker runs regularly to see if a service really works (for example `mysqladmin ping`).
- `depends_on` with `condition: service_healthy` makes a service start only after the other service is healthy.
- Plain `depends_on` only waits for the container to **start**, not to be **ready**.

### Service name = host name
In Compose, the service name is the host name. If the DB service is called `mysql`, the app connects to the host `mysql`.

---

## 9. Disk usage and cleanup

| Command | Purpose |
|---|---|
| `docker system df` | Disk usage of images, containers, volumes, build cache |
| `docker system df -v` | Detailed version |
| `docker container prune` | Remove stopped containers |
| `docker image prune` | Remove dangling images |
| `docker image prune -a` | Remove all unused images |
| `docker volume prune` | Remove unused volumes |
| `docker network prune` | Remove unused networks |
| `docker builder prune` | Remove build cache |
| `docker system prune` | Remove unused containers, networks, dangling images, build cache |
| `docker system prune -a` | The same, plus all unused images |

- `docker system df` shows **space usage**. `docker image ls` only **lists images**.
- Run `docker system df` before cleaning up, especially on a small EC2 disk.
- Prune commands delete things. Check first.

---

## 10. Day 36 project: Flask + MySQL

A message board. The browser talks to Flask, and Flask saves messages in MySQL.

```
Browser → Flask container (:5000, host :5001) → MySQL container (:3306) → Volume (mysql-data)
```

What it used: a multi-stage Dockerfile, Compose with two services, a custom network, a named volume, a healthcheck with `depends_on`, and `.env` for the password.

Run it:

```bash
cd day-36
docker compose up --build -d
docker compose ps
curl http://localhost:5001/health
```

Open `http://<EC2-public-IP>:5001`. The security group must allow port 5001.

Check the data:

```bash
docker exec -it mysql mysql -uroot -p
USE mydb;
SELECT * FROM messages;
```

That command means: run the `mysql` client program inside the container named `mysql`, as user `root`, and ask for the password.

Prove data persists: `docker compose down`, then `docker compose up -d`. The messages are still there.

---

## 11. Quick-fire questions

**Image vs container?**
An image is the blueprint. A container is a running or stopped instance of it.

**What happens to data when a container is removed?**
Data in the container's writable layer is lost. Data in a named volume stays.

**How do two containers talk on a custom network?**
By container (or service) name. Docker provides DNS on that network.

**`down` vs `down -v`?**
`down` removes containers and networks. `down -v` also removes the volumes.

**Why multi-stage builds?**
They keep build tools out of the final image, so it's smaller and safer.

**COPY vs ADD?**
`COPY` copies files. `ADD` also extracts local tar archives and downloads URLs. Prefer `COPY`.

**What does `-p 8080:80` mean?**
Host port 8080 forwards to container port 80.

**How do I check Docker disk usage?**
`docker system df` (or `docker system df -v` for details).

---

## 12. Revision checklist

Tick these off when I can do them without looking:

- [ ] Run containers interactively and detached
- [ ] List, stop and remove containers and images
- [ ] Explain image layers and the build cache
- [ ] Write a Dockerfile from scratch
- [ ] Explain CMD vs ENTRYPOINT
- [ ] Build and tag an image
- [ ] Create and use a named volume
- [ ] Use a bind mount
- [ ] Create a custom network
- [ ] Write a Compose file
- [ ] Use environment variables and `.env`
- [ ] Write a multi-stage Dockerfile
- [ ] Push an image to Docker Hub
- [ ] Use healthchecks and `depends_on`

---

## Takeaway

Images are blueprints, containers are disposable, volumes keep the data, networks connect services by name, and Compose runs it all together.

Consistency over perfection! #90DaysOfDevOps
