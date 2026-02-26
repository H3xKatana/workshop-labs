# Workshops

This is a repository for hosting various technical workshops.

## Available Workshops

- [ech-docker-workshop](./ech-docker-workshop/) - Docker fundamentals workshop

## Adding a New Workshop

1. Create a new directory at the root level (e.g., `ech-kubernetes-workshop/`)
2. Add your workshop content (exercises, slides, etc.)
3. If your workshop has slides, add a `slides/` subfolder with:
   - `package.json` with marp-cli dependency
   - `*.md` files for slide content
4. The CI pipeline will automatically detect and build slides

## Slides

Slides are built using [Marp](https://marp.app/). Each workshop with slides should have:

```
workshop-name/
└── slides/
    ├── package.json
    └── *.md
```

The CI pipeline automatically builds HTML from markdown slides and uploads them as artifacts.

## CI/CD

This repository uses GitHub Actions to build slides. See [.github/workflows/build-slides.yml](./.github/workflows/build-slides.yml) for details.
