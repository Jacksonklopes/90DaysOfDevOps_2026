# Day 30 – Docker Images & Container Lifecycle

## Task 1: Docker Images

### 1. What is a Docker Image?

A Docker image is a template used to create Docker containers. It contains the application, required libraries, files, and configuration.

### 2. Pull Docker Images

```bash
docker pull nginx       # Download the Nginx image
docker pull ubuntu      # Download the Ubuntu image
docker pull alpine      # Download the Alpine image
```

### 3. List Docker Images

```bash
docker images           # List images downloaded to the local machine
```

**My observation:**

| Image | Size | Content size |
|---|---:|---:|
| Alpine | 13 MB | 3.94 MB |
| Ubuntu | 162 MB | 45.6 MB |
| Nginx | 243 MB | 66.7 MB |

- **Alpine:** A small Linux image that is useful for lightweight containers.
- **Ubuntu:** A general-purpose Linux image with more included components.
- **Nginx:** An image containing the Nginx web server.

Image size and content size are different measurements shown by Docker.

### 4. Inspect a Docker Image

```bash
docker image inspect nginx  # View detailed information about the Nginx image
```

This command displays image configuration, architecture, layers, and other details.

### 5. Remove an Image

```bash
docker image rm IMAGE_NAME  # Remove a specified image when it is not in use
```

Replace `IMAGE_NAME` with the actual image name, such as `hello-world`.

---

## Task 2: Docker Image Layers

### 1. View Image History

```bash
docker image history nginx  # Show the instructions and layers used to build the Nginx image
```

### 2. What Are Image Layers?

Docker images are built from layers. Each layer represents filesystem changes or build instructions.

- `RUN` can install packages or create files.
- `COPY` adds files to an image.
- `CMD` specifies the default command to run.
- `EXPOSE` documents the port the application is expected to use.
- `ENTRYPOINT` specifies the main executable.

### 3. Why Do Some Layers Show 0B?

Some instructions change image configuration rather than adding filesystem data. For example, `CMD`, `ENTRYPOINT`, and `EXPOSE` can show `0B`.

**My observation:** Image history helped me understand how Docker images are built from multiple layers.

---

## Task 3: Docker Container Lifecycle

### 1. Create a Container Without Starting It

```bash
docker create --name day30-test alpine sleep 600  # Create a container configured to run sleep for 600 seconds
```

The container is created but does not start immediately.

### 2. Start the Container

```bash
docker start day30-test  # Start the existing container
docker ps                # Show running containers
```

The configured main process, `sleep 600`, starts when the container starts.

### 3. Pause the Container

```bash
docker pause day30-test  # Freeze the container's processes temporarily
docker ps                # Check the container status
```

### 4. Unpause the Container

```bash
docker unpause day30-test  # Resume the paused container's processes
```

### 5. Stop the Container

```bash
docker stop day30-test  # Stop the container gracefully
docker ps -a            # Show running and stopped containers
```

### 6. Restart the Container

```bash
docker restart day30-test  # Stop and start the existing container
```

### 7. Kill the Container

```bash
docker kill day30-test  # Immediately send SIGKILL to the container's main process
docker ps -a            # Check the container status
```

### 8. Remove the Container

```bash
docker rm day30-test  # Remove the stopped container
docker ps -a          # Verify the container is no longer listed
```

**Important:** `docker rm` removes a container, not the image. A container must normally be stopped before it can be removed.

---

## Task 4: Run and Explore Nginx

### 1. Run Nginx in Detached Mode

```bash
docker run -d --name day30-nginx -p 8081:80 nginx  # Run Nginx in the background and map host port 8081 to container port 80
```

- `-d`: Runs the container in the background.
- `--name`: Assigns a name to the container.
- `-p 8081:80`: Maps host port `8081` to container port `80`.
- `nginx`: Specifies the image.

### 2. Check the Running Container

```bash
docker ps  # List running containers
```

**My observation:** Docker showed the port mapping `0.0.0.0:8081->80/tcp`.

### 3. View Container Logs

```bash
docker logs day30-nginx  # Display the container's logs
```

