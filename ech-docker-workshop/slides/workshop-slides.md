---
marp: true
theme: default
class: invert
paginate: true
backgroundColor: #0d1117
color: #e6edf3
style: |
  section {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    font-size: 28px;
    color: #e6edf3;
  }
  h1 {
    color: #58a6ff;
    font-size: 2em;
    border-bottom: 3px solid #58a6ff;
    padding-bottom: 10px;
  }
  h2 {
    color: #58a6ff;
    font-size: 1.4em;
  }
  code {
    font-size: 0.85em;
    background: #21262d;
    padding: 2px 6px;
    border-radius: 4px;
    color: #e6edf3;
  }
  pre {
    background: #161b22;
    padding: 15px;
    border-radius: 8px;
    border-left: 4px solid #238636;
  }
  table {
    font-size: 0.9em;
  }
  th {
    background: #21262d;
    color: #e6edf3;
  }
  td {
    color: #e6edf3;
  }
  .lead {
    color: #e6edf3;
  }
---

<!-- _class: lead -->

# Ignite : ECH docker workshop

**Instructor:** Kara Mohamed Mourtadha (0xKatana)  
**Duration:** 2 hours

---

## Agenda (Learn → Practice)

| # | Content | Exercise |
|---|---------|----------|
| 1 | Why Docker? | - |
| 2 | Container runtime & Linux kernel | - |
| 3 | Tools (Podman, crictl) | - |
| 4 | **Running containers** | **Exercise 1** |
| 5 | **Building images** | **Exercise 2** |
| 6 | **Docker Compose** | **Exercise 3** |
| 7 | **Container Registries** | **Exercise 4** |
| 8 | Kubernetes & cloud native | - |
| 9 | **Security** | **Exercise 5** |

---

## The Problem

**"It works on my machine"**

- Different OS versions
- Missing dependencies  
- Config drift
- "Works for me" debugging

---

## The Real Cost

```
Developer A (macOS)          Production (Linux)
     │                              │
     ▼                              ▼
┌──────────┐                  ┌──────────┐
│ Node 18  │                  │ Node 16  │
│ Python 3.9│                 │ Python 3.8│
│ libxml 2.9│                 │ libxml 2.7│
└──────────┘                  └──────────┘
      │                              │
      └──────────┬───────────────────┘
                 │
                 ▼
          CRASH IN PROD 💥
          
Time to debug: 4 hours
Money lost: $$$$
Sanity: Gone
```

---

## The Solution

**Package app + dependencies together**

```
┌─────────────────────────────┐
│  Your Application           │
│  ├─ Code                    │
│  ├─ Runtime (Node/Python)   │
│  ├─ Libraries               │
│  └─ System tools            │
└─────────────────────────────┘
           ↓
    One portable unit
```

---

## VM vs Container

```
Virtual Machine:                Container:
┌─────────┐                     ┌─────────┐
│  App    │                     │   App   │
│  Deps   │                     │  Deps   │
│  OS     │                     ├─────────┤
├─────────┤                     │ Docker  │
│ Hypervisor│                   ├─────────┤
├─────────┤                     │ Host OS │
│ Host OS │                     └─────────┘
└─────────┘                     

Startup: Minutes              Startup: Seconds
Size: GBs                     Size: MBs
```

---

## Container Runtime Architecture

**Docker is not just one thing:**

```
┌─────────────────────────────────────────┐
│         Docker CLI / API                │
│    (docker run, docker build)           │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      containerd (Container Runtime)     │
│    - Image management                   │
│    - Container execution                │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      runc (Low-level Runtime)           │
│    - Creates namespaces                 │
│    - Sets up cgroups                    │
│    - Runs the actual process            │
└─────────────────────────────────────────┘
```

**Open Container Initiative (OCI):** Standard interface between containerd and runc

---

## Linux Namespaces Deep Dive

**What the container sees vs reality:**

