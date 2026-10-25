# Day 32 – Docker Volumes & Networking

## Goal

Understand two things:

1. **Storage:** how Docker keeps data safe even when a container is deleted.
2. **Networking:** how containers talk to each other.

By the end, an application container reaches a PostgreSQL database **by its container name**, and the database keeps its data across container replacements.

---

## Terms for First-Time Readers

| Term | Simple meaning |
| ---- | -------------- |
| **Container** | A running instance of an image. It is temporary and can be replaced at any time. |
| **Writable layer** | The thin storage area each container gets for files it creates while running. It is deleted together with the container. |
| **Volume** | A storage area managed by Docker, kept **outside** the container, so the data survives when the container is removed. |
| **Bind mount** | A direct link between a folder on the host machine and a folder inside the container. |
| **Network** | A virtual network that lets containers send traffic to each other. |
| **Bridge network** | The most common Docker network type. It works like a virtual switch that connects containers on the same machine. |
| **Network interface** | A connection point between a machine (or container) and a network. It holds an IP address. |
| **DNS** | The system that turns a name (like `pg-with-volume-2`) into an IP address. |
| **Host** | The machine Docker runs on (here, an EC2 instance). |

---

## Task 1 – What Happens to Data Without a Volume?

### The problem

Containers are temporary. When a container is removed, its writable layer is removed too. If a database stores its files only inside the container, **removing the container deletes the data**.

### What I did

**Step 1: Run a lightweight PostgreSQL container (no volume)**

```bash
docker run -d \
  --name my-lightweight-postgres \
  -e POSTGRES_PASSWORD=<your-password> \
  postgres:alpine
```

| Part | Meaning |
| ---- | ------- |
| `-d` | Run in the background |
| `--name my-lightweight-postgres` | Name of the container |
| `-e POSTGRES_PASSWORD=...` | Sets the database password. PostgreSQL will not start without it. |
| `postgres:alpine` | The PostgreSQL image built on Alpine Linux, which is much smaller than the default image ("lightweight") |

Check that it is running:

```bash
docker ps
```

**Step 2: Open the PostgreSQL command line (`psql`) inside the container**

```bash
docker exec -it my-lightweight-postgres psql -U postgres
```

| Part | Meaning |
| ---- | ------- |
| `docker exec -it` | Run an interactive command inside a running container |
| `my-lightweight-postgres` | The container to enter |
| `psql -U postgres` | Start the PostgreSQL client as the user `postgres` |

The prompt changes to `postgres=#`. Everything typed from here is SQL.

**Step 3: Create a table and insert data**

```sql
CREATE TABLE students (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50)
);

INSERT INTO students (name) VALUES ('Jackson'), ('Rahul');

SELECT * FROM students;
```

The `SELECT` shows both records. Type `\q` to leave `psql`.

**Step 4: Remove the container and create a new one**

```bash
docker rm -f my-lightweight-postgres
# Force-remove the container (its writable layer is deleted with it)

docker run -d \
  --name my-lightweight-postgres \
  -e POSTGRES_PASSWORD=<your-password> \
  postgres:alpine
# Create a fresh container with the same name and image
```

**Step 5: Check the database again**

```bash
docker exec -it my-lightweight-postgres psql -U postgres
```

```sql
SELECT * FROM students;
```

Result:

```text
ERROR:  relation "students" does not exist
```

### Observation

The `students` table and its records were **gone** in the new container.

### Meaning

The new container started with a fresh writable layer and had none of the old container's data. A container is replaceable, so important data must be stored separately.


---

## Task 2 – Named Volumes

### What is a named volume?

A Docker volume stores data **outside** the container's writable layer. Docker manages where it lives on the host. A new container can attach to the same volume and see the same data. The volume stays until you delete it yourself.

### Create and inspect a volume

```bash
docker volume create pg-data
# Create a named volume called pg-data

docker volume ls
# List all volumes

docker volume inspect pg-data
# Show details, including the mountpoint (where Docker stores it on the host)
```

### Attach the volume to PostgreSQL

**Which path do I mount the volume to?**

A volume must be mounted at the folder where the application stores its data **inside the container**. Different images use different folders, so don't guess. Ask the image itself:

