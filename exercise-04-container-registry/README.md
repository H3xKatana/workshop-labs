# Exercise 4: Container Registry & Docker Hub

**Objective:** Learn to push and pull images from container registries, focusing on Docker Hub.

**Duration:** 25 minutes

---

## Overview

In this exercise, you'll:
- Create a Docker Hub account
- Generate an access token for CLI authentication
- Tag your image from Exercise 2
- Push your image to Docker Hub
- Pull and run your image
- Understand public vs private repositories

---

## Prerequisites

You should have completed [Exercise 2](../exercise-02-build-image/) and have a built image.

Verify your image exists:
```bash
docker images | grep myapp
# Expected: myapp    v1.0    <image-id>    <size>
```

---

## Step-by-Step Instructions

### Step 1: Create Docker Hub Account

**Mentors will guide you through this step!**

1. Go to **https://hub.docker.com**
2. Click **"Sign Up"**
3. Enter:
   - Username
   - Email address
   - Password
4. Verify your email address
5. ✅ Account created!

**Note:** Remember your username - you'll need it for tagging images!

---

### Step 2: Create Access Token

**Why use an access token?**
- More secure than your password
- Can be revoked without changing your password
- Required for CI/CD pipelines

**Steps:**
1. Click your profile icon → **"Account Settings"**
2. Go to the **"Security"** tab
3. Click **"New Access Token"**
4. Fill in:
   - **Name:** `Workshop CLI`
   - **Expiration:** 90 days (or your preference)
   - **Permissions:** Read & Write
5. Click **"Generate"**
6. **⚠️ COPY THE TOKEN NOW** - You won't see it again!

---

### Step 3: Login to Docker Hub

Open your terminal and login:

```bash
docker login
```

When prompted:
- **Username:** Your Docker Hub username
- **Password:** Paste your access token (not your account password!)

**Expected output:**
```
Login Succeeded
```

**Verify:**
```bash
# Your credentials are stored
cat ~/.docker/config.json
```

---

### Step 4: Tag Your Image

**Current image name:** `myapp:v1.0`

**Problem:** Docker Hub requires the format `username/repository:tag`

