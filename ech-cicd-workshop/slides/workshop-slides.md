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
    font-size: 26px;
    color: #e6edf3;
  }
  h1 {
    color: #58a6ff;
    font-size: 2.2em;
    border-bottom: 3px solid #58a6ff;
    padding-bottom: 10px;
  }
  h2 {
    color: #7ee787;
    font-size: 1.5em;
  }
  h3 {
    color: #d2a8ff;
    font-size: 1.2em;
  }
  code {
    font-size: 0.8em;
    background: #21262d;
    padding: 2px 6px;
    border-radius: 4px;
    color: #79c0ff;
  }
  pre {
    background: #161b22;
    padding: 15px;
    border-radius: 8px;
    border-left: 4px solid #238636;
  }
  table {
    font-size: 0.85em;
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
    font-size: 1.3em;
  }
  .highlight {
    color: #ffa657;
  }
  .danger {
    color: #f85149;
  }
  .success {
    color: #7ee787;
  }
---

<!-- _class: lead -->

![bg](https://images.unsplash.com/photo-1556075798-4825dfaaf498?w=1920&q=80)

# 🚀 Ignite : ECH CI/CD Workshop

**Instructor:** Kara Mohamed Mourtadha (0xKatana)  
**Duration:** 2 hours

---

<!-- _class: lead -->

## 🎯 What You'll Learn Today

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   1️⃣  CI/CD Fundamentals & Concepts                    │
│   2️⃣  GitHub Actions Basics                            │
│   3️⃣  Building Workflows (Matrix, Cache, Artifacts)   │
│   4️⃣  Advanced Patterns (Secrets, Environments)        │
│   5️⃣  Security Hardening                               │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 📋 Agenda

| # | Content | Exercise |
|---|---------|----------|
| 1 | Why CI/CD? | - |
| 2 | CI/CD Concepts & Triggers | - |
| 3 | GitHub Actions Basics | 🏃 Ex 1 |
| 4 | Workflow Building Blocks | 🏃 Ex 2 |
| 5 | Advanced Patterns | 🏃 Ex 3 |
| 6 | Security Hardening | 🏃 Ex 4 |
| 7 | Wrap-up & Q&A | - |

---

<!-- _class: lead -->

## 😰 The Problem

# "It works on my machine!"

---

## The Real Cost

```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│  Developer (Mac)              Production (Linux)           │
│       │                             │                      │
│       ▼                             ▼                      │
│  ┌──────────┐                 ┌──────────┐                 │
│  │ Node 20  │                 │ Node 18  │                 │
│  │ Python 3.11│                │ Python 3.8│                │
│  │ npm 9.x │                 │ npm 6.x  │                 │
│  └──────────┘                 └──────────┘                 │
│       │                             │                      │
│       └────────────┬────────────────┘                      │
│                    ▼                                       │
│            💥 PRODUCTION CRASH 💥                          │
│                                                            │
│  Time wasted: 4-8 hours                                    │
│  Revenue lost: $$$$                                       │
│  Weekend: Gone                                            │
└────────────────────────────────────────────────────────────┘
```

---

## What is CI/CD?

```
┌─────────────────────────────────────────────────────────┐
│                     CI/CD Pipeline                       │
│                                                          │
│   CODE    BUILD     TEST     DEPLOY     MONITOR         │
│    📝   🔨        🧪        🚀         📊              │
│    │      │         │         │          │              │
│    └──────┴─────────┴─────────┴──────────┘              │
│                    ▼                                    │
│            ✅ Reliable Software                          │
└─────────────────────────────────────────────────────────┘
```

**CI = Continuous Integration**  
**CD = Continuous Delivery**  
**CD = Continuous Deployment**

---

## CI vs CD vs CD

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Continuous Integration                                     │
│  ┌─────┐    ┌─────┐    ┌─────┐                            │
│  │Merge│───▶│Build│───▶│Test │                            │
│  └─────┘    └─────┘    └─────┘                            │
│                                                             │
│  Continuous Delivery                                       │
│  ┌─────┐    ┌─────┐    ┌─────┐    ┌──────┐              │
│  │Merge│───▶│Build│───▶│Test │───▶│Staged │              │
│  └─────┘    └─────┘    └─────┘    └──────┘   👆 Manual  │
│                                                             │
│  Continuous Deployment                                    │
│  ┌─────┐    ┌─────┐    ┌─────┐    ┌──────┐              │
│  │Merge│───▶│Build│───▶│Test │───▶│Production│           │
│  └─────┘    └─────┘    └─────┘    └──────┘  👆 Auto   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Traditional vs CI/CD

```
TRADITIONAL:                     CI/CD:

Write Code                    Write Code
    │                            │
    ▼                            ▼
┌─────────┐                  ┌─────────┐
│  Test  │                  │  Push   │────────┐
│ Manually│                  │ to Git  │        │
└────┬────┘                  └────┬────┘        │
     │                            │              │
     ▼                            ▼              ▼
┌─────────┐                  ┌─────────┐    ┌─────────┐
│  Deploy │                  │  Auto   │    │  Auto   │
│  (weeks)│                  │ Pipeline│    │ Deploy  │
└─────────┘                  └─────────┘    └─────────┘

 4-8 hours                     5-15 min
 to find bugs
```

---

## Benefits of CI/CD

| 📊 Metric | ❌ Without CI/CD | ✅ With CI/CD |
|-----------|------------------|---------------|
| **Feedback Time** | Days/Hours | Minutes |
| **Bug Detection** | Production | Development |
| **Release Frequency** | Monthly/Quarterly | Daily |
| **Deployment Risk** | High | Low |
| **Developer Happiness** | 😞 | 😄 |

---

## 🔄 Pipeline Stages

```
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│  COMMIT │──▶│  BUILD  │──▶│  TEST   │──▶│ STAGING │──▶│ PROD    │
│          │   │          │   │          │   │          │   │          │
│  Code    │   │  Compile │   │  Unit    │   │ Deploy   │   │ Deploy   │
│  Push    │   │  Package │   │  Integ   │   │ Verify   │   │ Monitor  │
└──────────┘   └──────────┘   └──────────┘   └──────────┘   └──────────┘
                     │              │              │              │
                     ▼              ▼              ▼              ▼
                 Success!       89% pass     ✅ Green       🚀 Live!
```

---

<!-- _class: lead -->

# 🏃 Exercise 1

## CI/CD Fundamentals

**15 minutes**

See `exercise-01-intro-cicd/README.md`

---

## What is GitHub Actions?

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Actions                            │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Your Repository                          │   │
│  │  ┌─────────────────────────────────────────────┐    │   │
│  │  │  .github/workflows/*.yml                   │    │   │
│  │  │                                              │    │   │
│  │  │  name: CI Pipeline                          │    │   │
│  │  │  on: [push, pull_request]                  │    │   │
│  │  │  jobs:                                     │    │   │
│  │  │    build:                                  │    │   │
│  │  │      runs-on: ubuntu-latest               │    │   │
│  │  │      steps:                                │    │   │
│  │  │        - uses: actions/checkout@v4        │    │   │
│  │  │        - run: npm ci                       │    │   │
│  │  └─────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────┘   │
│                            │                                │
│                            ▼                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              GitHub Runners                          │   │
│  │                                                       │   │
│  │   🟢 ubuntu-latest    🟠 macOS    🟦 Windows       │   │
│  │                                                       │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Workflow** | Automated process defined in YAML |
| **Job** | Collection of steps on same runner |
| **Step** | Individual task (command or action) |
| **Action** | Reusable unit of work |
| **Runner** | Virtual machine that executes jobs |
| **Event** | Trigger that starts workflow |

---

## Workflow Structure

```yaml
name: CI Pipeline          # 📛 Workflow name

on:                       # 🔥 Triggers
  push:
    branches: [main]

jobs:                     # 📦 Jobs
  build:                  # Job ID
    runs-on: ubuntu-latest

    steps:                # 📝 Steps
      - uses: actions/checkout@v4

      - run: npm ci

      - run: npm test
```

---

## 🔥 Workflow Triggers

```yaml
on:
  # Code pushed to branch
  push:
    branches: [main, develop]

  # Pull request opened/updated
  pull_request:
    branches: [main]
    types: [opened, synchronize]

  # Scheduled job (cron)
  schedule:
    - cron: '0 0 * * *'

  # Manual trigger
  workflow_dispatch:
```

---

## ⏰ Cron Syntax

```
┌───────────────────── minute (0-59)
│ ┌─────────────────── hour (0-23)
│ │ ┌───────────────── day of month (1-31)
│ │ │ ┌─────────────── month (1-12)
│ │ │ │ ┌───────────── day of week (0-6)
│ │ │ │ │
* * * * *

Common Examples:
  '0 0 * * *'        → Every day at midnight
  '0 9 * * 1'       → Monday at 9am
  '*/15 * * * *'    → Every 15 minutes
  '0 0 1 * *'       → First of month
```

---

## 📅 Scheduled Job Examples

| Schedule | Use Case |
|----------|----------|
| `0 0 * * *` | Daily security scans |
| `0 9 * * 1` | Weekly reports |
| `*/15 * * * *` | Health checks |
| `0 0 1 * *` | Monthly backups |
| `0 */6 * * *` | Cache refresh every 6h |

---

## 👷 Marketplace Actions

```
┌─────────────────────────────────────────────────────────────┐
│                  GitHub Marketplace                         │
│                                                             │
│  🔧 Build & Test           🚀 Deployment                    │
│  ─────────────────        ──────────────────                │
│  • actions/checkout       • aws-actions/configure-aws       │
│  • actions/setup-node     • azure/login                    │
│  • actions/setup-python   • google-github-actions          │
│  • docker/build-push      • vercel/action                  │
│                                                             │
│  🛡️ Security              📊 Monitoring                    │
│  ───────────────         ──────────────────                │
│  • snyk/actions           • aws-lambda-actions             │
│  • github/codeql-action   • datadog/actions                │
│  • trufflesecurity/truffle│                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Basic Workflow Example

```yaml
name: Node.js CI

on:
  push:
main]
  pull_request:
    branches    branches: [: [main]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test
```

---

<!-- _class: lead -->

# 🏃 Exercise 2

## GitHub Actions Basics

**20 minutes**

See `exercise-02-github-actions/README.md`

---

## 🔀 Matrix Builds

```
┌─────────────────────────────────────────────────────────────┐
│                    Matrix Strategy                           │
│                                                             │
│  matrix:                                                   │
│    node-version: [18, 20, 22]                              │
│    os: [ubuntu-latest, windows-latest]                     │
│                                                             │
│  Results in 6 jobs:                                        │
│  ┌────────────────┐ ┌────────────────┐ ┌────────────────┐ │
│  │ Node 18 + Ub   │ │ Node 20 + Ub   │ │ Node 22 + Ub   │ │
│  └────────────────┘ └────────────────┘ └────────────────┘ │
│  ┌────────────────┐ ┌────────────────┐ ┌────────────────┐ │
│  │ Node 18 + Win  │ │ Node 20 + Win  │ │ Node 22 + Win  │ │
│  └────────────────┘ └────────────────┘ └────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Matrix Builds Example

```yaml
jobs:
  test:
    strategy:
      matrix:
        node-version: [18, 20, 22]
        # Run on multiple OS
        include:
          - node-version: 21
            os: windows-latest
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm test
```

---

## 💾 Build Caching

```
Without Cache:                 With Cache:

  npm install                   npm install
       │                            │
       ▼                            ▼
  ┌─────────┐                  ┌─────────┐
  │ Download│                  │  Cache  │
  │ 500+    │                  │   HIT   │
  │ packages │                  └─────────┘
  └─────────┘                       │
       │                            ▼
       ▼                       ┌─────────┐
  ⏱️ 45 seconds                │ Skip    │
                               │ Download│
                               └─────────┘
                                    │
                                    ▼
                               ⏱️ 8 seconds
```

---

## Caching in Actions

```yaml
# Automatic caching (recommended)
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'

# Manual caching
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-npm-
```

---

## 📦 Artifacts

```
┌─────────────────────────────────────────────────────────────┐
│                    Artifacts Flow                           │
│                                                             │
│   JOB: build              JOB: deploy                      │
│  ┌──────────────┐        ┌──────────────┐                 │
│  │              │        │              │                 │
│  │  npm run    │        │              │                 │
│  │  build      │        │  npm run     │                 │
│  │     │       │        │  deploy      │                 │
│  │     ▼       │        │     ▲        │                 │
│  │  dist/      │───────▶│  dist/       │                 │
│  │             │upload  │              │                 │
│  └──────────────┘        └──────────────┘                 │
│                              │                              │
│                              ▼                              │
│                          🚀 Deploy!                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Artifacts Example

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: npm run build

      - uses: actions/upload-artifact@v4
        with:
          name: my-app
          path: dist/

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: my-app
      - run: npm run deploy
```

---

## 🔗 Job Dependencies

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - run: npm run lint

  test:
    needs: lint
    runs-on: ubuntu-latest
    steps:
      - run: npm test

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - run: npm run build
```

---

## Complete Workflow

```yaml
name: CI/CD Pipeline

on: [push, pull_request]

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

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm run build
      - uses: actions/upload-artifact@v4
        with:
          name: build
          path: dist/
```

---

<!-- _class: lead -->

# 🏃 Exercise 3

## Building Workflows

**25 minutes**

See `exercise-03-workflows/README.md`

---

## 🔐 Secrets

```
┌─────────────────────────────────────────────────────────────┐
│                      GitHub Secrets                         │
│                                                             │
│  1. Repository Settings                                    │
│     └── Secrets and variables                               │
│         └── Actions                                         │
│                                                             │
│  2. Add Secret:                                            │
│     ┌──────────────────┐                                    │
│     │ NPM_TOKEN        │ ← Name                            │
│     │ **************   │ ← Value (hidden)                  │
│     └──────────────────┘                                    │
│                                                             │
│  3. Use in workflow:                                       │
│     env:                                                    │
│       NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Secrets Example

```yaml
jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          registry-url: 'https://registry.npmjs.org'

      - run: npm ci

      - run: npm publish
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

---

## 🌍 Environments

```
┌─────────────────────────────────────────────────────────────┐
│                   Protected Environments                    │
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐   │
│  │   staging   │───▶│  production │    │  development│   │
│  └─────────────┘    └─────────────┘    └─────────────┘   │
│        │                  │                  │             │
│        ▼                  ▼                  ▼             │
│   Auto-deploy         Requires          Anyone           │
│   after tests         approval                          │
│                        👤👤                                │
│                                                             │
│  Environment Rules:                                         │
│  ✓ Required reviewers (1-6 people)                        │
│  ✓ Wait timer (0 to 30 days)                             │
│  ✓ Deployment branches (allow/deny)                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Environments Example

```yaml
jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment:
      name: staging
      url: https://staging.myapp.com
    steps:
      - run: echo "Deploying to staging"

  deploy-prod:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://myapp.com
    steps:
      - run: echo "Deploying to production"
```

---

## 🤔 Conditionals

```yaml
steps:
  # Only on PRs
  - name: Comment on PR
    if: github.event_name == 'pull_request'
    run: gh pr comment ${{ github.event.pull_request.number }} -m "Build started!"

  # Skip on specific paths
  - name: Build
    if: "!contains(github.event.head_commit.message, '[skip ci]')"
    run: npm run build

  # Matrix-specific
  - name: Build Windows
    if: matrix.os == 'windows-latest'
    run: npm run build:windows
```

---

## ⚡ Concurrency

```yaml
# Cancel in-progress runs for same branch
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

**Before:** 5 runs queued for same PR  
**After:** Only latest run executes

---

## 🔄 Reusable Workflows

```
┌─────────────────────────────────────────────────────────────┐
│                 Reusable Workflow Pattern                   │
│                                                             │
│  .github/workflows/test.yml (template)                     │
│  ┌───────────────────────────────────────────┐             │
│  │ on: workflow_call                          │             │
│  │   inputs:                                  │             │
│  │     node-version:                          │             │
│  │       type: string                         │             │
│  │       default: '20'                        │             │
│  └───────────────────────────────────────────┘             │
│                       │                                      │
│                       ▼                                      │
│  .github/workflows/ci.yml (usage)                          │
│  ┌───────────────────────────────────────────┐             │
│  │ jobs:                                     │             │
│  │   test-node-18:                           │             │
│  │     uses: ./.github/workflows/test.yml    │             │
│  │     with:                                  │             │
│  │       node-version: '18'                   │             │
│  └───────────────────────────────────────────┘             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

<!-- _class: lead -->

# 🏃 Exercise 4

## Advanced Patterns

**30 minutes**

See `exercise-04-advanced/README.md`

---

## 🛡️ Security Hardening

```
┌─────────────────────────────────────────────────────────────┐
│                 CI/CD Security Best Practices               │
│                                                             │
│  1️⃣  Pin Actions to SHA                                    │
│      ❌ uses: actions/checkout@v4                          │
│      ✅ uses: actions/checkout@b4ffde65...                 │
│                                                             │
│  2️⃣  Minimal Permissions                                    │
│      permissions:                                           │
│        contents: read                                       │
│        pull-requests: write                                 │
│                                                             │
│  3️⃣  Don't Expose Secrets                                   │
│      ❌ echo $SECRET                                       │
│      ✅ env: { SECRET: ${{ secrets.SECRET }} }            │
│                                                             │
│  4️⃣  Scan Dependencies                                      │
│      • npm audit                                            │
│      • Snyk                                                 │
│      • Dependabot                                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Dependency Scanning

```yaml
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: npm audit
        run: npm audit --audit-level=high

      - name: Snyk
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

---

## Secret Scanning

```yaml
jobs:
  secret-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: TruffleHog
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: ${{ github.event.repository.default_branch }}
```

---

## CodeQL Analysis

```yaml
jobs:
  codeql:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      contents: read
    steps:
      - uses: actions/checkout@v4

      - uses: github/codeql-action/init@v3
        with:
          languages: javascript

      - uses: github/codeql-action/analyze@v3
```

---

## Minimal Permissions

```yaml
permissions:
  contents: read       # Read repository
  pull-requests: write # Update PRs
  # No: contents: write
  # No: secrets: read
  # No: id-token: write
```

---

## Complete Secure Workflow

```yaml
name: Secure CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

# Cancel duplicate runs
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

# Minimal permissions
permissions:
  contents: read
  pull-requests: write

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11

      - uses: actions/setup-node@b4ffde65f46336ab88eb53be808477a3936bae11
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20, 22]
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11

      - uses: actions/setup-node@b4ffde65f46336ab88eb53be808477a3936bae11
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'

      - run: npm ci
      - run: npm test

      - name: Security audit
        run: npm audit --audit-level=high
        continue-on-error: true