```
Inside Container:               On Host:
┌──────────────┐               ┌──────────────┐
│ PID 1: nginx │               │ PID 2345: nginx
│ (thinks it's │               │ (in container)
│  init system)│               │ PID 1: systemd
└──────────────┘               └──────────────┘
```

**Namespace Types:**
- **PID** - Process IDs isolated
- **NET** - Own network stack (interfaces, routes)
- **MNT** - Own filesystem mounts
- **UTS** - Own hostname
- **IPC** - Own shared memory
- **USER** - UID/GID mapping (root in container ≠ root on host)

---

## cgroups (Control Groups)

**Resource limiting in action:**

```bash
# Limit to 512MB RAM and 1 CPU core
docker run -m 512m --cpus="1.0" myapp

# What happens under the hood:
# /sys/fs/cgroup/memory/docker/<id>/memory.limit_in_bytes = 536870912
# /sys/fs/cgroup/cpu/docker/<id>/cpu.cfs_quota_us = 100000
```

**Without limits:** One container can starve others

```
┌─────────────────────────────────────┐
│  Host: 4GB RAM, 4 CPU cores         │
├─────────────────────────────────────┤
│  Container A: Uses 3.5GB (no limit) │
│  Container B: OOM Killed            │
└─────────────────────────────────────┘
```

---

## Overlay Filesystem

**How image layers work:**

```
Container View:         Actual Storage:
┌──────────────┐       ┌────────────────┐
│ /app/server  │ ←───  │ Layer 3 (RW)   │  ← Your changes
│ /app/config  │ ←───  └────────────────┘
│ /usr/bin/node│ ←───  ┌────────────────┐
└──────────────┘       │ Layer 2 (RO)   │  ← App code
                       ├────────────────┤
                       │ Layer 1 (RO)   │  ← Dependencies
                       ├────────────────┤
                       │ Layer 0 (RO)   │  ← Base image
                       └────────────────┘
```

**Benefits:**
- Share base layers between containers (saves disk)
- Instant container startup (no copy)
- Rollback to previous state

---

## Container Lifecycle

```
    docker run
        ↓
┌──────────────┐
│   CREATED    │
└──────┬───────┘
       │ docker start
       ↓
┌──────────────┐
│   RUNNING    │ ← docker stop → ┌─────────┐
└──────┬───────┘                 │ EXITED  │
       │ docker pause            └─────────┘
       ↓
┌──────────────┐
│   PAUSED     │
└──────────────┘
```

---

## Container Tools Ecosystem

**Docker is not the only player:**

| Tool | Purpose | When to Use |
|------|---------|-------------|
| **Podman** | Docker alternative | Rootless containers, no daemon |
| **Buildah** | Build images | CI/CD pipelines, scripted builds |
| **crictl** | Debug Kubernetes | Inspect containers in K8s |
| **nerdctl** | Docker-compatible CLI | containerd environments |
| **Skopeo** | Image operations | Copy/sign images without pull |

---

## Docker vs Podman

**Key differences:**

```
Docker:                      Podman:
┌──────────┐                ┌──────────┐
│ Docker   │                │ Podman   │
│ Daemon   │                │ (daemonless)
│ (root)   │                │          │
└────┬─────┘                └────┬─────┘
     │                          │
┌────▼─────┐                ┌────▼─────┐
│ containerd│                │ containers│
│           │                │ (libpod)  │
└────┬─────┘                └────┬─────┘
     │                          │
┌────▼─────┐                ┌────▼─────┐
│   runc   │                │   runc   │
└──────────┘                └──────────┘
```

**Podman advantage:** No daemon = no single point of failure

---

## Essential Docker Commands

**Containers:**
```bash
docker ps                    # List running
docker ps -a                 # List all
docker logs -f <name>        # Follow logs
docker exec -it <name> sh    # Shell inside
docker stop <name>           # Stop gracefully
docker rm <name>             # Remove container
```

**Images:**
```bash
docker images                # List images
docker rmi <image>           # Remove image
docker build -t name:tag .   # Build
docker pull/push <image>     # Registry ops
```

