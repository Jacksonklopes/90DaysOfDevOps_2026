# Day 33 – Docker Compose

## What is Docker Compose?

A tool that runs **many containers from one YAML file** with one command, instead of typing a long `docker run` for each container.

```text
docker-compose.yml  →  docker compose up -d  →  all containers, network and volumes created
```

Check it is installed:

```bash
docker compose version
```

---

## 1. Nginx with Compose

`docker-compose.yml`:

```yaml
services:
  nginx-service:
    image: nginx:alpine
    ports:
      - "8081:80"
    volumes:
      - ./website:/usr/share/nginx/html
    environment:
      - APP_ENV=${APP_ENV}
```

| Line | Meaning | Same as in `docker run` |
| ---- | ------- | ----------------------- |
| `services:` | List of containers to run | - |
| `nginx-service:` | Service name | `--name` |
| `image:` | Image to use | image name |
| `"8081:80"` | Host port 8081 → container port 80 | `-p 8081:80` |
| `./website:/usr/share/nginx/html` | Host folder → folder Nginx serves (bind mount) | `-v` |
| `APP_ENV=${APP_ENV}` | Pass a variable (value comes from `.env`) | `-e` |

Run and test:

```bash
docker compose config     # validate the file and show the final values
docker compose up -d      # start in the background
docker compose ps         # check status
curl http://localhost:8081
```

---

## 2. Compose Commands

| Command | What it does |
| ------- | ------------ |
| `docker compose up -d` | Create and start the services in the background |
| `docker compose ps` | Show the services and their status |
| `docker compose logs` | Show logs (`-f` to follow, `--tail=20` for the last 20 lines) |
| `docker compose stop` | Stop the containers, but keep them |
| `docker compose start` | Start the stopped containers again |
| `docker compose restart` | Restart the containers |
| `docker compose up -d --force-recreate` | Replace the containers with new ones |
| `docker compose down` | Remove the containers and the network (**volumes are kept**) |
| `docker compose down -v` | Same, and **also deletes the volumes** (data is lost) |
| `docker compose exec <service> <cmd>` | Run a command inside a running service |

**Using another file name:** Compose reads `docker-compose.yml` by default. For a different file, add `-f`:

```bash
docker compose -f docker-compose.wordpress.yml up -d
```

> Recreating a container is not the same as rebuilding an image. Nginx here uses a ready-made image, so nothing is rebuilt.

---

## 3. Environment Variables with `.env`

A `.env` file keeps values (like passwords) **out of the YAML**. Compose reads it automatically and fills in `${VARIABLE}`.

`.env`:

```dotenv
APP_ENV=learning
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=<your-password>
MYSQL_ROOT_PASSWORD=<your-root-password>
```

Check the value inside a container:

```bash
docker compose exec nginx-service printenv APP_ENV
```

Protect the file:

```bash
chmod 600 .env            # only the owner can read it
git check-ignore .env     # prints .env if Git ignores it
```

**Remember:**
- `.env` is **not encrypted**. It only keeps secrets out of the YAML.
- Add `.env` to `.gitignore` so it is never pushed to GitHub.
- `docker compose config` prints the real passwords, so don't share its output.

---

## 4. WordPress + MySQL

`docker-compose.wordpress.yml`:

```yaml
services:
  wordpress:
    image: wordpress:latest
    ports:
      - "8082:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_NAME: ${MYSQL_DATABASE}
      WORDPRESS_DB_USER: ${MYSQL_USER}
      WORDPRESS_DB_PASSWORD: ${MYSQL_PASSWORD}
    depends_on:
      - db

  db:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
```

| Part | Meaning |
| ---- | ------- |
| `wordpress` | The website (the app) |
| `db` | The MySQL database |
| `WORDPRESS_DB_HOST: db:3306` | WordPress finds MySQL by the **service name** `db`, on MySQL's default port 3306 |
| `depends_on: - db` | Start `db` first. It controls **start order only**, not whether MySQL is ready. |
| `db_data:/var/lib/mysql` | Named volume that stores the database files |
| `volumes: db_data:` | Declares the volume (like `docker volume create`) |

The database values in `wordpress` and `db` must **match**, which is why both read from the same `.env` variables.

Run it:

```bash
docker compose -f docker-compose.wordpress.yml up -d
docker compose -f docker-compose.wordpress.yml ps
docker volume ls
```

Open `http://<EC2-public-IP>:8082` in the browser. The EC2 security group must allow port 8082. Finish the WordPress setup page and log in.

---

## 5. Look Inside the Database

```bash
docker exec -it compose-basics-db-1 mysql -u root -p
```

```sql
SHOW DATABASES;
USE wordpress;                 -- select the database first
SHOW TABLES;
SELECT ID, user_login, user_email, display_name FROM wp_users;
EXIT;
```

`compose-basics-db-1` is the container name Compose made: `<project folder>-<service>-<number>`.

---

## 6. Networking

Compose creates a **network for the project automatically** and puts all services on it. On that network, services reach each other by **service name** (`db`), so there is no need for IP addresses. MySQL's port 3306 does not need to be published to the host, because WordPress reaches it inside the network.

---

## 7. Data Persistence Test

```bash
docker compose -f docker-compose.wordpress.yml down     # remove containers and network
docker compose -f docker-compose.wordpress.yml up -d    # create them again
```

Result: the WordPress account I created was **still there**, because the data is in the named volume `compose-basics_db_data`, not in the container.

> Never use `down -v` unless you want to delete the data.

---

## Key Points

1. Compose defines many containers in one YAML file and runs them with one command.
2. `ports`, `volumes`, and `environment` in the YAML are the same as `-p`, `-v`, and `-e` in `docker run`.
3. Services talk to each other by **service name** on the network Compose creates.
4. A **named volume** keeps database data when containers are removed.
5. `down` keeps volumes. `down -v` deletes them.
6. `.env` keeps passwords out of the YAML. Never push it to Git.
7. `depends_on` only controls start order, not readiness.
8. Use `-f <file>` when the file is not named `docker-compose.yml`.
