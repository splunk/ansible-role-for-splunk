# Ephemeral Molecule Runner for Cross-Platform Testing
# Runs molecule commands to provision containers via Docker socket
FROM python:3.12-slim

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
        curl \
        git \
        openssh-client \
        docker.io \
        build-essential \
        ethtool && \
    rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install --no-cache-dir \
        ansible-dev-tools \
        molecule==25.12.0 \
        molecule-plugins \
        ansible-lint \
        requests

# Install go-task
RUN sh -c "$(curl -fsSL https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

# Install required Ansible collections
RUN ansible-galaxy collection install \
        ansible.posix \
        community.crypto \
        community.general \
        community.docker

WORKDIR /workspace
CMD ["molecule", "--help"]
