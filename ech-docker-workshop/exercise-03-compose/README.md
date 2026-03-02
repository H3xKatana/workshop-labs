# Exercise 3: Multi-Container App with Compose

**Objective:** Connect multiple services together using Docker Compose.

**Duration:** 30 minutes

---

## Overview

In this exercise, you'll:
- Extend your Node.js app to use PostgreSQL
- Create a docker-compose.yml file
- Manage service dependencies
- Use volumes for data persistence
- Test that data survives container restarts

---

## Step-by-Step Instructions

### Step 1: Update Your Application

Update **server.js** to connect to PostgreSQL:

```javascript
const express = require('express');
const { Pool } = require('pg');
const app = express();
const PORT = process.env.PORT || 3000;

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://postgres:password@localhost:5432/mydb'
});

app.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW() as time');
    res.json({
      message: 'Hello from Docker with Postgres!',
      database_time: result.rows[0].time,
      hostname: require('os').hostname()
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.status(200).json({ status: 'healthy', database: 'connected' });
  } catch (err) {
    res.status(500).json({ status: 'unhealthy', error: err.message });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
```

Update **package.json** to add pg dependency:
```json
{
  "name": "my-docker-app",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.11.0"
  }
}
```

---

### Step 2: Create docker-compose.yml

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:secret@postgres:5432/mydb
      - PORT=3000
    depends_on:
      - postgres
    restart: unless-stopped

  postgres:
    image: postgres:15-alpine
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=secret
      - POSTGRES_DB=mydb
    ports:
      - "5432:5432"
    restart: unless-stopped

volumes:
  pgdata:
```

---

### Step 3: Run and Test

```bash
# Build and start all services
docker compose up --build

# In another terminal, test the endpoints
curl http://localhost:3000
curl http://localhost:3000/health

# View logs
docker compose logs -f

# Stop (Ctrl+C) or in another terminal:
docker compose down
```

---

### Step 4: Test Persistence

```bash
# Start services in background
docker compose up -d

# Verify it's working
curl http://localhost:3000/health

# Stop and remove containers (but keep volumes!)
docker compose down

# Start again
docker compose up -d

# Verify data persisted - the database should still have data
curl http://localhost:3000
# Should show database_time from the query
```

---

### Step 5: Explore Compose Commands

```bash
# Scale the app service to 3 instances
docker compose up -d --scale app=3

# View logs for specific service
docker compose logs -f app

# Execute command in postgres container
docker compose exec postgres psql -U postgres -d mydb -c "SELECT * FROM pg_tables;"

# Stop and remove everything including volumes
docker compose down -v
```

---

## Verification Checklist

- [ ] App connects to database successfully
- [ ] Health check shows database status
- [ ] Data persists after container restart
- [ ] Services start in correct order (depends_on)
- [ ] Can scale app service

---

## What You Learned

✅ Writing docker-compose.yml  
✅ Service dependencies  
✅ Environment variables in Compose  
✅ Named volumes for persistence  
✅ Docker Compose commands  
✅ Service scaling  

---

## Troubleshooting

**Problem:** "Error: connect ECONNREFUSED"
**Solution:** The app started before PostgreSQL was ready. Use `depends_on` and add retry logic, or just restart the app container:
```bash
docker compose restart app
```

**Problem:** Port already in use
**Solution:** Change the host port mapping in docker-compose.yml:
```yaml
ports:
  - "3001:3000"  # Use 3001 on host instead
```

---

## Next Steps

Move on to [Exercise 4: Production Hardening](../exercise-04-production/)