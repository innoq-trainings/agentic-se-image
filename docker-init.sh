#!/bin/sh
set -e

# Clean up stale pid files from previous runs
rm -f /var/run/docker.pid /var/run/docker/containerd/containerd.pid

# Start Docker daemon in background
sudo dockerd &

# Wait for Docker daemon to be ready (max 30s)
TRIES=0
while ! sudo docker info >/dev/null 2>&1; do
    TRIES=$((TRIES + 1))
    if [ "$TRIES" -gt 30 ]; then
        echo "Docker daemon failed to start" >&2
        break
    fi
    sleep 1
done

# Execute whatever command was passed (e.g., shell)
exec "$@"
