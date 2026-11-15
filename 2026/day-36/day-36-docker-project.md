# Day 36 – Flask + MySQL with Docker Compose (Notes)

**Project code:** https://github.com/Jacksonklopes/Docker-projects/tree/main/day-36

## 1. What I built
A message board. You type a message in the browser, Flask saves it in MySQL, and the page shows all saved messages. Both parts run as Docker containers, started with one command.

```
Browser → Flask container (:5000) → MySQL container (:3306) → Volume (saved data)
         host port 5001
```

## 2. Project files

```
day-36/
├── app/
│   ├── app.py              # Flask code
│   ├── requirements.txt    # Flask, mysql-connector-python
│   ├── templates/index.html
│   └── static/style.css
├── Dockerfile              # how to build the Flask image
├── docker-compose.yml      # runs Flask + MySQL together
├── .env                    # DB name + password (never push to GitHub)
└── .dockerignore           # files Docker skips when building
```

## 3. Key ideas

| Idea | Meaning |
|---|---|
| Service name, not `localhost` | Each container has its own `localhost`. Flask connects to the host `mysql`, the service name in the compose file. Docker's internal DNS resolves it. |
| Environment variables | `app.py` reads `MYSQL_HOST`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_DB`. Compose fills them from `.env`. No password in the code. |
| One `.env` for both containers | Flask and MySQL read the same `MYSQL_PASSWORD`, so they always match. |
| Healthcheck + `depends_on: service_healthy` | Flask waits until MySQL is ready before it starts. |
| Named volume `mysql-data` | MySQL's files live outside the container, so the data survives container removal. |
| Ports `5001:5000` | `host:container`. Browser → EC2 port 5001 → Flask port 5000. |
| `host="0.0.0.0"` | The app must listen on all interfaces, or it can't be reached from outside the container. |
| Port 3306 not published | MySQL is reachable only inside the Docker network. |

## 4. Multi-stage Dockerfile

```dockerfile
FROM python:3.12-slim AS builder
WORKDIR /app
COPY app/requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim AS runner
WORKDIR /app
COPY --from=builder /install/ /usr/local
COPY app/ .
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser
EXPOSE 5000
CMD ["python", "app.py"]
```

- **Stage 1 (builder):** installs the packages into `/install`.
- **Stage 2 (runner):** copies them into `/usr/local`, where Python looks for packages, then adds the app. Only the last stage becomes the final image.
- `--prefix=/install` builds a mini `/usr/local` layout (`lib/` and `bin/`), so copying the whole folder puts everything in the right place.
- `COPY --from=builder` copies from another stage. A plain `COPY` copies from the host folder.
- `USER appuser` means the app does not run as root.

## 5. Run it

```bash
cd ~/day-36
docker compose config              # validate the YAML
docker compose up --build -d       # build and start
docker compose ps                  # both should be Up / healthy
curl http://localhost:5001/health  # {"status":"healthy"}
```

Browser: `http://<EC2-public-IP>:5001`

The EC2 security group must allow inbound TCP 5001 (ideally from your IP only). Never open 3306.

## 6. Check the saved data

```bash
docker exec -it mysql mysql -uroot -p
USE mydb;
SELECT * FROM messages;
```

`docker exec -it mysql mysql -uroot -p` means: run the `mysql` client program inside the container named `mysql`, as user `root`, and ask for the password.

## 7. Prove the data persists

```bash
docker compose down     # removes containers + network, keeps the volume
docker compose up -d    # start again
```

The messages are still there. **`docker compose down -v` deletes the volume and the data.**

MySQL reads the password only on the **first** start, when the volume is empty. Changing `.env` later does nothing until the volume is deleted.

## 8. Commands to remember

| Command | Purpose |
|---|---|
| `docker compose up --build -d` | Build and start in the background |
| `docker compose ps` | Container status |
| `docker compose logs <service>` | Logs (`flask-app` or `mysql`) |
| `docker compose down` | Stop and remove containers |
| `docker compose down -v` | Same, plus delete volumes |
| `docker exec -it <container> sh` | Shell inside a container |
| `docker images` / `docker volume ls` / `docker network ls` | List images, volumes, networks |

## 9. Debug checklist

1. `docker compose ps`: is anything Exited or unhealthy?
2. `docker compose logs <service>`: read the last lines of the error.
3. DB connection error: do the host name and passwords match?
4. Browser can't connect: is the port published, and open in the security group?
5. Changed code or `.env`: run `docker compose up --build -d` again.

## Takeaway

Flask runs the app, MySQL stores the data, Docker packages them, Compose runs them together, and the volume keeps the data safe.