```

---

<!-- _class: lead -->

# 🏃 Exercise 5

## Security Hardening

**25 minutes**

See `exercise-05-security/README.md`

---

## 🚀 Deployment Strategies

```
┌─────────────────────────────────────────────────────────────┐
│                    Blue-Green Deployment                     │
│                                                             │
│   Before:                    After:                         │
│                                                             │
│   ┌─────────┐              ┌─────────┐                     │
│   │  Blue   │              │  Green  │                     │
│   │  v1.0   │─────────────▶│  v1.1   │                     │
│   │  100%   │   Switch     │  100%   │                     │
│   └─────────┘   Traffic     └─────────┘                     │
│                                                             │
│   ✅ Instant rollback                                    │
│   ✅ Zero downtime                                       │
│   ❌ 2x resources                                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    Canary Deployment                        │
│                                                             │
│   v1.0: ████████████░░░░░  (80%)                            │
│   v1.1: █████░░░░░░░░░░░░  (20%)                            │
│                                                             │
│   Gradually increase traffic                                │
│   ✅ Low risk                                              │
│   ✅ Real user feedback                                    │
│   ✅ Easy rollback                                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 GitOps

```
┌─────────────────────────────────────────────────────────────┐
│                        GitOps Flow                          │
│                                                             │
│    ┌──────────────┐                                        │
│    │   Developer  │                                        │
│    └──────┬───────┘                                        │
│           │ Push code                                       │
│           ▼                                                 │
│    ┌──────────────┐      ┌──────────────┐                  │
│    │  Git Repo    │ ───▶ │   CI/CD      │                  │
│    │ (Source of   │      │   Pipeline   │                  │
│    │  Truth)      │      └──────┬───────┘                  │
│    └──────────────┘             │                          │
│                                  ▼                          │
│                           ┌──────────────┐                  │
│                           │   Cluster    │                  │
│                           │   (K8s)      │                  │
│                           │   ArgoCD    │                  │
│                           └──────────────┘                  │
│                                                             │
│    ✅ Single source of truth                               │
│    ✅ Git history for auditing                             │
│    ✅ Easy rollback                                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📈 Monitoring Metrics

```
┌─────────────────────────────────────────────────────────────┐
│                 DORA Metrics (DevOps)                       │
│                                                             │
│  🚀 Deployment Frequency                                    │
│     How often do you deploy?                                │
│     • Elite: On-demand (multiple/day)                       │
│     • Low: Monthly to yearly                                │
│                                                             │
│  ⏱️ Lead Time for Changes                                   │
│     Commit to production                                     │
│     • Elite: Hours                                          │
│     • Low: Months                                           │
│                                                             │
│  🔧 Change Failure Rate                                     │
│     % of deployments causing failures                       │
│     • Elite: 0-15%                                          │
│     • High: 46-60%                                          │
│                                                             │
│  🛠️ Mean Time to Recovery (MTTR)                           │
│     Time to restore service                                 │
│     • Elite: < 1 hour                                       │
│     • Low: 1-6 months                                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔗 Useful Resources

