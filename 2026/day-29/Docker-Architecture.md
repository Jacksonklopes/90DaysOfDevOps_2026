# Docker Architecture (CLI → Container → Exit)

## Interview answer (one line)

Docker uses a **client-server architecture**. The Docker CLI sends REST API requests to the Docker daemon (`dockerd`). The daemon manages images, networks and volumes, and hands container execution to `containerd`, which uses `runc` to create the container. Images come from a registry such as Docker Hub.

---

## Diagram

```
docker CLI (client)
      │  REST API  (unix socket /var/run/docker.sock)
      ▼
dockerd (Docker daemon) ───────────►  Registry (Docker Hub)
      │                               pull / push images
      │  gRPC(G remote procedure call )  (containerd.sock)
      ▼
containerd
      │
      ▼
containerd-shim
      │  starts
      ▼
runc ──creates──►  Container process  (isolated by namespaces + cgroups)
```

---

## Components, in order

| # | Component | What it does |
|---|---|---|
| 1 | **Docker CLI** | The `docker` command. It only sends requests and prints answers. |
| 2 | **dockerd (Docker daemon)** | Background service. Handles the API, image builds, networks and volumes. "Docker daemon" and `dockerd` are the same thing. |
| 3 | **Registry** | Stores images (Docker Hub, ECR). dockerd pulls from it and pushes to it. |
| 4 | **containerd** | A separate, lower-level program. Pulls image layers, manages container lifecycle (create, start, stop, delete). |
| 5 | **containerd-shim** | A small process kept per container. Stays alive as the container's parent, keeps its input and output open, and reports its exit. |
| 6 | **runc** | Creates the container using Linux kernel features, starts the app, then exits. |
| 7 | **Container** | A normal Linux process with an isolated view of the system. |

## How they talk

| From → To | Protocol |
|---|---|
| CLI → dockerd | REST API over `/var/run/docker.sock` |
| dockerd → containerd | gRPC over `containerd.sock` |
| containerd → shim → runc | Starts them as processes |

---

## Life of a container: `docker run nginx`

1. **CLI** sends the request to `dockerd`.
2. **dockerd** checks for the image locally. If it's missing, it **pulls** it from the registry.
3. dockerd prepares the container: image layers, network, volumes.
4. dockerd asks **containerd** to create and start it.
5. containerd starts a **shim**, and the shim calls **runc**.
6. **runc** sets up namespaces and cgroups, starts the app (`nginx`), then exits.
7. The container is now **running**. The shim stays as its parent.

## Exit of a container

1. The app inside the container stops (it finishes, crashes, or you run `docker stop`).
2. The **shim** sees the process end and collects its **exit code**.
3. The shim tells **containerd**, which tells **dockerd**.
4. dockerd marks the container as **Exited (code)**. You see it in `docker ps -a`.
5. The container's writable layer stays until you remove it (`docker rm`), or it is removed automatically if you used `--rm`.
6. If a **restart policy** is set (`--restart always`), dockerd starts it again.

---

## Why containers are isolated

- **Namespaces:** control what a container can **see** (processes, network, filesystem, hostname).
- **cgroups:** control what a container can **use** (CPU, memory).
- Containers **share the host kernel**. That's why they are lighter and faster than VMs, which each run their own OS.

---

## Check it on my own server

```bash
docker version                          # separate Client and Server sections
ps aux | grep -E "dockerd|containerd"   # both run as separate processes
ls -l /var/run/docker.sock              # the socket the CLI talks to
```

If the daemon is stopped, every docker command fails with "Cannot connect to the Docker daemon", because the CLI has nothing to talk to.

---

## Remember

**CLI asks → dockerd manages → containerd supervises → shim watches → runc creates → kernel isolates.**
