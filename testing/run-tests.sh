#!/usr/bin/env bash
# Run the testing framework inside a container. Requires only Docker on the host.
#
# Usage:
#   ./run-tests.sh              # Interactive shell with task available
#   ./run-tests.sh setup        # Run a specific task command
#   ./run-tests.sh infra:test   # Run infra test scenario
#   ./run-tests.sh --list       # List all available tasks
#
# Environment variables:
#   MOLECULE_ENV=prod ./run-tests.sh infra:test   # Override environment
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TESTING_DIR="$PROJECT_ROOT/testing"

# Build molecule-runner image if needed
if ! docker image inspect molecule-runner:latest >/dev/null 2>&1; then
    echo "Building molecule-runner image..."
    docker build -t molecule-runner:latest "$TESTING_DIR/docker-images/molecule-runner/"
fi

# Create network if needed
docker network inspect splunk-test-network >/dev/null 2>&1 || \
    docker network create splunk-test-network

# Install go-task inside the container at startup
INIT='sh -c "$(curl -fsSL https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin >/dev/null 2>&1'

# Mount the project at the SAME host path so that nested docker run commands
# (executed by the host Docker daemon via the mounted socket) resolve volume
# mount paths correctly.
DOCKER_ARGS=(--rm --network splunk-test-network)

# Allocate a TTY only when stdin is a terminal
if [ -t 0 ]; then
    DOCKER_ARGS+=(-it)
fi

DOCKER_ARGS+=(
    -v /var/run/docker.sock:/var/run/docker.sock
    -v "$PROJECT_ROOT":"$PROJECT_ROOT"
    -w "$TESTING_DIR"
)

# Forward MOLECULE_ENV if set
if [ -n "${MOLECULE_ENV:-}" ]; then
    DOCKER_ARGS+=(-e "MOLECULE_ENV=$MOLECULE_ENV")
fi

if [ $# -gt 0 ]; then
    exec docker run "${DOCKER_ARGS[@]}" \
        molecule-runner:latest \
        bash -c "${INIT} && exec task \"\$@\"" _ "$@"
else
    exec docker run "${DOCKER_ARGS[@]}" \
        molecule-runner:latest \
        bash -c "${INIT} && echo 'task ready - run: task --list' && exec bash"
fi
