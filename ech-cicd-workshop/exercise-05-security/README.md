# Exercise 5: Security Hardening

**Objective:** Secure your CI/CD pipeline with security scanning and secret detection.

**Duration:** 25 minutes

---

## Prerequisites

- ✅ Completed Exercise 4
- ✅ Understanding of GitHub Actions workflows

---

## Overview

In this exercise, you'll:
- Scan for vulnerabilities in your code (Trivy)
- Detect secrets accidentally committed (Gitleaks)
- Build and push a Docker container
- Add security checks to your pipeline
- Understand basic security best practices

---

## Step 1: Add Docker to Your App

First, create a Dockerfile in your project:

```dockerfile
# Use Node.js alpine for small size
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy source code
COPY . .

# Expose port
EXPOSE 3000

# Run the app
CMD ["node", "server.js"]
```

Also create `.dockerignore`:

```
node_modules
.git
*.test.js
README.md
.env
```

---

## Step 2: Build Docker Locally

```bash
# Build the image
docker build -t myapp:latest .

# Run it
docker run -p 3000:3000 myapp:latest

# Test it
curl http://localhost:3000
```

---

## Step 3: Add Docker to Your Workflow

Update your workflow to build and scan the Docker image:

```yaml
name: Secure CI/CD with Docker

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read
  pull-requests: write

env:
  NODE_VERSION: '20'
  IMAGE_NAME: myapp

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
      - run: npm install
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20, 22]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm install
      - run: npm test
      - name: npm audit
        run: npm audit --audit-level=high
        continue-on-error: true

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Trivy scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'

      - name: Run Gitleaks
        uses: gitleaks/gitleaks-action@v2

  build-docker:
    needs: [lint, test, security]
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Build Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: false
          tags: ${{ env.IMAGE_NAME }}:latest

      - name: Scan Docker image with Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: '${{ env.IMAGE_NAME }}:latest'
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Upload Trivy results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'trivy-results.sarif'
```

---

## Step 4: Why Build Docker in CI/CD?

```
┌─────────────────────────────────────────────────────────────┐
│              Docker in CI/CD Pipeline                         │
│                                                             │
│  1. Build → Test → Scan → Build Image → Push              │
│                                                             │
│  2. Benefits:                                               │
│     ✅ Consistent builds                                    │
│     ✅ Scan for vulnerabilities in final image             │
│     ✅ Ready to deploy                                     │
│     ✅ Version control for images                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Step 5: Why Security in CI/CD?

```
┌─────────────────────────────────────────────────────────────┐
│                    Security in CI/CD                        │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Before:                                            │   │
│  │  1. Developer commits secret to Git                │   │
│  │  2. Secret is now in history forever!              │   │
│  │  3. Attacker finds it                              │   │
│  │  4. 💰 Account compromised!                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  With Security Pipeline:                                    │
│  1. Developer commits secret                               │
│  2. Gitleaks catches it immediately                        │
│  3. Build fails                                            │   │
│  4. Secret never reaches production!                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Step 2: What is Trivy?

**Trivy** scans for:
- 🐛 Vulnerable dependencies
- 🔒 Security misconfigurations
- 📦 Outdated packages

Think of it like a virus scanner for your code!

---

## Step 3: What is Gitleaks?

**Gitleaks** detects:
- 🔑 API keys
- 🔐 Passwords
- 💳 Credentials
- 📝 Sensitive data

It scans your git history and current code for accidentally committed secrets!

---

## Step 4: Add Security to Your Workflow

Update your workflow file to include security scanning:

```yaml
name: Secure CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read
  pull-requests: write

env:
  NODE_VERSION: '20'

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      - run: npm ci
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20, 22]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      - run: npm ci
      - run: npm test

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Trivy scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Upload Trivy results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'trivy-results.sarif'

      - name: Run Gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ github.token }}
```

---

## Step 5: Understanding the Security Job

```
┌─────────────────────────────────────────────────────────────┐
│                 Security Job Flow                           │
│                                                             │
│  1. Checkout code                                          │
│              ↓                                              │
│  2. Trivy scans dependencies                               │
│     • Checks for CVEs                                      │
│     • Checks for insecure packages                         │
│              ↓                                              │
│  3. Upload results to Security tab                         │
│              ↓                                              │
│  4. Gitleaks scans for secrets                            │
│     • API keys                                             │
│     • Passwords                                            │
│     • Tokens                                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Step 6: Test Security Scanning

Let's test locally first:

```bash
# Install trivy (optional - for local testing)
brew install trivy   # macOS
# or
apt-get install trivy  # Linux

# Scan your code
trivy fs .

# Check for secrets
gitleaks detect --source .
```

---

## Step 7: Add npm audit (Simple Alternative)

If you don't want to use Trivy, npm has built-in security scanning:

```yaml
- name: Security audit
  run: npm audit --audit-level=high
  continue-on-error: true
```

This is simpler but less comprehensive than Trivy.

---

## Complete Secure Workflow

```yaml
name: Secure CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read
  pull-requests: write

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

env:
  NODE_VERSION: '20'

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      - run: npm ci
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20, 22]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      - run: npm ci
      - run: npm test
      - name: npm audit
        run: npm audit --audit-level=high
        continue-on-error: true

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Trivy
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
      - name: Run Gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ github.token }}
```

---

## Security Best Practices

| ✅ Do | ❌ Don't |
|-------|----------|
| Use secrets in CI/CD | Commit secrets to git |
| Scan dependencies | Ignore security warnings |
| Use Gitleaks | Hardcode API keys |
| Keep dependencies updated | Use old vulnerable packages |
| Limit permissions | Give unnecessary access |

---

## Viewing Security Results

After running the workflow:

1. Go to your repository on GitHub
2. Click **Security** tab
3. See vulnerabilities found by Trivy
4. See alerts for leaked secrets

---

## Verification Checklist

- [ ] Trivy scans for vulnerabilities
- [ ] Gitleaks detects secrets
- [ ] Security job runs after other jobs
- [ ] Results visible in Security tab

---

## What You've Learned

✅ Using Trivy for vulnerability scanning  
✅ Using Gitleaks for secret detection  
✅ Adding security to CI/CD pipeline  
✅ Viewing security results in GitHub  

---

## Summary

You've completed all 5 exercises!

| Exercise | Topic |
|----------|-------|
| 1 | CI/CD Fundamentals |
| 2 | GitHub Actions Basics |
| 3 | Building Workflows |
| 4 | Advanced Patterns |
| 5 | Security Hardening |

**Congratulations!** You now know how to build secure CI/CD pipelines! 🎉
