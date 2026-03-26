# agentic-se-image

Pre-built DevContainer image for the [INNOQ](https://www.innoq.com/) **Agentic Software Engineering** training. Used via GitHub Codespaces.

## What's included

| Tool | Version / Source |
|---|---|
| **Node.js** | 22.14.0 (pinned, binary tarball) |
| **Claude Code** | `@anthropic-ai/claude-code` (latest at build time) |
| **Playwright MCP + Chromium** | Pre-installed so the MCP server starts instantly |
| **Docker CE** | docker-ce, containerd, buildx, compose (official apt repo) |
| **act** | GitHub Actions local runner (latest release) |
| **GitHub CLI** | `gh` (official apt repo) |
| **Git, Zsh, Oh My Zsh** | From base image (`devcontainers/base:bookworm`) |

## Usage in a training repo

```jsonc
{
    "name": "Agentic SE",
    "image": "ghcr.io/innoq-trainings/agentic-se-image:latest",

    // Docker-in-Docker: privileged mode + volume + daemon start
    "runArgs": ["--init", "--privileged"],
    "mounts": ["source=dind-var-lib-docker,target=/var/lib/docker,type=volume"],
    "postStartCommand": "sudo /usr/local/share/docker-init.sh",

    "customizations": {
        "vscode": {
            "extensions": [
                "anthropic.claude-code"
            ]
        }
    }
}
```

## Image builds

The image is built and pushed to `ghcr.io/innoq-trainings/agentic-se-image` by a [GitHub Actions workflow](.github/workflows/build-image.yml).

**Triggers:**
- Push to `main` (when `Dockerfile`, `docker-init.sh`, or the workflow file changes)
- Weekly (Monday 06:00 UTC) to pick up security updates
- Manual via `workflow_dispatch`

**Tags:** `latest`, `sha-<commit>`, `YYYYMMDD`

## Local development

Build and test locally:

```bash
docker build -t agentic-se-image .

docker run --rm -it --privileged agentic-se-image bash
# Inside the container:
node --version        # v22.14.0
act --version
claude --version
gh --version
docker --version
ls /opt/playwright-browsers/   # Chromium present
```
