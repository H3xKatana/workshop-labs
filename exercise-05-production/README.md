# Exercise 5: Production Hardening

**Objective:** Optimize and secure your Docker image for production.

**Duration:** 20 minutes

---

## Overview

In this exercise, you'll:
- Convert to multi-stage build
- Compare image sizes
- Scan for vulnerabilities
- Test with read-only filesystem
- Push to Docker Hub

---

## Step-by-Step Instructions

### Step 1: Create Multi-Stage Dockerfile

Create a new `Dockerfile` (this will be the multi-stage version):

```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
# No build step needed for this simple app

# Production stage
FROM node:18-alpine
WORKDIR /app

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Copy only necessary files from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/server.js ./

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S appuser -u 1001

USER appuser

EXPOSE 3000

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]
```

---

### Step 2: Compare Image Sizes

First, create a single-stage version for comparison (`Dockerfile.single`):

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN addgroup -g 1001 -S nodejs && \
    adduser -S appuser -u 1001
USER appuser
EXPOSE 3000
CMD ["node", "server.js"]
```

Now build both:

```bash
# Build single-stage version
docker build -f Dockerfile.single -t myapp:single-stage .

# Build multi-stage version
docker build -t myapp:multi-stage .

# Compare sizes
docker images | grep myapp
```

**Expected:** Multi-stage should be smaller or similar, but cleaner separation.

---

### Step 3: Scan for Vulnerabilities

**Using Docker Scout (built into Docker Desktop):**
```bash
docker scout cves myapp:multi-stage
```

**Using Trivy (if installed):**
```bash
# Install Trivy first if needed:
# https://aquasecurity.github.io/trivy/latest/getting-started/installation/

trivy image myapp:multi-stage
```

**Review the output:**
- Look for HIGH and CRITICAL vulnerabilities
- Note which packages have issues
- Consider using more secure base images (Distroless, Chainguard)

---

### Step 4: Test Security Improvements

Run with read-only filesystem:

```bash
# Start PostgreSQL first (from exercise 3)
docker compose up -d postgres

# Run app with security flags
docker run -d \
  --name myapp-secure \
  --read-only \
  --tmpfs /tmp \
  -p 3000:3000 \
  -e DATABASE_URL=postgresql://postgres:secret@host.docker.internal:5432/mydb \
  myapp:multi-stage

# Test it still works
curl http://localhost:3000/health

# View logs
docker logs myapp-secure
```

**Security flags explained:**
- `--read-only` - Make root filesystem read-only
- `--tmpfs /tmp` - Create writable tmpfs for temporary files

---

### Step 5: Push to Docker Hub

```bash
# Tag with your Docker Hub username
docker tag myapp:multi-stage YOURUSERNAME/myapp:v1.0

# Login to Docker Hub
docker login

# Push the image
docker push YOURUSERNAME/myapp:v1.0

# Verify on Docker Hub website:
# https://hub.docker.com/r/YOURUSERNAME/myapp/tags
```

---

## Verification Checklist

- [ ] Multi-stage Dockerfile builds successfully
- [ ] Image size compared between single and multi-stage
- [ ] Vulnerability scan completed
- [ ] App runs with read-only filesystem
- [ ] Image pushed to Docker Hub

---

## What You Learned

✅ Multi-stage builds for optimization
✅ Image scanning for vulnerabilities
✅ Read-only filesystems for security
✅ Pushing to container registries
✅ Production security best practices

---

## Troubleshooting

**Problem:** "dumb-init: not found"
**Solution:** Make sure you install dumb-init in the production stage:
```dockerfile
RUN apk add --no-cache dumb-init
```

**Problem:** "Cannot write to /app"
**Solution:** The app might be trying to write logs. Either:
1. Configure app to write to /tmp
2. Mount a volume for logs
3. Remove --read-only flag for now

**Problem:** "denied: requested access to the resource is denied"
**Solution:** You need to login first:
```bash
docker login
```

---

## Bonus: Even More Secure

Try using a Distroless image:

```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .

# Production stage with Distroless
FROM gcr.io/distroless/nodejs18-debian11
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/server.js ./
EXPOSE 3000
CMD ["server.js"]
```

**Note:** Distroless images don't have a shell, making them more secure but harder to debug.

---

## Congratulations!

You've completed all 5 exercises! You now know how to:
- Run containers
- Build custom images
- Orchestrate multi-container apps
- Push images to registries
- Secure and optimize for production

**Next steps:** Containerize one of your own applications!