---

## System Management & Cleanup

**Volumes & Resources:**
```bash
docker volume ls             # List volumes
docker volume rm <name>      # Remove volume
docker system df             # Disk usage
docker system prune          # Clean unused data
```

**Power User Shortcuts:**
```bash
# Kill all containers
docker rm -f $(docker ps -aq)

# Remove all images
docker rmi -f $(docker images -q)

# Full cleanup (containers + images + volumes)
docker system prune -af --volumes
```

---

## Docker GUIs & TUIs

**GUI Tools:**
| Tool | Platform | Use Case |
|------|----------|----------|
| **Docker Desktop** | Mac/Win/Linux | Complete dev environment, GUI |
| **Portainer** | Web | Manage remote clusters |
| **Dozzle** | Web | Real-time log viewer |
| **OrbStack** | macOS | Fast alternative to Docker Desktop |

**TUI (Terminal UI) Tools:**
```bash
# lazydocker - Interactive terminal UI
docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock lazyteam/lazydocker

# Manual TUI with fzf
# docker ps | fzf | awk '{print $1}' | xargs docker logs -f
```

---

## Your First Container

```bash
# Run interactive shell
docker run -it ubuntu:22.04

# Run web server (detached)
docker run -d -p 8080:80 nginx

# Check what's running
docker ps

# Stop it
docker stop <container-id>
```

---

## Essential Flags

```bash
docker run \
  -d \                    # Detached (background)
  -it \                   # Interactive TTY
  --rm \                  # Auto-remove when done
  -p 3000:3000 \          # Port mapping
  -v mydata:/data \       # Named volume
  -e NODE_ENV=prod \      # Environment variable
  --name myapp \          # Container name
  myimage:tag
```

---

## Data Persistence

**Without volumes:** Data lost on restart ❌

**Named volume:**
```bash
docker volume create pgdata
docker run -v pgdata:/var/lib/postgresql/data postgres
```

**Bind mount (dev):**
```bash
docker run -v $(pwd):/app myapp
```

---

## Real Example: Database

```bash
docker run -d \
  --name postgres \
  -v pgdata:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=secret \
  -p 5432:5432 \
  postgres:15-alpine

# Connect
docker exec -it postgres psql -U postgres
```

---

<!-- _class: lead -->

# 🏃 Exercise 1

## Run Your First Container

**15 minutes**

See `exercise-01-first-container/README.md`

---

## Building Images

**Dockerfile:**
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
USER node
EXPOSE 3000
CMD ["node", "server.js"]
```

**Build:**
```bash
docker build -t myapp:1.0 .
```

---

## Build Cache

**Order matters:**
```dockerfile
# Dependencies change less often ↓
COPY package*.json ./
RUN npm ci

# App code changes frequently ↓  
COPY . .
```

Cache layers = faster rebuilds

---

## Multi-Stage Build

**Problem:** Build tools bloat production image

```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY . .
RUN npm ci && npm run build

# Production stage (smaller!)
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
RUN npm ci --only=production
USER node
CMD ["node", "dist/server.js"]
```

**Result:** 1GB → 100MB

---

## .dockerignore

```
node_modules
.git
.env
*.md
.vscode
coverage
dist
```

**Smaller context = faster builds**

---

<!-- _class: lead -->

# 🏃 Exercise 2

## Build a Docker Image

**20 minutes**

See `exercise-02-build-image/README.md`

---

## Docker Compose

**Problem:** Managing multiple containers manually

**Solution:** `docker-compose.yml`

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DB_URL=postgresql://db:5432/mydb
    depends_on:
      - db

  db:
    image: postgres:15-alpine
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=secret

volumes:
  pgdata:
```

---

## Compose Commands

```bash
docker compose up --build    # Build & start
docker compose up -d         # Background
docker compose logs -f       # Follow logs
docker compose down          # Stop & remove
docker compose down -v       # + delete volumes
```

---

## Networking

Compose creates a network automatically:

