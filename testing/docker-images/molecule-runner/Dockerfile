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
        build-essential && \
    rm -rf /var/lib/apt/lists/*

# Install uv for fast Python package management
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Install ansible-dev-tools for complete Ansible development environment
RUN pip3 install ansible-dev-tools

RUN pip3 install --upgrade molecule==25.12.0
RUN pip3 install --upgrade molecule-plugins

# Install additional tools
RUN uv tool install ansible-lint

# Install requests library for Docker modules
RUN pip3 install requests

# Add tools to PATH
ENV PATH="/root/.local/bin:/root/.local/share/uv/tools/ansible-lint/bin:$PATH"

# Install required Ansible collections
RUN ansible-galaxy collection install ansible.posix && \
    ansible-galaxy collection install community.crypto && \
    ansible-galaxy collection install community.general && \
    ansible-galaxy collection install community.docker

# Create workspace
WORKDIR /workspace

# Default command
CMD ["molecule", "--help"]