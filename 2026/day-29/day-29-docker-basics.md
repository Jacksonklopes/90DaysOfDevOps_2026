# Day 29 – Docker Basics

## Task 1: What is Docker?

### What is a container and why do we need it?

A container packages an application together with everything it needs to run: its files, libraries, and dependencies.

Without containers, an app can work on one machine and fail on another because of different versions, libraries, or configuration. A container behaves the same everywhere.

**Benefits:**
- Runs consistently across development, testing, and production
- Lightweight and starts quickly
- Many apps can run isolated from each other on one host
- Makes deployment easier and repeatable

### Containers vs Virtual Machines

| | Virtual Machine | Container |
|---|---|---|
| Operating system | Own full guest OS | Shares the host kernel |
| Managed by | Hypervisor | Docker Engine |
| Size | Large (GBs) | Small (MBs) |
| Startup | Slow (boots an OS) | Fast (starts a process) |
| Isolation | Stronger (separate kernels) | Process-level, on a shared kernel |

**Real difference:** a VM runs a whole separate operating system. A container shares the host's kernel and only packages the app and its dependencies.

### Docker Architecture

| Component | Role |
|---|---|
| **Client** | The tool I type commands into (`docker run`, `docker ps`). Sends requests to the daemon. |
| **Daemon** | Background service that manages images, containers, networks, and volumes. |
| **Image** | Read-only template used to create containers. |
| **Container** | A running instance created from an image. An instance of an image is a container created from that image. The image holds the application and all the dependencies it needs, and the container is the running copy that actually executes the application. |
| **Registry** | Stores images. Docker Hub is the default one. |

```text
Docker Client
     |
     | docker commands
     v
Docker Daemon
     |
     |---- Pulls images from Docker Hub
     |---- Builds images
     |---- Creates and manages containers
     v
Running Application
```

**In my own words:** I give commands to the client, and the daemon does the work. If the image isn't on my machine, the daemon pulls it from Docker Hub, creates a container from it, and starts it.

**Dockerfile → Image → Container**
- Dockerfile = blueprint (instructions)
- Image = packaged template built from it
- Container = running instance of the image

---

## Task 2: Install Docker

Docker was already installed on my AWS EC2 instance.

```bash
docker --version             # Check the installed version
sudo docker run hello-world  # Test Docker
```

The `hello-world` output explains what happened:
1. The Docker client contacted the daemon.
2. The daemon pulled the `hello-world` image from Docker Hub.
3. The daemon created a container from that image.
4. The container printed the message, and the daemon sent it to my terminal.

---

## Task 3: Run Real Containers

### 1. Nginx container

```bash
sudo docker run -d -p 80:80 nginx
```

| Part | Meaning |
|---|---|
| `-d` | Run in the background |
| `-p 80:80` | Map host port 80 to container port 80 |
| `nginx` | The image |

I opened the EC2 public IP in my browser and saw the default Nginx welcome page.

### 2. Ubuntu container (interactive mode)

```bash
sudo docker run -it --name my-ubuntu ubuntu bash
```

| Part | Meaning |
|---|---|
| `-i` | Keep input open |
| `-t` | Allocate a terminal |
| `--name my-ubuntu` | Custom name |
| `bash` | The command to run (the main process) |

Inside the container:

```bash
ls
cd /home/ubuntu
echo "test" > file.txt
ls
```

When I typed `exit`, the container stopped. A container only runs as long as its main process, and here that was `bash`.

### 3. List running containers

```bash
sudo docker ps
```

### 4. List all containers (including stopped)

```bash
sudo docker ps -a
```

`ps` shows running containers only. `ps -a` also shows stopped ones, like my Ubuntu container.

### 5. Stop and remove a container

```bash
sudo docker stop CONTAINER_NAME
sudo docker rm CONTAINER_NAME
```

A running container must be stopped before it can be removed. Removing a container does not remove its image (use `docker rmi` for that).

---

## Task 4: Explore

### 1. Detached mode

```bash
sudo docker run -d --name background-nginx nginx
```

Without `-d`, the container runs attached to my terminal and blocks it. With `-d`, it runs in the background and I get my terminal back.

### 2. Custom name

```bash
sudo docker run -d --name my-nginx -p 8080:80 nginx
```

If I don't give a name, Docker generates one (my Nginx container was `agitated_austin`). Names are easier to use than container IDs.

### 3. Port mapping

Format: `-p HOST_PORT:CONTAINER_PORT`

```bash
sudo docker run -d -p 8080:80 --name nginx-test nginx
```

Nginx listens on port 80 inside the container, and I reach it through port 8080 on the host: `http://EC2-PUBLIC-IP:8080`.

The EC2 security group must allow inbound traffic on the host port (8080), otherwise the browser can't connect.

### 4. Check logs

```bash
sudo docker logs agitated_austin
```

The logs showed Nginx starting and handling requests:
- `200` means the request succeeded
- `404` means the resource wasn't found (I saw it for `/favicon.ico`, which browsers request automatically)

### 5. Run a command inside a running container

```bash
sudo docker exec -it agitated_austin bash
```

`docker exec` runs a command inside an already running container. It does not create a new one.

Some commands (`top`, `ss`) were missing because the Nginx image is minimal. `systemctl` didn't work because a container runs one main process, not a full init system like systemd.

Exiting this shell does not stop the container, because the main process (Nginx) is still running. This is different from the Ubuntu container, where the shell itself was the main process.

### Bonus: container processes

```bash
sudo docker top agitated_austin
```

- `nginx: master process` manages the workers
- `nginx: worker process` handles requests

---

## Commands Summary

| Command | Purpose |
|---|---|
| `docker --version` | Check version |
| `docker run` | Create and start a container |
| `docker ps` | List running containers |
| `docker ps -a` | List all containers |
| `docker images` | List local images |
| `docker pull` | Download an image |
| `docker stop` | Stop a container |
| `docker start` | Start a stopped container |
| `docker rm` | Remove a container |
| `docker rmi` | Remove an image |
| `docker logs` | View logs |
| `docker exec -it` | Run a command inside a running container |
| `docker top` | Show container processes |

---

## What I Learned

- What Docker and containers are, and why they're useful
- How containers differ from virtual machines
- The roles of the client, daemon, image, container, and registry
- Running `hello-world`, Nginx, and Ubuntu containers
- Detached mode, custom names, port mapping, logs, and `docker exec`
- A container lives only as long as its main process