```bash
docker image inspect --format='{{json .Config.Volumes}}' postgres:alpine
# Show the folders this image declares as data volumes
```

For PostgreSQL the output looks like this:

```text
{"/var/lib/postgresql/data":{}}
```

That is the path to use on the right side of `-v`. You can also check the environment variables of the image, which may show where the data lives (`PGDATA`):

```bash
docker image inspect --format='{{json .Config.Env}}' postgres:alpine
```

> The image must be on the machine first (`docker pull postgres:alpine`). The data folder can differ between image versions (newer PostgreSQL images changed it), so always inspect the exact image and tag you use.

The same idea applies to other images:

| Image | How to find its data path |
| ----- | ------------------------- |
| `postgres` | `docker image inspect --format='{{json .Config.Volumes}}' postgres:alpine` |
| `mysql` | `docker image inspect --format='{{json .Config.Volumes}}' mysql` |
| any image | Same command, or read the "Volumes" section of its page on Docker Hub |

The key part of the `docker run` command is then:

```bash
-v pg-data:/var/lib/postgresql/data
```

| Part | Meaning |
| ---- | ------- |
| `pg-data` | The volume name (stored on the host, managed by Docker) |
| `:` | Separates the volume from the path inside the container |
| `/var/lib/postgresql/data` | The folder where PostgreSQL stores its database files inside the container (the path found with `docker image inspect` above) |

Full command (the password is a placeholder; PostgreSQL requires one to start):

```bash
docker run -d \
  --name pg-with-volume \
  -e POSTGRES_PASSWORD=<your-password> \
  -v pg-data:/var/lib/postgresql/data \
  postgres:alpine
```

Then create the table and insert the records in the same way as Task 1:

```bash
docker exec -it pg-with-volume psql -U postgres
```

```sql
CREATE TABLE students (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50)
);

INSERT INTO students (name) VALUES ('Jackson'), ('Rahul');

SELECT * FROM students;
```

Type `\q` to leave `psql`.

Now remove this container (the volume stays) before creating the replacement:

```bash
docker rm -f pg-with-volume
# Remove the container only; the pg-data volume is NOT deleted
```

### Verify that the data persists

I created a **replacement** container named `pg-with-volume-2` using the same `pg-data` volume:

```bash
docker run -d \
  --name pg-with-volume-2 \
  -e POSTGRES_PASSWORD=<your-password> \
  -v pg-data:/var/lib/postgresql/data \
  postgres:alpine
```

Then I checked that the volume and data were still there:

```bash
docker volume ls
# Confirm pg-data still exists

docker volume inspect pg-data
# Inspect the persistent volume

docker start pg-with-volume-2
# Start the container if it is stopped

docker exec -it pg-with-volume-2 psql -U postgres
# Open the PostgreSQL command-line client inside the container
```

Inside PostgreSQL:

```sql
SELECT * FROM students;
-- Show the saved records
```

### Observation

The records for Jackson and Rahul were **still there** in the new container.

### Meaning

The data was stored in the `pg-data` volume, not in the container's writable layer. The container was replaced, and the data stayed.


---

## Task 3 – Bind Mounts

### What is a bind mount?

A bind mount connects a **specific folder or file on the host** to a location inside the container. Unlike a named volume, **I choose the host path** myself.

### Host folder and file

```text
/home/ubuntu/website/index.html
```

Initial content:

```html
<h1>Hello from my EC2 host!</h1>
```

### Run Nginx with the bind mount

```bash
docker run -d \
  --name bind-mount-nginx \
  -p 8081:80 \
  -v /home/ubuntu/website:/usr/share/nginx/html \
  nginx:alpine
```

| Part | Meaning |
| ---- | ------- |
| `-p 8081:80` | Publish container port 80 on **host port 8081**. Port 80 was already in use on the host. |
| `-v /home/ubuntu/website:/usr/share/nginx/html` | Link the host folder to the folder Nginx serves its website from |
| `nginx:alpine` | A small Nginx image |

### Test it

```bash
curl http://localhost:8081
# Show the HTML that Nginx serves
```

Output:

```text
Hello from my EC2 host!
```

### Change the file on the host

