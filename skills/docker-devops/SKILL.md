---
name: docker-devops
description: Creates production-ready Dockerfiles, docker-compose setups, GitHub Actions CI/CD workflows, and container optimizations. Trigger via /docker-devops or when containerizing or setting up CI/CD.
---

# Docker & DevOps Skill

Design, build, and optimize containerization setups and CI/CD pipelines adhering to production security and performance standards.

## Trigger Scenarios
- Slash command: `/docker-devops`
- User requests: "Dockerize this project", "สร้าง Dockerfile ให้หน่อย", "ทำ CI/CD pipeline", "Setup docker-compose with Postgres and Redis"

## Best Practices & Standards

1. **Production-Grade Dockerfiles**:
   - **Multi-Stage Builds**: Separate builder stages (compilation/dependencies) from minimal runtime stages (Alpine/Distroless/Debian-slim).
   - **Security**: Never run as `root` (use non-root user `USER node`, `USER appuser`).
   - **Layer Caching**: Copy lockfiles and dependency manifests first (`package.json`, `pnpm-lock.yaml`, `requirements.txt`) before copying application source.
   - **Signal Handling**: Use proper `ENTRYPOINT` or `init` system (e.g. `tini`) to handle SIGTERM/SIGINT gracefully.
   - **Proper .dockerignore**: Exclude `.git`, `node_modules`, `.env*`, `test`, `coverage`, cache dirs.

2. **Docker Compose Orchestration**:
   - Explicit service dependencies (`depends_on` with `condition: service_healthy`).
   - Persistent volume mounts for databases and stateful services.
   - Isolated bridge networks and environment variable files (`.env`).
   - Healthcheck configurations for databases, caches, and web services.

3. **CI/CD Pipelines (GitHub Actions)**:
   - Automated linting, type-checking, and test runs on Pull Request and push to `main`.
   - Dependency caching (`actions/cache`, `setup-node`, `setup-python`).
   - Docker image build and push with Buildx, layer caching, and semantic version tagging.

## Instructions for the Agent

1. **Detect Stack**: Inspect `package.json`, `go.mod`, `Cargo.toml`, `requirements.txt`, etc.
2. **Generate Deliverables**:
   - Create minimal, secure `Dockerfile` with multi-stage builds.
   - Create `.dockerignore` tailored to the language.
   - Create `docker-compose.yml` if multi-service infrastructure is needed.
   - Create `.github/workflows/ci.yml` if CI pipeline is requested.
3. **Verify and Document**: Provide instructions on how to test locally (`docker compose up --build`).
