# Exercise 1: CI/CD Fundamentals

**Objective:** Understand the core concepts of CI/CD and why they matter.

**Duration:** 15 minutes

---

## Overview

In this exercise, you'll:
- Learn what CI/CD actually means
- Understand the benefits of automated pipelines
- See how code flows from development to production

---

## What is CI/CD?

**CI = Continuous Integration**
- Developers merge code changes frequently
- Automated builds run on every push
- Automated tests catch issues early

**CD = Continuous Delivery/Deployment**
- Code is always in a deployable state
- Automated release process
- One click (or automatic) to deploy

---

## The Traditional Workflow

```
Developer          QA Team           Operations
    │                  │                  │
    │  Write code     │                  │
    │---------------->│                  │
    │                 │  Manual testing  │
    │                 │----------------->│
    │                 │                  │
    │  Bug found!     │                  │
    |<----------------│                  │
    │  (days later)  │                  │
    │                 │                  │
    │  Fix code       │                  │
    │---------------->│                  │
    │                 │  More testing    │
    │                 │----------------->│
    │                 │                  │
    │                 │  Deploy (weeks)  │
    │                 │                  │
    └─────────────────┴──────────────────┘
              SLOW & FRUSTRATING
```

---

## The CI/CD Workflow

```
Developer          CI Server            Cloud
    │                   │                  │
    │  Push code        │                  │
    │------------------>│                  │
    │                   │  Build & Test    │
    │                   │----------------->│
    │                   │                  │
    │  Results (min)   │                  │
    |<------------------│                  │
    │                   │                  │
    │  Auto-deploy     │                  │
    │   (if passing)   │                  │
    │                   │---------------->│
    │                   │                  │
    └───────────────────┴──────────────────┘
              FAST & RELIABLE
```

---

## Key Benefits

| Benefit | Without CI/CD | With CI/CD |
|---------|---------------|------------|
| **Feedback** | Days/Hours | Minutes |
| **Bugs** | Production | Caught early |
| **Deploys** | Big bang | Incremental |
| **Confidence** | Low | High |
| **Speed** | Slow | Fast |

---

## The Pipeline Stages

```
┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐
│  BUILD  │──▶│  TEST   │──▶│ ANALYZE │──▶│ STAGING │──▶│ PROD    │
│         │   │         │   │         │   │         │   │         │
│ Compile │   │ Unit    │   │ Security│   │ Deploy  │   │ Deploy  │
│ Package │   │ Integrate│  │ Quality │   │ Verify  │   │ Monitor │
└─────────┘   └─────────┘   └─────────┘   └─────────┘   └─────────┘
```

---

## Common CI/CD Tools

| Tool | Type | Best For |
|------|------|----------|
| **GitHub Actions** | Cloud | GitHub projects |
| **GitLab CI** | Cloud/Self-hosted | GitLab users |
| **Jenkins** | Self-hosted | Enterprise |
| **CircleCI** | Cloud | Speed |
| **Travis CI** | Cloud | Open source |
| **Argo CD** | Kubernetes | GitOps |

---

## Pipeline Triggers

**What starts a pipeline?**

| Trigger | Description | Example |
|---------|-------------|---------|
| **Push** | Code pushed to branch | `push: [main, develop]` |
| **Pull Request** | PR opened/updated | `pull_request:` |
| **Schedule** | Cron-based execution | `schedule: "0 0 * * *"` |
| **Manual** | Workflow dispatch | `workflow_dispatch:` |
| **External** | Repository dispatch | `repository_dispatch:` |

---

## Scheduled Jobs (Cron)

**Run pipelines on a schedule:**

```yaml
name: Daily Security Scan

on:
  schedule:
    # Run at midnight every day (UTC)
    - cron: '0 0 * * *'
  # Also allow manual trigger
  workflow_dispatch:

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run security scan
        run: npm audit
```

**Cron syntax:**
```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6)
│ │ │ │ │
* * * * *
```

**Common schedules:**
```yaml
# Every day at midnight
cron: '0 0 * * *'

# Every Monday at 9am
cron: '0 9 * * 1'

# Every hour
cron: '0 * * * *'

# Every 15 minutes
cron: '*/15 * * * *'

# First day of month
cron: '0 0 1 * *'
```

---

## Scheduled Job Use Cases

**Why schedule jobs?**

| Use Case | Example |
|----------|---------|
| **Security scans** | Daily vulnerability checks |
| **Database cleanup** | Remove old records weekly |
| **Reports** | Generate weekly summaries |
| **Cache cleanup** | Clear CDN caches nightly |
| **Health checks** | Monitor services hourly |
| **Backups** | Daily database backups |
| **Dependency updates** | Weekly dependabot scans |

---

## Manual Triggers (workflow_dispatch)

**Allow manual execution:**

```yaml
name: Deploy to Production

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        default: 'staging'
      version:
        description: 'Version to deploy'
        required: false

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}
    steps:
      - name: Deploy ${{ github.event.inputs.version }}
        run: echo "Deploying to ${{ github.event.inputs.environment }}"
```

**Trigger from UI:** Actions tab → Run workflow

---

## Pull Request Triggers

**Validate every PR:**

```yaml
on:
  pull_request:
    branches: [main, develop]
    types: [opened, synchronize, reopened]
    paths-ignore:
      - '**.md'
      - 'docs/**'
```

**Types:**
- `opened` - PR created
- `synchronize` - New commit pushed
- `reopened` - PR reopened
- `closed` - PR merged or closed

---

## What You've Learned

✅ What CI/CD means  
✅ Benefits of automated pipelines  
✅ Pipeline stages overview  
✅ Popular CI/CD tools  
✅ Workflow triggers (push, PR, schedule)  
✅ Scheduled jobs with cron syntax  
✅ Manual workflow dispatch  
✅ Pull request automation  

---

## Next Steps

Move on to [Exercise 2: GitHub Actions Basics](../exercise-02-github-actions/)
