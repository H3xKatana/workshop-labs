# Docker Workshop Slides

> From Zero to Production

---

## Slide 1: Welcome & Introduction

### Docker Fundamentals Workshop

**Instructor:** Kara Mohamed Mourtadha (0xKatana)  
**Role:** DevOps/SRE Engineer  
**Workshop Duration:** ~4-6 hours  
**Prerequisites:** Basic command line knowledge, some programming experience

---

## Slide 2: Workshop Agenda

1. **History & Motivation** - Why containers matter
2. **Technology Overview** - How containers work under the hood
3. **Hands-on: Running Containers** - Using existing images
4. **Building Images** - Creating production-ready Dockerfiles
5. **Container Registries** - Sharing and distributing images
6. **Running Multi-Container Apps** - Docker Compose
7. **Development Workflow** - Live coding with containers
8. **Hands-On Exercises** - Put it all into practice

---

## Slide 3: What is a Container?

> "A lightweight, standalone, executable package of software that includes everything needed to run an application"

**Key Characteristics:**
- 📦 **Self-contained** - Everything needed is inside
- 🚀 **Fast** - Start in seconds, not minutes
- 🔄 **Portable** - Runs the same everywhere
- 🔒 **Isolated** - Doesn't interfere with other apps
- 📉 **Lightweight** - Shares host kernel

**Analogy:** Think of a container like a shipping container - standardized, portable, and contains everything needed for transport.

---

## Slide 4: Evolution of Virtualization

### The Journey: Bare Metal → VMs → Containers

| Era | Technology | Startup Time | Resource Usage | Isolation |
|-----|-----------|--------------|----------------|-----------|
| 1960s-2000s | Bare Metal | Minutes | Low | None |
| 2000s-2010s | Virtual Machines | Minutes | High | Strong |
| 2013+ | Containers | Seconds | Low | Good |

---

## Slide 5: Bare Metal vs VMs vs Containers

### Bare Metal (Direct Installation)
```
┌─────────────────────────────────┐
│ Application                     │
│ Dependencies                    │
│ Operating System                │
├─────────────────────────────────┤
│ Physical Hardware               │
└─────────────────────────────────┘
```
**Problems:**
- Dependency hell (library conflicts)
- Slow provisioning (hours to days)
- Low resource utilization
- Large blast radius

---

### Virtual Machines (Hypervisor)
```
┌─────────────┐ ┌─────────────┐
│  App A      │ │  App B      │
│  OS + Deps  │ │  OS + Deps  │
├─────────────┤ ├─────────────┤
│  Hypervisor              │
├──────────────────────────┤
│  Host OS                 │
├──────────────────────────┤
│  Physical Hardware       │
└──────────────────────────┘
```
**Benefits:** Better isolation, no dependency conflicts  
**Drawbacks:** Resource overhead, slower startup

---

### Containers (Shared Kernel)
```
┌─────────────┐ ┌─────────────┐
│  App A      │ │  App B      │
│  Bin/Libs   │ │  Bin/Libs   │
├─────────────┤ ├─────────────┤
│  Container Engine (Docker)   │
├──────────────────────────────┤
│  Host OS (Linux)             │
├──────────────────────────────┤
│  Physical Hardware           │
└──────────────────────────────┘
```
**Benefits:** Fast, lightweight, portable, efficient  
**Trade-off:** Less isolation than VMs

---

## Slide 6: Linux Building Blocks

Containers leverage three core Linux features:

### 1. Cgroups (Control Groups)
**Purpose:** Resource limiting and monitoring

```
┌─────────────────────────────────┐
│ Container A                     │
│  CPU: max 50%                   │
│  Memory: max 512MB              │
│  Disk I/O: throttle 100MB/s     │
└─────────────────────────────────┘
```

**Example:** Limit a container to 512MB RAM and 1 CPU core
```bash
docker run -m 512m --cpus="1.0" myapp
```

---

### 2. Namespaces
**Purpose:** Process isolation

**Types of Namespaces:**
- **PID** - Process ID isolation
- **NET** - Network isolation  
- **MNT** - Filesystem mount points
- **UTS** - Hostname/domain name
- **IPC** - Inter-process communication
- **USER** - User ID mapping

**Example:** Container thinks it has PID 1, but host sees PID 5421
```
Inside Container:  PID 1 = nginx
On Host:         PID 5421 = nginx (in container xyz)
```

---

### 3. Union Filesystem (OverlayFS)
**Purpose:** Layered, copy-on-write storage

```
┌─────────────────────────────────┐
│ Layer 3: Container Layer (RW)   │ ← Changes here
├─────────────────────────────────┤
│ Layer 2: Application Code       │
├─────────────────────────────────┤
│ Layer 1: Dependencies           │
├─────────────────────────────────┤
│ Layer 0: Base Image (Ubuntu)    │
└─────────────────────────────────┘
```

**Benefits:**
- Shared layers between containers
- Fast startup (no full copy)
- Efficient storage

---

## Slide 7: Docker Architecture

### Docker Desktop vs Docker Engine

