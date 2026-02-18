# Docker Workshop Labs - Project Context

## Project Overview

**Docker Workshop: From Zero to Production** is a hands-on training course that teaches Docker fundamentals through production-ready practices. The workshop consists of 4 progressive exercises that take learners from running existing containers to building secure, production-hardened images.

**Instructor:** Kara Mohamed Mourtadha (0xKatana)  
**Duration:** 4-6 hours (80 minutes hands-on)  
**Repository:** https://github.com/H3xKatana/workshop-labs

---

## Project Structure

```
workshop-labs/
├── exercise-01-first-container/   # Running existing containers (Redis)
├── exercise-02-build-image/       # Building custom images (Node.js API)
├── exercise-03-compose/           # Multi-container orchestration
├── exercise-04-production/        # Production hardening & security
├── slides/                        # Marp presentation slides
├── README.md                      # Workshop overview
└── QWEN.md                        # This file
```

---

## Technologies & Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Runtime** | Node.js 18 (Alpine) | Example application |
| **Database** | PostgreSQL 15/16 | Persistent data storage |
| **Cache** | Redis 7 | In-memory data store |
| **Container** | Docker, Docker Compose | Containerization platform |
| **Framework** | Express.js | Simple REST API |
| **Presentation** | Marp | Slide deck generator |

---

## Exercise Breakdown

### Exercise 1: First Container (10 min)
**Objective:** Run existing containers and learn basic Docker commands.

**Key Commands:**
```bash
docker run -d --name my-redis -p 6379:6379 redis:7-alpine
docker ps
docker logs <container>
docker exec -it <container> redis-cli
docker stop/rm <container>
```

**Files:** `commands.sh`, `README.md`

---

### Exercise 2: Build Your Image (20 min)
**Objective:** Create a Dockerfile for a Node.js Express API.

**Key Concepts:**
- Writing Dockerfiles
- `.dockerignore` for efficient builds
- Non-root user for security
- Image tagging and versioning

**Files:** `Dockerfile`, `server.js`, `package.json`, `.dockerignore`

**Key Commands:**
```bash
docker build -t myapp:v1 .
docker run -d -p 3000:3000 --name myapp-container myapp:v1
curl http://localhost:3000/health
```

---

### Exercise 3: Multi-Container with Compose (30 min)
**Objective:** Orchestrate Node.js app + PostgreSQL using Docker Compose.

**Key Concepts:**
- `docker-compose.yml` structure
- Service dependencies (`depends_on`)
- Named volumes for persistence
- Environment variables
- Service scaling

**Files:** `docker-compose.yml`, `Dockerfile`, `server.js` (with pg driver)

**Key Commands:**
```bash
docker compose up --build
docker compose up -d
docker compose logs -f
docker compose down
docker compose down -v  # Remove volumes
```

---

### Exercise 4: Production Hardening (20 min)
**Objective:** Optimize and secure Docker images for production.

**Key Concepts:**
- Multi-stage builds (smaller images)
- Vulnerability scanning (`docker scout`, `trivy`)
- Read-only filesystems
- `dumb-init` for signal handling
- Pushing to Docker Hub

**Files:** `Dockerfile` (multi-stage), `Dockerfile.single`, `docker-compose.yml` (with `read_only`)

**Key Commands:**
```bash
docker build -f Dockerfile.single -t myapp:single-stage .
docker build -t myapp:multi-stage .
docker scout cves myapp:multi-stage
docker run --read-only --tmpfs /tmp myapp:multi-stage
docker tag/push <image>
```

---

## Building & Running

### Prerequisites
- Docker Desktop or Docker Engine installed
- Basic command line knowledge
- Text editor (VSCode recommended)

### Verify Installation
```bash
docker --version
docker run hello-world
```

### Quick Start
```bash
# Start with Exercise 1
cd exercise-01-first-container
cat README.md

# Or view the presentation
cd slides
cat workshop-slides.md
```

---

## Development Conventions

### Dockerfile Best Practices (Taught in Workshop)

1. **Use Alpine base images** - Smaller attack surface, faster pulls
2. **Pin versions** - `node:18-alpine` not `node:latest`
3. **Copy package files first** - Leverage Docker cache layers
4. **Use non-root users** - Security hardening
5. **Multi-stage builds** - Separate build and runtime environments
6. **Use `.dockerignore`** - Exclude unnecessary files from build context

### Example Dockerfile Pattern
```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .

# Production stage
FROM node:18-alpine
WORKDIR /app
RUN apk add --no-cache dumb-init
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/server.js ./
RUN addgroup -g 1001 -S nodejs && adduser -S appuser -u 1001
USER appuser
EXPOSE 3000
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]
```

### Security Checklist
- [ ] Non-root user
- [ ] Read-only filesystem (where possible)
- [ ] No secrets in images
- [ ] Vulnerability scanning
- [ ] Minimal base images

---

## Testing Practices

### Health Check Endpoint
All applications include a `/health` endpoint:
```bash
curl http://localhost:3000/health
# Expected: {"status":"healthy"}
```

### Manual Testing
```bash
# Test basic endpoint
curl http://localhost:3000

# Test health check
curl http://localhost:3000/health

# View container logs
docker logs <container-name>

# Execute commands inside container
docker exec -it <container-name> sh
```

---

## Common Troubleshooting

### Port Already in Use
```bash
# Change host port mapping
docker run -p 3001:3000 myapp  # Use 3001 instead of 3000
```

### Permission Denied (Linux)
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Then log out and back in
```

### Container Won't Start
```bash
# Check logs
docker logs <container-name>

# Inspect container
docker inspect <container-name>
```

### Cleanup Commands
```bash
# Stop and remove all containers
docker rm -f $(docker ps -aq)

# Remove all images
docker rmi -f $(docker images -q)

# Full cleanup (including volumes)
docker system prune -af --volumes
```

---

## Resources

### Official Documentation
- [Docker Documentation](https://docs.docker.com)
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)

### Practice Platforms
- [Iximiuz Labs](https://labs.iximiuz.com/challenges?category=containers)
- [Killer Coda](https://killercoda.com/)
- [Play with Docker](https://labs.play-with-docker.com/)

### Recommended Reading
- "Docker Deep Dive" - Nigel Poulton
- "The Docker Book" - James Turnbull
- [DevOps Directive Docker Course](https://youtu.be/RqTEHSBrYFw)

---

## Key Takeaways

By completing this workshop, learners will be able to:
- 🐳 Run and manage Docker containers
- 🐳 Write efficient, secure Dockerfiles
- 🐳 Orchestrate multi-container applications with Compose
- 🐳 Apply production security best practices
- 🐳 Push images to container registries