```
┌─────────────────────────────────────────────────────────────┐
│                      Resources                              │
│                                                             │
│  📖 Documentation                                           │
│     • docs.github.com/en/actions                           │
│     • docs.github.com/en/actions/security-guides           │
│                                                             │
│  🧪 Learning                                                │
│     • github.com/skills                                     │
│     • lab.github.com                                        │
│                                                             │
│  🛒 Actions                                                  │
│     • github.com/marketplace                                │
│                                                             │
│  📝 Examples                                                │
│     • github.com/actions/starter-workflows                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎉 Key Takeaways

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   1️⃣  CI/CD = Faster, reliable software delivery           │
│                                                             │
│   2️⃣  GitHub Actions = Native CI/CD for GitHub            │
│                                                             │
│   3️⃣  Workflows = YAML-defined automation                  │
│                                                             │
│   4️⃣  Matrix = Test on multiple versions/platforms        │
│                                                             │
│   5️⃣  Caching = Speed up your builds                       │
│                                                             │
│   6️⃣  Security = Scan, pin actions, minimal permissions    │
│                                                             │
│   7️⃣  Automation = Less manual work = More coding!        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

<!-- _class: lead -->

# ❓ Questions?

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│    GitHub: @0xkatana                                        │
│    Email:  (check workshop)                                │
│                                                             │
│    Thank you for attending! 🎉                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

<!-- _class: lead -->

# 🚀 Go Build Something!

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│      ███████╗██████╗ ██████╗  █████╗ ██████╗ ██████╗     │
│      ██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗    │
│      █████╗  ██████╔╝██████╔╝███████║██████╔╝██║  ██║    │
│      ██╔══╝  ██╔══██╗██╔══██╗██╔══██║██╔══██╗██║  ██║    │
│      ██║     ██║  ██║██║  ██║██║  ██║██║  ██║██████╔╝    │
│      ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝     │
│                                                             │
│                  Build. Test. Deploy. Repeat.               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```