**Docker Desktop (Mac/Windows):**
- Complete package with GUI
- Includes Linux VM
- Built-in Kubernetes
- Extensions support

**Docker Engine (Linux only):**
- Command-line only
- No VM needed
- Open source
- Production deployments

```
┌─────────────────────────────────────────┐
│ Docker Desktop                          │
│ ┌──────────────┐ ┌────────────────────┐ │
│ │ Docker CLI   │ │ Linux VM           │ │
│ │ GUI          │ │ ├─ Docker Daemon   │ │
│ │ Credentials  │ │ └─ Kubernetes      │ │
│ └──────────────┘ └────────────────────┘ │
└─────────────────────────────────────────┘
```

---

## Slide 8: Installation & Setup

### Installing Docker Desktop

**Mac (Apple Silicon/Intel):**
```bash
# Download from docker.com or use Homebrew
brew install --cask docker
```

**Windows:**
- Download from docker.com
- Requires WSL2 backend

**Linux:**
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```

**Verify Installation:**
```bash
docker --version
docker run hello-world
```

---

## Slide 9: Using 3rd Party Containers

### Your First Container

**Run a simple container:**
```bash
# Interactive Ubuntu shell
docker run -it --rm ubuntu:22.04

# Run a web server
docker run -d -p 8080:80 nginx:latest

# Run a database
docker run -d \
  --name my-postgres \
  -e POSTGRES_PASSWORD=secret \
  -p 5432:5432 \
  postgres:15-alpine
```

**Common Flags:**
- `-d` - Detached mode (background)
- `-it` - Interactive + TTY
- `--rm` - Remove after exit
- `-p` - Port mapping
- `-e` - Environment variables
- `--name` - Container name

---

## Slide 10: Data Persistence

### Understanding Container Storage

**Problem:** Data is lost when container restarts

```bash
# Create a file in a container
docker run -it --rm ubuntu:22.04 bash
echo "Hello" > /data.txt
exit

# Start new container - file is gone!
docker run -it --rm ubuntu:22.04 cat /data.txt
# Error: No such file
```

**Solutions:**

### 1. Named Volumes (Docker managed)
```bash
# Create and use a volume
docker volume create my-data
docker run -v my-data:/app/data ubuntu:22.04
```

### 2. Bind Mounts (Host filesystem)
```bash
# Mount host directory
docker run -v $(pwd)/data:/app/data ubuntu:22.04
```

---

## Slide 11: Practical Use Cases

### Running Databases

**PostgreSQL:**
```bash
docker run -d \
  --name postgres \
  -v pgdata:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=mysecret \
  -p 5432:5432 \
  postgres:15-alpine
```

**Redis:**
```bash
docker run -d \
  --name redis \
  -v redisdata:/data \
  -p 6379:6379 \
  redis:7-alpine
```

**MongoDB:**
```bash
docker run -d \
  --name mongo \
  -v mongodata:/data/db \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=secret \
  -p 27017:27017 \
  mongo:6
```

---

### CLI Tools Without Installation

**jq (JSON processor):**
```bash
echo '{"name":"John","age":30}' | \
  docker run -i stedolan/jq '.age'
# Output: 30
```

**AWS CLI:**
```bash
docker run --rm \
  -v ~/.aws:/root/.aws \
  amazon/aws-cli s3 ls
```

**Create an alias for convenience:**
```bash
alias aws='docker run --rm -v ~/.aws:/root/.aws amazon/aws-cli'
alias jq='docker run -i stedolan/jq'
```

---

## Slide 12: Building Container Images

### The Dockerfile

A recipe for building container images:

```dockerfile
# Start from a base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy dependency files first (for caching)
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Run as non-root user
USER node

# Start the application
CMD ["node", "server.js"]
```

**Build the image:**
```bash
docker build -t myapp:1.0 .
```

---

## Slide 13: Dockerfile Best Practices

### 🏆 The 10 Commandments of Dockerfiles

| # | Practice | Impact | Example |
|---|----------|--------|---------|
| 1 | **Pin base image versions** | 🔒 👁️ | `FROM node:18.17.1-alpine` |
| 2 | **Use small base images** | 🔒 🏎️ | `alpine` vs `ubuntu` |
| 3 | **Protect layer cache** | 🏎️ 👁️ | Order by change frequency |
| 4 | **Use .dockerignore** | 🔒 🏎️ 👁️ | Exclude node_modules, .git |
| 5 | **Run as non-root USER** | 🔒 | `USER node` |
| 6 | **Use multi-stage builds** | 🔒 🏎️ | Separate build/runtime |
| 7 | **Install only prod deps** | 🔒 🏎️ | `npm ci --only=production` |
| 8 | **Use COPY --link** | 🏎️ | Independent layers |
| 9 | **Be explicit with ENV** | 🔒 👁️ | Document configuration |
| 10 | **EXPOSE ports** | 👁️ | `EXPOSE 3000` |

---

## Slide 14: Multi-Stage Builds

### Separate Build and Runtime

**Problem:** Build tools bloat production images

**Solution:** Use multiple stages

```dockerfile
# Stage 1: Build
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:18-alpine AS production
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
RUN npm ci --only=production && npm cache clean --force
USER node
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

