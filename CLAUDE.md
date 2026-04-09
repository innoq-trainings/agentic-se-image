# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Shared DevContainer base image for INNOQ's **Agentic Software Engineering** trainings — supports both Claude- and Copilot-based training variants. Consumed via GitHub Codespaces; training repos reference `ghcr.io/innoq-trainings/agentic-se-image` in their `devcontainer.json`.

This repo contains only the image definition and CI pipeline. There is no application code, no tests, no linter. VS Code extensions and secrets belong in the consumer repos.

## Repository Structure

- `Dockerfile` — image based on `devcontainers/base:bookworm`. Installs Node.js 22, Claude Code, GitHub Copilot CLI, Playwright MCP + Chromium, Docker CE (DinD), act, and GitHub CLI.
- `docker-init.sh` — entrypoint script that starts the Docker daemon inside the container (used via `postStartCommand`).
- `.github/workflows/build-image.yml` — builds multi-arch image (amd64 + arm64) and pushes to GHCR. Triggers on push to main (when Dockerfile/docker-init.sh/workflow change), weekly Monday 06:00 UTC, or manual dispatch.

## Build & Test

```bash
# Build locally
docker build -t agentic-se-image .

# Smoke-test the image
docker run --rm -it --privileged agentic-se-image bash
# Inside: node --version, claude --version, copilot --version, act --version, gh --version, docker --version
```

There are no automated tests. Verification is manual (run the container, check tool versions).

## CI/CD

Image is published to `ghcr.io/innoq-trainings/agentic-se-image` with tags: `latest`, `sha-<commit>`, `YYYYMMDD`. Uses GitHub Actions with QEMU for cross-platform builds and GHA cache for layer caching.

## Key Decisions

- **Node.js is installed from binary tarball** (not nvm/nodesource) to pin an exact version and support both architectures cleanly.
- **Docker-in-Docker via privileged mode** — the container needs `--privileged` and a named volume for `/var/lib/docker`. The daemon is started by `docker-init.sh`, not an ENTRYPOINT.
- **Playwright browsers are pre-installed** at build time (`PLAYWRIGHT_BROWSERS_PATH=/opt/playwright-browsers`) so the MCP server starts without download delays in Codespaces.