```bash
echo '<h1>Updated directly from EC2!</h1>' > /home/ubuntu/website/index.html
# Overwrite the website file on the host

curl http://localhost:8081
# Check what Nginx serves now
```

### Observation

The new content appeared **immediately**, without rebuilding the image or restarting the container.

### Meaning

The host folder and the container folder are the same files, seen from two places. Editing one changes the other.


---

## Task 4 – The Default Bridge Network

### What is a Docker network?

A Docker network lets containers send traffic to each other (and, depending on its type, to outside networks). It is separate from storage: a network connects containers, a volume stores data.

### List the networks

```bash
docker network ls
```

Docker has three built-in networks:

| Network | What it does |
| ------- | ------------ |
| `bridge` | The **default** network for containers. A virtual switch inside the host. |
| `host` | The container shares the host's network directly. |
| `none` | No networking at all. |

### Inspect the default bridge

```bash
docker network inspect bridge
```

What I found:

| Item | Value |
| ---- | ----- |
| Network | `bridge` |
| Subnet | `172.17.0.0/16` (the range of IPs containers get) |
| Gateway | `172.17.0.1` |
| Host-side interface | `docker0` |

### What is `docker0`?

```bash
ip addr show docker0
# Show the host's docker0 network interface
```

It had the address `172.17.0.1/16`.

`docker0` is the host's end of the default bridge. It works like a **virtual switch**: every container on the default bridge is plugged into it with a virtual cable, and its address `172.17.0.1` is the gateway the containers use to reach the host and, through the host, the outside world.

### Test two containers by IP address

I used two Ubuntu containers on the default bridge:

| Container | IP |
| --------- | -- |
| `test-a` | `172.17.0.2` |
| `test-b` | `172.17.0.3` |

```bash
docker exec test-a ping -c 5 172.17.0.3
# From test-a, ping test-b using its IP address
```

The ping **succeeded** with no packet loss.

### Test by container name

```bash
docker exec test-a ping -c 4 test-b
# From test-a, ping test-b using its name
```

Output:

```text
ping: test-b: Name or service not known
```

### Observation

On the default bridge, containers can reach each other by **IP address**, but **not by name**, because the default bridge does not provide name lookup (DNS) between containers.

### Why this matters

IP addresses change every time a container is recreated, so relying on them is fragile. Names are stable.


---

## Task 5 – Custom Bridge Network

### Why use a custom bridge?

A **user-defined bridge** gives containers automatic DNS. A container can reach another connected container using its **name** instead of a hard-coded IP.

### Create the network and connect the containers

```bash
docker network create my-app-network
# Create a custom bridge network

docker network connect my-app-network test-a
docker network connect my-app-network test-b
# Connect both existing containers to it

docker network inspect my-app-network
# Check the network and its connected containers
```

`docker network connect` adds a **second** connection. The containers stay on the default bridge as well, so each now has two network interfaces: one on `172.17.0.0/16` and one on the custom network.

The custom network used:

| Item | Value |
| ---- | ----- |
| Subnet | `172.18.0.0/16` |
| Gateway | `172.18.0.1` |
| `test-a` | `172.18.0.2` |
| `test-b` | `172.18.0.3` |

### Test by name

```bash
docker exec test-a ping -c 4 test-b
```

The ping **succeeded**, and the output showed `test-b` resolving to `172.18.0.3`.

> I later disconnected both containers from `my-app-network` (with `docker network disconnect`) so I could repeat the default-bridge name test on its own.

### Observation

| Network | Ping by IP | Ping by name |
| ------- | ---------- | ------------ |
| Default bridge | Works | **Fails** |
| Custom bridge | Works | **Works** |

### Meaning

A custom bridge network makes it much easier for application containers to find each other, because Docker's built-in DNS resolves container names.


---

## Task 6 – Connect an App Container to PostgreSQL

### Goal

Put an app container and the database on the same custom network, so the app can reach PostgreSQL **by container name**.

### Steps

```bash
docker network create my-app-net
# Create a new custom network for the app and database

docker network connect my-app-net pg-with-volume-2
# Connect the existing PostgreSQL container to it

docker run -dit \
  --name my-app \
  --network my-app-net \
  ubuntu:latest bash
# Start an Ubuntu container directly on my-app-net
```

