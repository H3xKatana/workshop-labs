# Exercise 2: Build Your First Image

**Objective:** Create and build a simple containerized Node.js application.

**Duration:** 20 minutes

---

## Overview

In this exercise, you'll:
- Create a simple Express.js API
- Write a Dockerfile
- Build and run your image
- Learn about .dockerignore
- Add security improvements (non-root user)

---

## Step-by-Step Instructions

### Step 1: Create Project Files

Create these files in this directory:

**package.json:**
```json
{
  "name": "my-docker-app",
  "version": "1.0.0",
  "description": "My first Docker app",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

**server.js:**
```javascript
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Docker!',
    timestamp: new Date().toISOString(),
    hostname: require('os').hostname()
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
```

---

### Step 2: Create Basic Dockerfile

Create a file named `Dockerfile`:

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000

CMD ["node", "server.js"]
```

---

### Step 3: Build and Test

```bash
# Build the image
docker build -t myapp:v1 .

# Run it
docker run -d -p 3000:3000 --name myapp-container myapp:v1

# Test it
curl http://localhost:3000
# Expected: {"message":"Hello from Docker!",...}

curl http://localhost:3000/health
# Expected: {"status":"healthy"}

# View logs
docker logs myapp-container
```

---

### Step 4: Add .dockerignore

Create a `.dockerignore` file:

```
node_modules
.git
.env
npm-debug.log
.DS_Store
```

**Why this matters:** Prevents unnecessary files from being copied into the image, making builds faster and images smaller.

---

### Step 5: Add Security - Non-Root User

Update your Dockerfile:

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S appuser -u 1001

USER appuser

EXPOSE 3000

CMD ["node", "server.js"]
```

**Rebuild and test:**
```bash
# Stop and remove old container
docker rm -f myapp-container

# Rebuild
docker build -t myapp:v2 .

# Run
docker run -d -p 3000:3000 --name myapp-container myapp:v2

# Verify it still works
curl http://localhost:3000
```

---

## Verification Checklist

- [ ] Container builds without errors
- [ ] App responds on http://localhost:3000
- [ ] Health endpoint works
- [ ] .dockerignore excludes node_modules
- [ ] App runs as non-root user

---

## What You Learned

✅ Writing Dockerfiles  
✅ Building images with `docker build`  
✅ Tagging images  
✅ Using .dockerignore  
✅ Running as non-root for security  

---

## Troubleshooting

**Problem:** "Cannot find module 'express'"
**Solution:** Make sure you ran `npm install` locally first, or the COPY commands are correct in Dockerfile.

**Problem:** Permission denied
**Solution:** On Linux, you may need to adjust user permissions or run without USER directive first to debug.

---

## Next Steps

Move on to [Exercise 3: Multi-Container App](../exercise-03-compose/)