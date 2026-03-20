#!/usr/bin/env bash
# Run the testing framework inside a container. Requires only Docker on the host.
#
# Usage:
#   ./run-tests.sh              # Interactive shell with task available
#   ./run-tests.sh setup        # Run a specific task command
#   ./run-tests.sh infra:test   # Run infra test scenario
#   ./run-tests.sh --list       # List all available tasks
#   ./run-tests.sh --rebuild    # Force rebuild molecule-runner image
#
# Environment variables:
#   MOLECULE_ENV=prod ./run-tests.sh infra:test   # Override environment
set -euo pipefail

REBUILD=false
if [[ "${1:-}" == "--rebuild" ]]; then
    REBUILD=true
    shift
fi

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TESTING_DIR="$PROJECT_ROOT/testing"
SECRETS_DIR="$TESTING_DIR/.secrets"

# Create secrets on the host (runs as current user, not root)
mkdir -p "$SECRETS_DIR/inventory/group_vars"
chmod 700 "$SECRETS_DIR"
test -f "$SECRETS_DIR/id_rsa"                      || ssh-keygen -t rsa -b 2048 -N '' -C 'splunk-test-cluster' -f "$SECRETS_DIR/id_rsa"
test -f "$SECRETS_DIR/ansible_password"             || dd if=/dev/urandom bs=1 count=100 2>/dev/null | tr -dc 'A-Za-z0-9' | head -c 20 > "$SECRETS_DIR/ansible_password"
test -f "$SECRETS_DIR/inventory/inventory.yml"      || printf -- '---\nall:\n' > "$SECRETS_DIR/inventory/inventory.yml"
test -f "$SECRETS_DIR/inventory/group_vars/all.yml" || printf -- '---\nsplunk_admin_password: %s\ngitea_secret_key: %s\n' \
    "$(dd if=/dev/urandom bs=1 count=100 2>/dev/null | tr -dc 'A-Za-z0-9' | head -c 20)" \
    "$(dd if=/dev/urandom bs=1 count=100 2>/dev/null | tr -dc 'A-Za-z0-9' | head -c 40)" \
    > "$SECRETS_DIR/inventory/group_vars/all.yml"

# Build molecule-runner image if needed (or if --rebuild was requested)
if [[ "$REBUILD" == true ]] || ! docker image inspect molecule-runner:latest >/dev/null 2>&1; then
    echo "Building molecule-runner image..."
    docker build -t molecule-runner:latest "$TESTING_DIR/docker-images/molecule-runner/"
fi

# Create network if needed
docker network inspect splunk-test-network >/dev/null 2>&1 || \
    docker network create splunk-test-network

# Mount the project at the SAME host path so that nested docker run commands
# (executed by the host Docker daemon via the mounted socket) resolve volume
# mount paths correctly.
HOST_UID=$(id -u)
HOST_GID=$(id -g)
DOCKER_ARGS=(--rm --network splunk-test-network -e "HOST_UID=$HOST_UID" -e "HOST_GID=$HOST_GID")

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
        bash -c "exec task \"\$@\"" _ "$@"
else
    exec docker run "${DOCKER_ARGS[@]}" \
        molecule-runner:latest \
        bash -c "echo 'task ready - run: task --list' && exec bash"
fi
