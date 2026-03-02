# Exercise 1: Your First Container

**Objective:** Get comfortable running existing containers and basic Docker commands.

**Duration:** 10 minutes

---

## Overview

In this exercise, you'll:
- Run a Redis container in the background
- Connect to it from another container
- Store and retrieve data
- Practice cleanup commands

---

## Step-by-Step Instructions

### Step 1: Start Redis Container

Open your terminal and run:

```bash
# Start Redis in detached mode (background)
docker run -d --name my-redis -p 6379:6379 redis:7-alpine
```

**Flags explained:**
- `-d` - Run in detached mode (background)
- `--name my-redis` - Give the container a name
- `-p 6379:6379` - Map host port 6379 to container port 6379
- `redis:7-alpine` - Use Redis version 7 with Alpine Linux base

### Step 2: Verify It's Running

```bash
# List running containers
docker ps

# You should see something like:
# CONTAINER ID   IMAGE             COMMAND                  CREATED         STATUS         PORTS                    NAMES
# abc123def456   redis:7-alpine    "docker-entrypoint.s…"   5 seconds ago   Up 4 seconds   0.0.0.0:6379->6379/tcp   my-redis

# Check the logs
docker logs my-redis
```

### Step 3: Connect and Test

Open another terminal window and run:

```bash
# Start redis-cli in a new container, connecting to our Redis server
docker run -it --rm redis:7-alpine redis-cli -h host.docker.internal
```

**Note:** On Linux, you might need to use the container's IP address instead of `host.docker.internal`.

Now you'll be at the Redis prompt. Try these commands:

```bash
# Store a key-value pair
127.0.0.1:6379> SET workshop "Docker is awesome!"
OK

# Retrieve the value
127.0.0.1:6379> GET workshop
"Docker is awesome!"

# Store more data
127.0.0.1:6379> SET instructor "Kara"
OK
127.0.0.1:6379> GET instructor
"Kara"

# List all keys
127.0.0.1:6379> KEYS *
1) "workshop"
2) "instructor"

# Delete a key
127.0.0.1:6379> DEL instructor
(integer) 1

# Exit redis-cli
127.0.0.1:6379> exit
```

### Step 4: Cleanup

```bash
# Stop the Redis container
docker stop my-redis

# Remove the container
docker rm my-redis

# Verify it's gone
docker ps -a
```

**Alternative one-liner:**
```bash
# Stop and remove in one command
docker rm -f my-redis
```

---

## Quick Reference Commands

```bash
# Run container with auto-cleanup
docker run -d --rm --name temp-redis redis:7-alpine

# Run with interactive shell
docker run -it redis:7-alpine sh

# Execute command in running container
docker exec -it my-redis redis-cli

# View container stats
docker stats my-redis
```

---

## What You Learned

✅ Running containers with `docker run`  
✅ Port mapping with `-p`  
✅ Naming containers with `--name`  
✅ Connecting containers to each other  
✅ Viewing logs with `docker logs`  
✅ Stopping and removing containers  

---

## Troubleshooting

**Problem:** Port already in use
```
Error response from daemon: Ports are not available: exposing port TCP 0.0.0.0:6379...
```
**Solution:** Either stop the other service using port 6379, or use a different port:
```bash
docker run -d --name my-redis -p 6380:6379 redis:7-alpine
```

**Problem:** Permission denied (Linux)
```
Got permission denied while trying to connect to the Docker daemon
```
**Solution:** Add your user to the docker group:
```bash
sudo usermod -aG docker $USER
# Then log out and back in
```

---

## Next Steps

Move on to [Exercise 2: Build Your First Image](../exercise-02-build-image/)