### 4. Follow Logs Live

```bash
docker logs -f day30-nginx  # Continue displaying new log entries as they appear
```

Press `Ctrl+C` to stop following logs. This does not normally stop the container.

### 5. Test Nginx Locally

```bash
curl http://localhost:8081  # Send an HTTP request to Nginx through the mapped host port
```

### 6. Open a Shell Inside the Container

```bash
docker exec -it day30-nginx bash  # Open an interactive Bash shell inside the running container
```

To leave the container shell:

```bash
exit  # Return to the EC2 host terminal
```

### 7. Run a Single Command Inside the Container

```bash
docker exec day30-nginx ls /usr/share/nginx/html  # List Nginx's default web page files
```

`docker exec` runs an additional command inside an already-running container. It does not create a new container.

### 8. Inspect the Container

```bash
docker inspect day30-nginx  # Display detailed container configuration and network information
```

To view only selected details:

```bash
docker inspect -f '{{.NetworkSettings.IPAddress}}' day30-nginx  # Display the container's IP address
docker inspect -f '{{json .NetworkSettings.Ports}}' day30-nginx  # Display its port configuration
docker inspect -f '{{json .Mounts}}' day30-nginx  # Display its mounted filesystems or volumes
```

The container IP is internal to Docker and may differ between containers or restarts.

---

## Task 5: Docker Cleanup

### 1. Stop Running Containers

```bash
docker ps  # Check which containers are running
docker stop $(docker ps -q)  # Stop all currently running containers, if any
```

### 2. Remove Stopped Containers

```bash
docker container prune  # Remove all stopped containers after confirmation
```

**My observation:** Docker removed the stopped containers and reported `143.4kB` of reclaimed space.

### 3. Remove Unused Images

```bash
docker image prune -a  # Remove all images not used by existing containers after confirmation
```

**My observation:** Docker removed unused images, including Nginx, Ubuntu, Alpine, Bash, and Hello World. It reported `119.4MB` of reclaimed space.

### 4. Check Remaining Images

```bash
docker images  # List images remaining on the machine
```

**My observation:** The image list was empty after cleanup.

### 5. Check Docker Disk Usage

```bash
docker system df  # Display disk space used by images, containers, volumes, and build cache
```

This command helps identify how much disk space Docker is using.

---

docker run -itd ubuntu bash   → creates a new container and runs it in the background
docker run -it ubuntu bash    → creates a new container and opens a shell inside it
docker exec -it <name> bash   → opens a shell inside an already running container


## Important Commands Revision

| Command | Purpose |
|---|---|
| `docker pull` | Download an image |
| `docker images` | List local images |
| `docker image inspect` | View image details |
| `docker image history` | View image layers and build instructions |
| `docker create` | Create a container without starting it |
| `docker start` | Start an existing container |
| `docker pause` | Pause container processes |
| `docker unpause` | Resume paused processes |
| `docker stop` | Stop a container gracefully |
| `docker restart` | Restart a container |
| `docker kill` | Force-stop a container |
| `docker rm` | Remove a container |
| `docker logs` | View container logs |
| `docker exec` | Run an additional command in a running container |
| `docker inspect` | View detailed container information |
| `docker container prune` | Remove stopped containers |
| `docker image prune -a` | Remove unused images |
| `docker system df` | Check Docker disk usage |

## What I Learned Today

- A Docker image is a template; a container is a running or stopped instance created from an image.
- Images contain layers that can be reused.
- A container's main process affects its lifecycle.
- Port mapping allows applications inside containers to be reached through host ports.
- `docker logs`, `docker exec`, and `docker inspect` help troubleshoot containers.
- Cleanup commands help reclaim disk space.

## GitHub Submission

```bash
git status  # Check which files have changed
git add 2026/day-30/day-30-images.md  # Stage the Day 30 notes
git commit -m "Add Day 30 Docker images and lifecycle notes"  # Save the changes in Git
git push origin master  # Push the commit to the remote master branch
```

**Day 30 complete:** Practiced Docker images, image layers, container lifecycle, Nginx, container inspection, and cleanup.
