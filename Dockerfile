FROM mcr.microsoft.com/devcontainers/base:bookworm

# ── Node.js (pinned version) ────────────────────────────────────
ARG NODE_VERSION=22.14.0
RUN DPKG_ARCH=$(dpkg --print-architecture) && \
    case "$DPKG_ARCH" in amd64) ARCH=x64;; arm64) ARCH=arm64;; *) ARCH=$DPKG_ARCH;; esac && \
    curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH}.tar.xz" \
    | tar -xJ -C /usr/local --strip-components=1 && \
    node --version && npm --version

# ── act (GitHub Actions local runner) ────────────────────────────
RUN DPKG_ARCH=$(dpkg --print-architecture) && \
    case "$DPKG_ARCH" in amd64) ARCH=x86_64;; arm64) ARCH=arm64;; *) ARCH=$DPKG_ARCH;; esac && \
    curl -fsSL "https://github.com/nektos/act/releases/latest/download/act_Linux_${ARCH}.tar.gz" \
    | tar xz -C /usr/local/bin act

# ── Claude Code + Playwright MCP ────────────────────────────────
RUN npm install -g @anthropic-ai/claude-code && \
    npm cache clean --force

# ── Chromium for Playwright MCP ──────────────────────────────────
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/playwright-browsers
RUN npx playwright install chromium --with-deps && \
    rm -rf /var/lib/apt/lists/*

# ── Docker CE (Docker-in-Docker) ────────────────────────────────
RUN apt-get update && \
    apt-get install -y ca-certificates curl gnupg && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" \
    > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/* && \
    usermod -aG docker vscode

# ── Docker Daemon Entrypoint ────────────────────────────────────
COPY docker-init.sh /usr/local/share/docker-init.sh
RUN chmod +x /usr/local/share/docker-init.sh
ENTRYPOINT ["/usr/local/share/docker-init.sh"]

LABEL org.opencontainers.image.source="https://github.com/innoq-trainings/agentic-se-image"
LABEL org.opencontainers.image.description="DevContainer image for INNOQ Agentic SE trainings"