The database already uses the `pg-data` volume, so its records are preserved.

> `my-app-net` (this task) is a **different network** from `my-app-network` (Task 5). I created a new one so each task could be tested separately.

### Inspect the network

```bash
docker network inspect my-app-net
```

| Container | IP on `my-app-net` |
| --------- | ------------------ |
| `pg-with-volume-2` | `172.19.0.2` |
| `my-app` | `172.19.0.3` |

### Test 1: ping by name

```bash
docker exec my-app ping -c 4 pg-with-volume-2
```

Result: 4 packets sent, 4 received, 0% loss, and the name resolved to `172.19.0.2`.

### Test 2: TCP connection to PostgreSQL's port

```bash
docker exec my-app bash -c 'echo > /dev/tcp/pg-with-volume-2/5432'
# Try to open a TCP connection to port 5432 using the container name

echo $?
# Show the exit status of the previous command (0 = success)
```

The test worked (exit status `0`). Port `5432` is PostgreSQL's default port.

### Observation

The app container could reach the PostgreSQL container **by name**, over the shared custom network.

### Meaning

Docker's DNS lets the app find the database without knowing its IP address.

> **Important:** This proves the **network path** and the **port** are reachable. It does not prove that the app logged in to PostgreSQL or ran a query. That needs a real database client or application.


---

## How It All Fits Together

```text
            my-app-net (custom bridge, 172.19.0.0/16)
        ┌────────────────────────────────────────────┐
        │                                            │
   my-app (172.19.0.3)  ───────►  pg-with-volume-2 (172.19.0.2)
   ping / connect by name          PostgreSQL on port 5432
                                          │
                                          ▼
                                 pg-data volume (data kept
                                 even if the container is replaced)
```

---

## Key Comparisons

### Named Volume vs Bind Mount

| Feature | Named volume | Bind mount |
| ------- | ------------ | ---------- |
| Where the data lives | Managed by Docker | A host path **I choose** |
| Example | `pg-data` | `/home/ubuntu/website` |
| Typical use | Databases and persistent app data | Website files, config, development files |
| Survives container removal | Yes, until the volume is deleted | Yes, the files stay on the host |
| Created by | `docker volume create` or `-v name:path` | `-v /host/path:/container/path` |

### Default Bridge vs Custom Bridge

| Feature | Default bridge | Custom bridge |
| ------- | -------------- | ------------- |
| Containers can talk by IP | Yes | Yes |
| Containers can talk by **name** (DNS) | **No** (in my test) | **Yes** |
| Example | `bridge` | `my-app-net` |
| Isolation | Containers on this network can talk to each other | Containers on this network can talk to each other, and containers on a **different** network are separated from it |

---

## Important Commands

```bash
# Volumes
docker volume create pg-data      # Create a named volume
docker volume ls                  # List volumes
docker volume inspect pg-data     # Show volume details

# Networks
docker network ls                       # List networks
docker network create my-app-net        # Create a custom bridge network
docker network inspect bridge           # Inspect the default bridge
docker network inspect my-app-net       # Inspect a custom network
docker network connect <net> <ctr>      # Add a running container to a network
docker network disconnect <net> <ctr>   # Remove a container from a network

# Containers
docker ps                         # Running containers
docker ps -a                      # Running and stopped containers
docker exec -it <ctr> <command>   # Run a command inside a running container

# Host
ip addr show docker0              # Show the host side of the default bridge
```

---

## Day 32 Summary

* Data stored only in a container's writable layer is **lost** when the container is removed.
* **Named volumes** keep data independent of the container's life.
* **Bind mounts** link a host folder to a container folder, so edits show up instantly.
* **Docker networks** let containers communicate.
* The **default bridge** connects containers by IP only. A **custom bridge** also gives them **name-based DNS**.
* An app container can reach PostgreSQL by container name and port on a shared custom network.

**Key takeaway:** Containers can be replaced at any time, so keep important data in a volume, and put related containers on a custom network so they can find each other by name.

---

## GitHub Submission

Save this file as:

```text
2026/day-32/day-32-volumes-networking.md
```

Then commit and push it to the `master` branch of the `90DaysOfDevOps_2026` repository.