```yaml
services:
  app:
    environment:
      # Service name = hostname
      - DB_HOST=db
      - REDIS_HOST=redis
  
  db:
    image: postgres
  
  redis:
    image: redis
```

---

<!-- _class: lead -->

# 🏃 Exercise 3

## Docker Compose

**30 minutes**

See `exercise-03-compose/README.md`

---

## Container Registries

**Problem:** How do you share and distribute images?

**Solution:** Container Registry = Image storage & distribution

```
Your Machine              Registry              Production
     │                       │                      │
     │  docker build         │                      │
     ├──────────────────────>│                      │
     │                       │                      │
     │  docker push          │                      │
     ├──────────────────────>│                      │
     │                       │                      │
     │                       │  docker pull         │
     │                       ├─────────────────────>│
     │                       │                      │
     │                       │   Store & Distribute │
     └───────────────────────┴──────────────────────┘
```

---

## What is a Container Registry?

**Centralized storage for Docker images**

```
┌─────────────────────────────────────────┐
│           Container Registry            │
├─────────────────────────────────────────┤
│  Organization / User                    │
│  ├─ Repository: myapp                   │
│  │  ├─ Tag: v1.0                        │
│  │  ├─ Tag: v1.1                        │
│  │  └─ Tag: latest                      │
│  ├─ Repository: api                     │
│  └─ Repository: worker                  │
└─────────────────────────────────────────┘
```

---

## What is a Container Registry?

**Key Concepts:**
- **Repository** = Collection of related images (e.g., `myapp`)
- **Tag** = Version identifier (e.g., `v1.0`, `latest`)
- **Digest** = Immutable SHA256 hash

---

## Popular Container Registries

| Registry | Provider | Best For | Pricing |
|----------|----------|----------|---------|
| **Docker Hub** | Docker | Personal/Open Source | Free (public) |
| **GHCR** | GitHub | GitHub projects | Free |
| **Quay.io** | Red Hat | Enterprise | Free tier |
| **ECR** | AWS | AWS deployments | Pay per GB |
| **GCR/Artifact Registry** | Google | GCP deployments | Pay per GB |
| **ACR** | Azure | Azure deployments | Pay per GB |
| **Harbor** | CNCF | Self-hosted | Free (open source) |

---

## Docker Hub Deep Dive

**Default registry for Docker**

```bash
# Pull from Docker Hub (default)
docker pull nginx:latest

# Pull from specific registry
docker pull ghcr.io/username/myapp:v1.0
docker pull quay.io/podman/stable
```

---

## Docker Hub Deep Dive

**Image naming:**
```
# Docker Hub (official)
nginx:latest
redis:7-alpine

# Docker Hub (user/org)
username/myapp:v1.0
myorg/api:2.1.0

# Other registries
registry.example.com/myapp:v1.0
ghcr.io/username/myapp:v1.0
```

---

## Public vs Private Registries

**Public Repositories:**
- ✅ Free on Docker Hub
- ✅ Anyone can pull
- ✅ Great for open source
- ❌ Code is visible to everyone

---

## Public vs Private Registries

**Private Repositories:**
- ✅ Restricted access
- ✅ For proprietary code
- ❌ Limited free tier (Docker Hub: 1 private repo)
- ❌ Need authentication

---

## Public vs Private Registries

**Recommendation:**
- Open source projects → Public
- Company/internal apps → Private

---

## Image Tagging Strategies

**Don't just use `latest`!**

```bash
# ❌ Bad practice (unclear version)
docker push myapp:latest

# ✅ Good practice (semantic versioning)
docker push myapp:1.0.0
docker push myapp:1.0
docker push myapp:1

# ✅ Also tag with latest for convenience
docker tag myapp:1.0.0 myapp:latest
docker push myapp:latest
```

---

## Image Tagging Strategies

**Tag hierarchy:**
```
myapp:1.0.0  → Specific version (production)
myapp:1.0    → Minor version rollup
myapp:1      → Major version rollup
myapp:latest → Most recent (convenience)
```

