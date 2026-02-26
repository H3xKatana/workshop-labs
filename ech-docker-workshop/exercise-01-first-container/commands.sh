#!/bin/bash
# Exercise 1: Your First Container
# This script contains all the commands for Exercise 1

echo "=== Exercise 1: Your First Container ==="
echo ""

# Step 1: Start Redis
echo "Starting Redis container..."
docker run -d --name my-redis -p 6379:6379 redis:7-alpine

# Step 2: Verify it's running
echo ""
echo "Checking if container is running..."
docker ps

# Step 3: Show connection command
echo ""
echo "=== To connect to Redis, run in another terminal: ==="
echo "docker run -it --rm redis:7-alpine redis-cli -h host.docker.internal"
echo ""
echo "Then try these commands in redis-cli:"
echo "  SET workshop \"Docker is awesome!\""
echo "  GET workshop"
echo "  KEYS *"
echo "  exit"
echo ""

# Step 4: Cleanup commands (commented out)
echo "=== Cleanup commands (run after you're done): ==="
echo "docker stop my-redis"
echo "docker rm my-redis"
echo ""
echo "Or use: docker rm -f my-redis"