**Result:** Image size reduced from 1GB+ to ~100MB

---

## Slide 15: Container Registries

### Sharing Your Images

**What is a Registry?**
A service for storing and distributing container images.

**Popular Registries:**
- 🐳 **Docker Hub** - Default, largest library
- 🐙 **GitHub Container Registry (ghcr.io)**
- 🦊 **GitLab Container Registry**
- ☁️ **Cloud Registries:** GCR, ECR, ACR
- 🏢 **Private:** Harbor, Nexus, JFrog

**Push your image:**
```bash
# Tag with registry prefix
docker tag myapp:1.0 username/myapp:1.0

# Login
docker login

# Push
docker push username/myapp:1.0
```

---

## Slide 16: Running Multi-Container Apps

### Docker Compose

**Problem:** Managing multiple containers manually is tedious

**Solution:** Docker Compose - Define entire stack in YAML

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:secret@postgres:5432/mydb
    depends_on:
      - postgres

  postgres:
    image: postgres:15-alpine
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=secret

volumes:
  pgdata:
```

---

## Slide 17: Docker Compose Commands

### Essential Commands

```bash
# Build and start all services
docker compose up --build

# Start in background
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down

# Stop and remove volumes
docker compose down -v

# Execute command in service
docker compose exec postgres psql -U postgres
```

---

## Slide 18: Development Workflow

### Live Coding with Containers

**Goals:**
1. Easy setup (one command)
2. Fast iteration (no rebuilds)
3. Hot reloading

**docker-compose.dev.yml:**
```yaml
services:
  api:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
    ports:
      - "3000:3000"
```

---

## Slide 19: Quick Reference - Security Notes

### Essential Security Practices

**Image Security:**
- Use minimal base images (Alpine, Distroless)
- Scan with `docker scout cves` or Trivy
- Pin versions, don't use `latest`
- Never commit secrets to images
- Use non-root USER

**Runtime Security:**
```bash
# Drop capabilities
docker run --cap-drop=all --cap-add=NET_BIND_SERVICE myapp

# Read-only filesystem
docker run --read-only --tmpfs /tmp myapp

# Resource limits
docker run --memory=512m --cpus=1.0 myapp
```

---

## Slide 20: Quick Reference - Deployment Notes

### CI/CD & Deployment Overview

**CI/CD Integration:**
- Build images in GitHub Actions/GitLab CI
- Scan before pushing
- Tag with commit SHA or semantic version
- Push to registry

**Deployment Options:**
1. **PaaS** (Railway, Render) - Simple, managed
2. **Docker Swarm** - Built into Docker
3. **Kubernetes** - Industry standard

**Key Principle:** Build once, deploy anywhere using the same container image.

---

## Slide 21: Workshop Exercises Overview

### Hands-On Practice

| Exercise | Duration | Skills |
|----------|----------|--------|
| Exercise 1: First Container | 10 min | Running containers, ports |
| Exercise 2: Build Image | 20 min | Dockerfiles, building |
| Exercise 3: Multi-Container | 30 min | Compose, networking |
| Exercise 4: Production | 20 min | Optimization, security |

Navigate to each exercise directory and follow the README!

---

## Slide 22: Common Pitfalls

### What NOT to Do

❌ **Don't run as root in production**
```dockerfile
# BAD
FROM ubuntu
CMD ["myapp"]

# GOOD
FROM ubuntu
RUN useradd -m myuser
USER myuser
CMD ["myapp"]
```

❌ **Don't store secrets in images**
```dockerfile
# BAD
ENV API_KEY=sk-1234567890abcdef

# GOOD
docker run -e API_KEY=$API_KEY myapp
```

❌ **Don't use 'latest' tag**
```bash
# BAD
docker pull myapp:latest

# GOOD
docker pull myapp:1.2.3
```

❌ **Don't ignore .dockerignore**
```
node_modules
.git
.env
```

---

## Slide 23: Resources & Next Steps

### Learn More

📚 **Official:**
- [Docker Documentation](https://docs.docker.com)
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)

🛠️ **Practice:**
- [Iximiuz Labs](https://labs.iximiuz.com/challenges?category=containers)
- [Killer Coda](https://killercoda.com/)

📖 **Books:**
- "Docker Deep Dive" - Nigel Poulton
- "The Docker Book" - James Turnbull

---

## Slide 24: Q&A

### Questions?

**Key Takeaways:**
- 🎯 Containers provide lightweight, portable application packaging
- 🎯 Docker Compose simplifies multi-container applications
- 🎯 Multi-stage builds optimize for size and security
- 🎯 Security is defense in depth
- 🎯 Practice makes perfect!

**Next Steps:**
1. Complete all 4 exercises
2. Containerize your own applications
3. Explore Docker networking
4. Learn Kubernetes when ready

**Contact:**
- GitHub: @0xkatana

---

**Thank you!** 🐳

*"Containers won't solve all your problems, but they'll solve the 'it works on my machine' problem."*