---

## Pushing Images

**Workflow:**

```bash
# 1. Build your image
docker build -t myapp:1.0 .

# 2. Tag with your Docker Hub username
docker tag myapp:1.0 yourusername/myapp:1.0

# 3. Login (if not already)
docker login

# 4. Push
docker push yourusername/myapp:1.0

# 5. Push latest too
docker tag myapp:1.0 yourusername/myapp:latest
docker push yourusername/myapp:latest
```

---

## Pulling Images

**From any machine:**

```bash
# Login (required for private repos)
docker login

# Pull your image
docker pull yourusername/myapp:1.0

# Run it
docker run -d -p 3000:3000 yourusername/myapp:1.0

# Pull from other registries
docker pull ghcr.io/username/myapp:v1.0
docker pull quay.io/organization/app:latest
```
---

<!-- _class: lead -->

# 🏃 Exercise 4

## Container Registry & Docker Hub

**25 minutes**

See `exercise-04-container-registry/README.md`

---

## Container Orchestration

**Problem:** Managing containers at scale is hard

```
Single Container:           Multiple Containers:
┌──────────────┐            ┌─────────────────┐
│  docker run  │            │  Which failed?  │
│  docker ps   │            │  Where's logs?  │
│  docker logs │            │  How to scale?  │
└──────────────┘            └─────────────────┘
   ✅ Easy                      ❌ Complex
```

---

## Why Orchestration?

**Production needs:**

✅ **High Availability** - Auto-restart failed containers  
✅ **Scaling** - Handle traffic spikes automatically  
✅ **Rolling Updates** - Zero-downtime deployments  
✅ **Resource Optimization** - Pack containers efficiently  
✅ **Service Discovery** - Containers find each other  
✅ **Configuration Management** - Secrets, configs centralized  

---

## Orchestration Tools

| Tool | Provider | Best For |
|------|----------|----------|
| **Kubernetes (K8s)** | CNCF | Industry standard, any cloud |
| **Docker Swarm** | Docker | Simple, Docker-native |
| **Nomad** | HashiCorp | Simple, flexible workloads |
| **ECS** | AWS | AWS-native deployments |
| **AKS** | Azure | Azure-managed K8s |
| **GKE** | Google | Google-managed K8s |

---

## Security Checklist

**Images:**
- ✅ Use `alpine` or `distroless` bases
- ✅ Pin versions: `:1.0` not `:latest`
- ✅ Non-root user
- ✅ No secrets in images

**Runtime:**
- ✅ Read-only filesystem
- ✅ Resource limits

---

## Common Mistakes

```dockerfile
# ❌ Root user
FROM ubuntu
CMD ["app"]

# ✅ Non-root
FROM ubuntu
RUN useradd app
USER app
CMD ["app"]
```

```dockerfile
# ❌ Hardcoded secrets
ENV API_KEY=xyz123

# ✅ Runtime env
docker run -e API_KEY=$API_KEY app
```

---

<!-- _class: lead -->

# 🏃 Exercise 5

## Security Hardening

**20 minutes**

See `exercise-05-production/README.md`

---

## Image Scanning

```bash
# Check for CVEs
docker scout cves myapp:latest

# Or use Trivy
trivy image myapp:latest
```

---

## Key Takeaways

```
┌──────────────────────────────────────────┐
│  1. Containers = App + Dependencies      │
│  2. Linux kernel powers containers       │
│  3. Dockerfile = Build recipe            │
│  4. Compose = Multi-container            │
│  5. Registries = Share & distribute      │
│  6. Orchestration = Scale & manage       │
│  7. Security = Production ready          │
└──────────────────────────────────────────┘
```

---

## Resources

- **Docker Docs:** docs.docker.com
- **Practice:** labs.iximiuz.com
- **Book:** "Docker Deep Dive" - Nigel Poulton

---

<!-- _class: lead -->

# Questions?

**GitHub:** @0xkatana

---

<!-- _class: lead -->

# Go Build Something! 🚀
