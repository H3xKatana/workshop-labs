# Docker Workshop: From Zero to Production

A hands-on workshop covering Docker fundamentals through production-ready practices.

**Instructor:** Kara Mohamed Mourtadha (0xKatana)  
**Role:** DevOps/SRE Engineer  
**Duration:** 4-6 hours

---

## Workshop Overview

This workshop takes you from Docker basics to building production-ready containerized applications through hands-on exercises.

### What You'll Learn

1. ✅ Running existing containers
2. ✅ Building custom images
3. ✅ Multi-container orchestration with Docker Compose
4. ✅ Production hardening and best practices

---

## Prerequisites

- Docker Desktop installed
- Basic command line knowledge
- Text editor (VSCode recommended)
- curl or similar HTTP client

### Verify Installation

```bash
docker --version
docker run hello-world
```

---

## Workshop Structure

| Exercise | Topic | Duration | Files |
|----------|-------|----------|-------|
| [Exercise 1](exercise-01-first-container/) | First Container | 10 min | `commands.sh` |
| [Exercise 2](exercise-02-build-image/) | Build Your Image | 20 min | `Dockerfile`, `server.js` |
| [Exercise 3](exercise-03-compose/) | Multi-Container App | 30 min | `docker-compose.yml` |
| [Exercise 4](exercise-04-production/) | Production Hardening | 20 min | Optimized `Dockerfile` |

**Total hands-on time:** ~80 minutes

---

## Quick Start

1. **Clone this repo:**
   ```bash
   git clone <repo-url>
   cd docker-workshop
   ```

2. **Start with Exercise 1:**
   ```bash
   cd exercise-01-first-container
   cat README.md
   ```

3. **Follow along with the presentation:**
   - See [slides/workshop-slides.md](slides/workshop-slides.md)

---

## Workshop Slides

The full presentation is available at: [slides/workshop-slides.md](slides/workshop-slides.md)

---

## Resources

### Official Documentation
- [Docker Documentation](https://docs.docker.com)
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)

### Video Course
- [Complete Docker Course - DevOps Directive](https://youtu.be/RqTEHSBrYFw)
- Companion repo: https://github.com/sidpalas/devops-directive-docker-course

### Hands-On Practice Platforms
- **Iximiuz Labs** (Container Challenges): https://labs.iximiuz.com/challenges?category=containers
- **Killer Coda** (Interactive Scenarios): https://killercoda.com/
- **Play with Docker** (Browser-based): https://labs.play-with-docker.com/

### Books
- "Docker Deep Dive" - Nigel Poulton
- "The Docker Book" - James Turnbull

---

## Getting Help

If you get stuck:
1. Check the `examples/` directory for reference implementations
2. Review the solutions in each exercise's README
3. Ask your instructor or peers

---

## Key Takeaways

By the end of this workshop, you will be able to:

- 🐳 Run and manage Docker containers
- 🐳 Write efficient Dockerfiles
- 🐳 Orchestrate multi-container applications
- 🐳 Apply security best practices
- 🐳 Push images to registries

**Happy Dockering!** 🐳

---

## License

MIT - Feel free to use for your own workshops!