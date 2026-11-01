# Day 34 – Docker Compose: Real-World Multi-Container Apps

## What I built

A 3-container app run with one `docker-compose.yml`:

```text
Browser → web (Flask, port 5000) → db (PostgreSQL, port 5432)
                                 → redis (Redis cache, port 6379)
```

| Service | What it is | Image |
| ------- | ---------- | ----- |
| `web` | Python Flask app | built from my own Dockerfile |
| `db` | PostgreSQL database | `postgres:16-alpine` |
| `redis` | Cache | `redis:alpine` |

The web app talks to the other two **by service name** (`db`, `redis`), not by IP address. Compose puts all services on one network where these names work.

---

## Project files

```text
day-34-compose/
├── docker-compose.yml
└── app/
    ├── Dockerfile
    ├── app.py              ← Flask app that connects to db and redis
    └── requirements.txt    ← Python packages the app needs
```

### app/Dockerfile

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN apt-get update && apt-get install -y curl

RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
```

- `requirements.txt` is copied and installed **before** the code, so Docker can reuse the cached install layer when only the code changes.
- Mistake I made: I first used `apk add curl`. That failed, because `apk` is for **Alpine** images. This image is **Debian**-based, so it needs `apt-get`.

### docker-compose.yml

```yaml
services:

  web:
    build: ./app
    ports:
      - "5000:5000"
    environment:
      DB_HOST: db
      DB_NAME: day34db
      DB_USER: admin
      DB_PASSWORD: secret123
      REDIS_HOST: redis
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    restart: on-failure
    labels:
      project: "day-34"
      service: "flask-web"

  db:
    image: postgres:16-alpine
    restart: always
    environment:
      POSTGRES_DB: day34db
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: secret123
    volumes:
      - postgres-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U admin -d day34db"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 10s
    labels:
      project: "day-34"
      service: "postgres-database"

  redis:
    image: redis:alpine
    labels:
      project: "day-34"
      service: "redis-cache"

volumes:
  postgres-data:

networks:
  default:
    name: day34-app-network
```

> The passwords are written in plain text because this is for learning. Real projects keep them in a `.env` file that is not pushed to Git.

### How to run it from scratch

```bash
cd ~/day-34-compose
docker compose up -d --build     # build the web image and start everything
docker compose ps                # check status
curl http://localhost:5000       # test the web app
```

---

## Task 1 – The 3-service stack

`web` is built from my Dockerfile with `build: ./app`. `db` and `redis` use ready-made images. All three are defined in one file and started with one command.

---

## Task 2 – depends_on and healthchecks

**Problem:** a container being *started* does not mean the program inside is *ready*. PostgreSQL needs a few seconds to set itself up. If Flask starts too early, its connection to the database fails.

**Solution, in two parts:**

**1. A healthcheck on `db`:** Docker runs a test command again and again to see if the database is ready.

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U admin -d day34db"]
  interval: 10s
  timeout: 5s
  retries: 5
  start_period: 10s
```

| Field | Meaning |
| ----- | ------- |
| `test` | The command Docker runs. `pg_isready` asks "is PostgreSQL accepting connections?" |
| `interval` | How often to run the test (every 10 seconds) |
| `timeout` | How long to wait for one test to answer (5 seconds) |
| `retries` | How many failed tests in a row before the container is marked `unhealthy` (5) |
| `start_period` | Grace time at the start, when failures aren't counted yet (10 seconds) |

A container's health is `starting`, then `healthy`, or `unhealthy`.

**2. `depends_on` with a condition on `web`:**

```yaml
depends_on:
  db:
    condition: service_healthy
  redis:
    condition: service_started
```

| Condition | Meaning |
| --------- | ------- |
| `service_healthy` | Wait until `db` passes its healthcheck |
| `service_started` | Wait only until `redis` has started (not until it is ready) |

**Test:**

```bash
docker compose down
docker compose up -d
docker compose ps
docker inspect day-34-compose-db-1 --format '{{.State.Health.Status}}'
```

**Result:** `db` showed `healthy` before `web` started, so the app waited for the database.

---

## Task 3 – Restart policies

A restart policy tells Docker what to do when a container **stops**. It is set with `restart:` in the YAML.

### What each policy does in each situation

| Situation | `no` | `on-failure` | `always` | `unless-stopped` |
| --------- | ---- | ------------ | -------- | ---------------- |
| Application exits with code 1 (failure) | Stops | Restarts | Restarts | Restarts |
| Application exits with code 0 (success) | Stops | Stops | Restarts | Restarts |
| Manually stopped using `docker stop` | Stays stopped | Stays stopped | Stays stopped | Stays stopped |
| Docker daemon restarts after manual stop | Stays stopped | Stays stopped | Starts again | Stays stopped |
| Docker daemon restarts without manual stop | Stays stopped | Stays stopped | Starts again | Starts again |
| Container created for the first time | Starts | Starts | Starts | Starts |

The "Docker daemon" is the Docker service on the machine (restarted with `sudo systemctl restart docker`).

I tested the exit code 1 and exit code 0 rows with the four-container test below. For `always`, I saw `db` come back after a Docker service restart, and a container with no policy stayed stopped. The other cells come from the Docker documentation.

### When to use each policy

- `no` (default): one-time jobs and scripts that should run once.
- `on-failure`: jobs that should retry after a crash, but be left alone when they finish properly.
- `always`: things that must always be running, like a database.
- `unless-stopped`: same as `always`, when a container I stopped on purpose should not come back after a reboot.

