# Exercise 3: Building Workflows

**Objective:** Build more complex CI/CD workflows with matrix builds, caching, and multiple jobs.

**Duration:** 25 minutes

---

## Prerequisites

- ✅ Completed Exercise 2
- ✅ A working GitHub repository with CI workflow
- ✅ Understanding of basic workflow structure

---

## Overview

In this exercise, you'll:
- Test your code on multiple Node.js versions (matrix builds)
- Speed up builds with caching
- Create multiple jobs that run in sequence
- Pass data between jobs using artifacts

---

## Step 1: What is Matrix Builds?

Imagine you want to test your app on Node.js 18, 20, and 22. Instead of creating three separate workflows, you can use a **matrix**:

```yaml
strategy:
  matrix:
    node-version: [18, 20, 22]
```

This creates 3 jobs automatically - one for each version!

---

## Step 2: Update Your Workflow with Matrix

Open your `.github/workflows/ci.yml` and replace the content with:

```yaml
name: CI Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20, 22]

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test
```

---

## Step 3: Understanding Matrix

The `${{ matrix.node-version }}` syntax tells GitHub to use each value from the matrix:

```
┌─────────────────────────────────────────┐
│         Matrix Build Results            │
│                                         │
│  Job 1: node-version = 18              │
│  Job 2: node-version = 20              │
│  Job 3: node-version = 22              │
│                                         │
│  All run in parallel!                   │
└─────────────────────────────────────────┘
```

Push this change and watch 3 jobs run at once!

---

## Step 4: Add Build Caching

Caching saves time by reusing downloaded packages:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20, 22]

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'  # <-- This enables caching!

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test
```

The first run will download all packages. Subsequent runs will be **much faster**!

---

## Step 5: Add Multiple Jobs

Let's add a lint job that runs before tests:

```yaml
name: CI Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    needs: lint  # Wait for lint to finish!
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
```

The `needs: lint` ensures lint runs first!

---

## Step 6: Understanding Job Dependencies

```
Without "needs":
┌────────┐     ┌────────┐
│  lint  │     │  test  │   (run at same time)
└────────┘     └────────┘

With "needs: lint":
┌────────┐
│  lint  │────▶┌────────┐
└────────┘     │  test  │   (run after lint)
               └────────┘
```

---

## Step 7: Use Artifacts

**Artifacts** let you save files from one job and use them in another:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm test

      # Upload the built files
      - uses: actions/upload-artifact@v4
        with:
          name: my-app-files
          path: ./

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      # Download the files from build job
      - uses: actions/download-artifact@v4
        with:
          name: my-app-files
      - run: ls -la
```

---

## Complete Workflow

Here's the complete workflow combining everything:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

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
    needs: lint
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
```

---

## Verification Checklist

- [ ] Matrix builds run on 3 Node versions
- [ ] Jobs run in correct order (lint → test)
- [ ] Dependencies are cached (faster builds)
- [ ] Push triggers the workflow

---

## What You've Learned

✅ Matrix builds for multiple versions  
✅ Build caching for speed  
✅ Multiple jobs with dependencies  
✅ Artifacts to pass data  

---

## Next Steps

Move on to [Exercise 4: Advanced Patterns](../exercise-04-advanced/)