**Solution:** Tag (don't rebuild!) your existing image:

```bash
# Replace YOURUSERNAME with your actual Docker Hub username
docker tag myapp:v1.0 YOURUSERNAME/myapp:v1.0

# Also tag as latest for convenience
docker tag myapp:v1.0 YOURUSERNAME/myapp:latest
```

**Verify:**
```bash
docker images | grep myapp
# You should see both tags pointing to the same image ID
```

**Example:**
```bash
# If your username is "johnsmith"
docker tag myapp:v1.0 johnsmith/myapp:v1.0
docker tag myapp:v1.0 johnsmith/myapp:latest
```

---

### Step 5: Push to Docker Hub

**Push the versioned tag:**
```bash
docker push YOURUSERNAME/myapp:v1.0
```

**Expected output:**
```
The push refers to repository [docker.io/YOURUSERNAME/myapp]
abc123def456: Pushed
xyz789ghi012: Pushed
v1.0: digest: sha256:... size: 1234
```

**Push the latest tag:**
```bash
docker push YOURUSERNAME/myapp:latest
```

**Verify on Docker Hub:**
1. Go to https://hub.docker.com/repositories
2. You should see `myapp` repository
3. Click to see the tags: `v1.0` and `latest`

---

### Step 6: Pull Your Image

**Simulate pulling on a different machine:**

```bash
# Remove the local image (to simulate a fresh machine)
docker rmi YOURUSERNAME/myapp:v1.0
docker rmi YOURUSERNAME/myapp:latest

# If you get an error about dependent containers, add -f flag:
# docker rmi -f YOURUSERNAME/myapp:v1.0

# Now pull it back from Docker Hub
docker pull YOURUSERNAME/myapp:v1.0
```

**Verify:**
```bash
docker images | grep myapp
```

---

### Step 7: Run Your Container

```bash
# Run your pulled image
docker run -d -p 3000:3000 --name my-hub-app YOURUSERNAME/myapp:v1.0

# Test it works
curl http://localhost:3000

# Expected: {"message":"Hello from Docker!",...}

# View logs
docker logs my-hub-app
```

---

## Step 8: Private Repository (Optional)

**Create a private repository:**

1. Go to https://hub.docker.com
2. Click **"Create Repository"**
3. Choose **"Private"**
4. Name it: `my-private-app`
5. Click **"Create"**

**Push to private repo:**
```bash
# Tag for private repo
docker tag myapp:v1.0 YOURUSERNAME/my-private-app:v1.0

# Push
docker push YOURUSERNAME/my-private-app:v1.0
```

**Pull from private repo:**
```bash
# Login is required for private repos
docker login

# Pull
docker pull YOURUSERNAME/my-private-app:v1.0
```

---

## Verification Checklist

- [ ] Docker Hub account created
- [ ] Access token generated and saved
- [ ] Logged in via CLI (`docker login`)
- [ ] Image tagged with username
- [ ] Image pushed to Docker Hub
- [ ] Image pulled from Docker Hub
- [ ] Container runs successfully from pulled image
- [ ] Verified repository on Docker Hub website

---

## What You Learned

✅ Container registry concepts  
✅ Docker Hub account setup  
✅ Access token authentication  
✅ Image tagging conventions  
✅ Pushing images to registries  
✅ Pulling images from registries  
✅ Public vs private repositories  

---

## Image Tagging Best Practices

**Do:**
```bash
# Use semantic versioning
docker push myapp:1.0.0
docker push myapp:1.0
docker push myapp:1

# Also tag latest for convenience
docker tag myapp:1.0.0 myapp:latest
docker push myapp:latest
```

**Don't:**
```bash
# Only using latest (unclear what version)
docker push myapp:latest

# Using ambiguous tags
docker push myapp:test
docker push myapp:final-final-v2
```

---

## Troubleshooting

**Problem:** "denied: requested access to the resource is denied"
**Solution:** You need to login first:
```bash
docker login
```

**Problem:** "tag does not match digest"
**Solution:** The remote tag already exists with different content. Use a unique version tag:
```bash
docker tag myapp:v1.0 YOURUSERNAME/myapp:v1.1
docker push YOURUSERNAME/myapp:v1.1
```

**Problem:** "repository not found"
**Solution:** Create the repository on Docker Hub first, or use your username as the namespace:
```bash
# Your username automatically creates a repository
docker push YOURUSERNAME/myapp:v1.0
```

**Problem:** "unauthorized: authentication required"
**Solution:** For private repos, ensure you're logged in:
```bash
docker login
# If still failing, logout and login again
docker logout
docker login
```

**Problem:** Access token lost/not saved
**Solution:** Generate a new one:
1. Account Settings → Security
2. Revoke the old token
3. Create a new access token

---

## Bonus Challenges

### 1. Pull on Another Machine
If you have access to another computer or VM:
```bash
# On the other machine
docker login
docker pull YOURUSERNAME/myapp:v1.0
docker run -p 3000:3000 YOURUSERNAME/myapp:v1.0
curl http://localhost:3000
```

### 2. Try GitHub Container Registry (GHCR)
```bash
# Login to GHCR (uses GitHub token)
echo $GHCR_TOKEN | docker login ghcr.io -u YOURUSERNAME --password-stdin

# Tag and push
docker tag myapp:v1.0 ghcr.io/YOURUSERNAME/myapp:v1.0
docker push ghcr.io/YOURUSERNAME/myapp:v1.0
```

### 3. Multi-Architecture Build
```bash
# Build for both AMD64 and ARM64
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t YOURUSERNAME/myapp:v1.0 \
  --push \
  .
```

---

## Next Steps

Move on to [Exercise 5: Production Hardening](../exercise-05-production/)

---

## Resources

- [Docker Hub Documentation](https://docs.docker.com/docker-hub/)
- [Docker Login Reference](https://docs.docker.com/engine/reference/commandline/login/)
- [Image Tagging Best Practices](https://docs.docker.com/engine/reference/commandline/tag/)
- [GHCR Documentation](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