In my stack: `db` uses `restart: always` and `web` uses `restart: on-failure`.

Exit code: `0` means finished fine, anything else (like `1`) means an error.

### My test (separate folder `restart-policy-test`)

Four tiny containers. Each one runs for 12 seconds and then exits. They are the same except for the `restart:` line and the exit code:

```yaml
services:

  policy-no:
    image: alpine
    container_name: policy-no
    command: ["sh", "-c", "sleep 12; exit 0"]


  policy-always:
    image: alpine
    container_name: policy-on-always
    command: ["sh", "-c", "sleep 12; exit 1"]
    restart: always

  policy-on-failure:
    image: alpine
    container_name: policy-on-failure
    command:  ["sh", "-c", "sleep 12; exit 1"]
    restart: on-failure

  policy-unless-stopped:
    image: alpine
    container_name: policy-unless-stopped
    command: sh -c 'echo "Starting policy-unless-stopped"; sleep 12; exit 1'
    restart:  unless-stopped
```

What the `command` means:

- `sh -c "..."` runs the text as a shell command.
- `sleep 12` waits 12 seconds, so the container stays running for a while.
- `exit 0` stops it cleanly (success). `exit 1` stops it with an error.

**Why `sleep 12`:** Docker only applies a restart policy to a container that has been running for at least 10 seconds. A container that stops instantly is not restarted the normal way. The 12 seconds also give me time to run `docker exec` into the container while it is up.

```bash
docker compose up -d
```

Wait about 30 seconds, then check the status:

```bash
docker compose ps -a
```

Restart the Docker service to test the restart policies:

```bash
sudo systemctl restart docker
docker ps
```

### Restart counter

```bash
docker inspect <container> --format 'RestartCount={{.RestartCount}}'
```

It counts restarts done **by the policy while Docker is running**. It stayed `0` for `db` after I restarted the Docker service, even though the container did come back.

---

## Task 4 – Build from a Dockerfile and rebuild with one command

Instead of an `image:`, the `web` service uses:

```yaml
web:
  build: ./app
```

This means "build the image from the Dockerfile in the `app` folder".

After changing the code in `app.py`:

```bash
docker compose up -d --build
```

| Command | What it does |
| ------- | ------------ |
| `docker compose up -d` | Starts the services. It does not rebuild the image when the code changed. |
| `docker compose up -d --build` | Rebuilds the images first, then starts or updates the services |

One command rebuilds the image and replaces the web container with the new version.

---

## Task 5 – Named network, named volume, labels

**Network:** by default Compose creates a network with an automatic name. I gave it my own name:

```yaml
networks:
  default:
    name: day34-app-network
```

All services join this network, so `web` can reach `db` and `redis` by name.

**Volume:** the database files are stored in a named volume, so the data survives when the container is removed:

```yaml
volumes:
  - postgres-data:/var/lib/postgresql/data     # inside the db service

volumes:
  postgres-data:                               # at the bottom of the file
```

Compose adds the project name in front, so the real name is `day-34-compose_postgres-data`.

> `docker compose down` keeps the volume. `docker compose down -v` deletes it, and the data with it.

**Labels:** key-value tags on a container, used to organize and filter:

```yaml
labels:
  project: "day-34"
  service: "flask-web"
```

**Check all three:**

```bash
docker network inspect day34-app-network
docker volume ls
docker inspect day-34-compose-web-1 --format '{{json .Config.Labels}}'
```

---

## Task 6 (bonus) – Scaling to 3 replicas

```bash
docker compose up -d --scale web=3
```

This creates 3 copies (replicas) of the `web` service.

With `ports: "5000:5000"` in the YAML, it fails with `port is already allocated`. One port on the EC2 machine can belong to only one container, so the 2nd and 3rd replicas can't use it.

After I removed the `ports:` section from `web`, all 3 replicas ran. Each one listens on port **5000 inside its own container**, because `app.py` runs the app on port 5000 (`app.run(host="0.0.0.0", port=5000)`). Every container has its own network, so the same port inside each of them doesn't clash.

Without `ports:`, the replicas can't be opened from the browser. So we add a **load balancer** (for example Nginx) in front. It owns the one public port and sends each request to one of the replicas:

```text
Users → Load balancer (one public port) → web 1
                                        → web 2
                                        → web 3
```

---

## Quick recap

1. One `docker-compose.yml` runs the whole stack: `docker compose up -d`.
2. **Healthcheck** + `depends_on: condition: service_healthy` = the app waits until the database is really ready.
3. **Restart policies** (`no`, `on-failure`, `always`, `unless-stopped`) decide what Docker does when a container stops. `docker kill` and `docker stop` don't trigger them.
4. `build: ./app` builds from my Dockerfile. `docker compose up -d --build` rebuilds and restarts in one command.
5. Named network, named volume, and labels keep things organized. A volume keeps the data when containers are removed.
6. Scaling fails with a fixed host port, because one host port can belong to only one container. A load balancer solves it.

## Commands used

```bash
docker compose up -d --build         # build and start
docker compose up -d --scale web=3   # run 3 web containers
docker compose ps                    # status (add -a to include stopped)
docker compose logs web              # logs of the web service
docker compose down                  # remove containers and network (keeps volumes)
docker inspect <container> --format '{{.State.Health.Status}}'   # health
docker inspect <container> --format 'RestartCount={{.RestartCount}}'
docker network inspect day34-app-network
docker volume ls
sudo systemctl restart docker        # test restart policies
```
