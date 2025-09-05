# Splunk Testing Framework & Development Lab

A comprehensive Docker-based testing framework for the `ansible-role-for-splunk` that doubles as a full-featured Splunk development lab environment.

## 🎯 Multi-Purpose Platform

This framework serves multiple use cases:

- **Role Testing** - Validate ansible-role-for-splunk changes across realistic topologies
- **Splunk Lab Environment** - Long-running cluster for learning and experimentation  
- **Integration Testing** - Test apps, configurations, and workflows
- **Training Platform** - Learn Splunk clustering, administration, and troubleshooting
- **POC Environment** - Test new Splunk features and configurations safely
- **CI/CD Pipeline** - Automated testing for pull requests and releases

## 🏗️ Architecture

### Complete Splunk Cluster (12 containers):
- **Cluster Manager** (`splunk-master`) - Manages indexer cluster
- **License Master + DMC** (`splunk-license`) - Licensing and monitoring
- **Deployment Server** (`splunk-fwdmanager`) - App distribution to forwarders
- **2x Indexers** (`splunkapp-prod01/02`) - Multi-site data indexing  
- **2x Search Heads** (`splunkshc-prod01/02`) - Search head cluster
- **SH Deployer** (`splunk-deploy`) - App deployment to search heads
- **Universal Forwarder** (`splunk-uf01`) - Data collection
- **Git Server** (`git-server`) - Gitea lightweight git server for app deployment testing

### Management & Access Layer:
- **Ansible Controller** (`ansible-controller`) - Web terminal and deployment control
- **Persistent Volumes** - Maintains state across container restarts
- **Docker Networking** - Full connectivity between all components

## 🚀 Quick Start

### Prerequisites
- Docker with 32GB+ RAM allocated (64GB+ recommended)
- 8+ CPU cores (16+ recommended)
- [Task](https://taskfile.dev) command runner (installed automatically)

### Setup Process
```bash
git clone <this-repo>
cd ansible-role-for-splunk/testing

# Copy environment template and configure (optional)
cp .env.example .env
# Edit .env and add your Remote.it registration code if needed

task setup              # Complete environment setup (secrets + images)
```

## ▶️ Development Workflow

The testing framework follows a structured approach with three main phases:

### Phase 1: Infrastructure Setup (Container Creation)
```bash
task infra:create       # Create all containers (9 Splunk + git-server)
task infra:prepare      # Setup SSH infrastructure and services
task infra:destroy      # Clean up all containers
# OR complete workflow:
task infra:setup        # Setup infrastructure for testing (create + prepare, no destroy)
task infra:test         # Run complete infrastructure scenario (create + prepare + verify + destroy)
```

### Phase 2: Day 0 - Splunk Deployment
```bash
task setup              # Downloads Splunk software to testing/software/
task infra_small:setup  # Create infrastructure with SSH connectivity
task day0_small:test    # Run complete deployment scenario using local software
# OR step-by-step:
task day0_small:converge # Deploy Splunk via SSH using predownloaded software
task day0_small:verify   # Verify deployment
task infra_small:destroy # Clean up containers when done
```

### Phase 3: Day 1 - Operations (Planned)
```bash
task day1:test          # Run complete operations scenario (when implemented)
```

**Key Points:**
- Inventory source of truth: `testing/molecule/inventory/hosts.yml`
- SSH diagnostics: `task diag:ssh` targets group `full` (excludes `git_server`)
- Artifacts: Fetched via remote URLs in `testing/molecule/inventory/group_vars/all.yml`
- ACL: `skip_acl_install: true` for faster container testing

**Optional Environment Variables:**
- `R3_REGISTRATION_CODE` - Get your free registration code from [remote.it](https://remote.it) for external access

## 🌐 Web Terminal Access

After running `task infra:test`, access the web terminal at `http://localhost:3000/ttyd`:

- **Web Terminal**: Direct shell access to ansible-controller container
- **SSH Connectivity**: All Splunk containers accessible via SSH from the terminal
- **File Navigation**: Browse and edit configurations across the cluster
- **Persistent Sessions**: Connections survive browser refreshes
- **Ansible Environment**: Pre-configured with ansible-role-for-splunk

### Login Credentials
- **Username**: `ansible`
- **Password**: `2L6pL8IHVUOLvN9qMAt0`

### Web Terminal Features
- **ttyd Service**: Lightweight web terminal using xterm.js
- **nginx Proxy**: Secure reverse proxy on port 3000
- **Systemd Managed**: Automatic service startup and management
- **SSH Integration**: Full SSH connectivity to all containers

## 🌐 External Access (Optional)

Enable external access to your testing environment using Twingate:

### Setup
1. Get your Twingate network name and access tokens from your Twingate admin
2. Set in `.env`:
   ```bash
   TWINGATE_NETWORK=your-network-name
   TWINGATE_ACCESS_TOKEN=your-access-token
   TWINGATE_REFRESH_TOKEN=your-refresh-token
   ```
3. Start with remote access: `task twingate:start`

### Usage
```bash
# Start Twingate connector
task twingate:start

# Check status
task twingate:status

# Stop Twingate connector
task twingate:stop
```

### Integration with Testing
Twingate can be integrated with your testing workflow:
```bash
# Start testing with remote access
task infra:test && task twingate:start

# Access via Twingate when containers are running
# Stop everything when done
task infra:destroy && task twingate:stop
```

**Note:** Twingate provides secure, zero-trust network access to your testing environment. The connector runs independently and can be started/stopped as needed.

## 🛠️ Usage

### ✅ Primary Commands (Updated for Current Taskfile)
```bash
task setup              # Complete environment setup (secrets + images)
task infra:test         # Run complete infrastructure scenario (create + services)
task day0:test          # Run complete Splunk deployment scenario
task status             # Show all container status
task infra:destroy      # Clean shutdown
```

### 🔄 Infrastructure Management
```bash
task infra:create       # Create all containers with services
task infra:destroy      # Destroy all infrastructure containers
task status             # Show all container status
```

> Note: `infra:destroy` removes containers and the scenario network but intentionally does not delete named Docker volumes (e.g., Splunk data volumes, ssh-keys). Use `task reset` between full test runs to minimize cross-run interference.

### 🚀 Day 0 - Splunk Provisioning (SSH Architecture Working ✅)
```bash
task day0:converge      # Deploy Splunk via SSH to existing infrastructure
task day0:verify        # Verify Splunk deployment
task day0:playbook      # Direct ansible-playbook deployment (bypasses molecule)
```

### 🔧 Day 1 - Operations (Planned)
```bash
task day1:test          # Complete operations scenario (when implemented)
task day1:converge      # Run operational tasks
task day1:verify        # Verify operations
```

### 🛠️ Development Utilities
```bash
task setup:images       # Build all Docker base images
task diag:ssh           # Test SSH connectivity between containers
task diag:terminal      # Check ttyd and nginx health
task controller:start   # Start ansible-controller container
task controller:shell   # Shell into ansible-controller
task shell -- <container>   # Shell into any container
task dev:shell          # Interactive shell in molecule-runner
task dev:cleanup        # Clean up Docker resources
```

**Current Status:** ✅ Sprint 5 Complete - Day0 infrastructure with local software setup working. Splunk binaries predownloaded to testing/software/, ansible native inventory configured, and day0 converge playbook updated to use local software. Infrastructure ready for Splunk deployment, blocked by existing Splunk installation cleanup needed.

## 🌐 Web Terminal Interface

Access the web terminal at `http://localhost:3000/ttyd`:

- **Terminal Access** - Direct shell access to ansible-controller
- **SSH Connectivity** - All Splunk containers accessible via SSH
- **File Navigation** - Browse and edit configurations across the cluster
- **Persistent Sessions** - Connections survive browser refreshes
- **Ansible Environment** - Pre-configured with ansible-role-for-splunk

### Web Terminal

The testing framework uses ttyd as the web terminal:
```bash
task infra:test         # Creates infrastructure with ttyd terminal
task diag:terminal      # Check ttyd and nginx health
```

#### Why ttyd?
- More actively maintained (latest release March 2024)
- C-based implementation (more lightweight than Node.js)
- Uses xterm.js for frontend terminal emulation
- No JavaScript dependency issues
- Better stability and performance

## 🧪 Testing Scenarios

### ✅ Current Working Workflow (Updated)
```bash
# Step 1: Environment setup (one-time)
task setup              # Complete environment setup (secrets + images + software)

# Step 2: Infrastructure creation
task infra_small:setup  # Setup small infrastructure for testing (create + prepare, keeps containers)
# OR for testing infrastructure only:
task infra_small:test   # Run complete small infrastructure scenario (includes destroy)

# Step 3: Splunk deployment
task day0_small:test    # Run complete deployment scenario using local software
# OR step-by-step:
task day0_small:converge # Deploy Splunk via SSH using predownloaded software
task day0_small:verify   # Verify deployment

# Step 4: Operations (planned)
task day1:test          # Run complete operations scenario (when implemented)

# Step 5: Cleanup
task infra_small:destroy # Clean up containers when done

# Step 6: Check status
task status             # All containers running properly ✅
```

### 🎯 Complete Development Workflow
```bash
# Full end-to-end testing
task workflow:full      # Complete workflow: infra → day0 → day1

# Quick development cycle
task workflow:quick     # Fast iteration: infra → day0 only

# Individual scenario testing
task infra:test         # Infrastructure testing
task day0:test          # Deployment testing
task day1:test          # Operations testing (when implemented)
```

### Current Development Status
```bash
# Working development cycle
task infra:test         # Create fresh infrastructure environment ✅
task day0:converge      # Test SSH connectivity to all hosts ✅
task status             # Verify all containers healthy ✅
task infra:destroy      # Clean shutdown ✅

# Next priorities:
# - Complete Splunk role integration (acl, sudo fixes)
# - Implement day1 operations scenarios
# - Add comprehensive verification playbooks
```

## 📊 Resource Requirements

### Minimum:
- **RAM**: 32GB (basic functionality)
- **CPU**: 8 cores
- **Disk**: 50GB free space

### Recommended:
- **RAM**: 64GB (full performance)
- **CPU**: 16+ cores  
- **Disk**: 100GB+ free space
- **Docker**: Privileged containers enabled

## 🔧 Advanced Usage

### 🏗️ SSH Architecture (Sprint 3 Achievement)
**Problem Solved:** SSH keys are generated in setup phase and distributed properly to all containers.

**Technical Details:**
- SSH keys: Generated once via `task setup:secrets` → `testing/.secrets/id_rsa`
- Project mount: Entire repo mounted to `/workspace` in molecule-runner container
- Key access: Keys read directly from `/workspace/testing/.secrets/` using `delegate_to: localhost`
- Key distribution: Public key pushed to all containers during `lab:prepare`; private key never copied to hosts
- Controller: Keys copied to `/home/ansible/.ssh/` on `ansible-controller` for SSH authentication
- Ansible: Uses `/home/ansible/.ssh/id_rsa` via `group_vars/all.yml`
- Connectivity: SSH working from molecule-runner to all 12 Splunk containers
- Network: Docker hostname resolution enabling realistic SSH-based testing
- Reuse: Same keys persist across test runs for efficiency

### 🔐 End-to-End Key Distribution Logic (Source of Truth = setup phase)
1. Key generation (Setup Phase)
   - `task setup:secrets` runs `ssh-keygen` → `testing/.secrets/id_rsa`
   - Keys created once and reused across test runs
2. Key access (Lab Phase)
   - Project root mounted to `/workspace` in molecule-runner container
   - Keys accessible at `/workspace/testing/.secrets/` (no special mounting needed)
3. Distribution to hosts (Prepare Phase)
   - `molecule/lab/prepare.yml` reads keys from host filesystem using `delegate_to: localhost`
   - Public key copied to `/home/ansible/.ssh/authorized_keys` on every host
   - SSH client config created to disable strict host key checking
4. Controller convenience
   - Both keys copied to `ansible-controller:/home/ansible/.ssh/` for SSH authentication
   - Enables ansible user on controller to SSH to other containers
5. Ansible configuration
   - `testing/molecule/inventory/group_vars/all.yml` sets `ansible_ssh_private_key_file: /home/ansible/.ssh/id_rsa`

Guarantees:
- Keys generated once in setup phase for reuse across test runs
- No keys baked into Docker images
- Private key never distributed to Splunk hosts
- Project mount enables direct host filesystem access

### 📁 Scenario Structure (Current Working)
```
molecule/
├── inventory/           # Shared inventory drives all scenarios
│   ├── hosts.yml       # Infrastructure specification
│   └── group_vars/     # SSH configuration overrides
├── infra/              # Container creation + SSH setup + services ✅
├── day0/               # Splunk provisioning (SSH working) ✅
└── day1/               # Operations (planned Sprint 4)
```

### 👤 End-to-End User Management Logic and Execution Contexts

**Understanding how users and processes execute throughout the testing lifecycle:**

#### Phase 1: Container Bootstrap (Molecule Create)
- **Host Process**: Docker daemon runs as root
- **Container Init**: `/sbin/init` starts as **UID=0 (root)** inside container
- **systemd Services**: SSH daemon, systemd-user-sessions run as root
- **Molecule Connection**: `ansible_connection: docker, ansible_user: root`
- **Purpose**: Container infrastructure setup, service initialization

#### Phase 2: SSH Infrastructure Setup (Molecule Prepare)  
- **Connection Method**: SSH from molecule-runner to containers
- **SSH Target User**: `ansible` user (**UID=1000**) 
- **SSH Key Authentication**: Password-less SSH keys distributed to `ansible` user
- **Privilege Escalation**: `ansible` user uses `sudo` to become root for system tasks
- **Purpose**: SSH connectivity, key distribution, system preparation

#### Phase 3: Splunk Role Deployment (ansible-playbook)
- **Connection Method**: SSH from molecule-runner to containers
- **SSH Target User**: `ansible` user (**UID=1000**)
- **Privilege Context**: 
  - Most tasks run as `ansible` user
  - System tasks use `become: true` → `sudo` → **UID=0 (root)**
- **User Management Tasks**:
  - `ansible` user (UID=1000) uses `sudo` to create `splunk` user (**UID varies**)
  - `ansible` user (UID=1000) uses `sudo` to create `splunk` group (**GID varies**)
- **File Operations**:
  - Download/extract: `ansible` user → `sudo` → root creates files
  - Ownership changes: root changes ownership to `splunk:splunk`
- **Service Management**: `ansible` user → `sudo` → root manages systemd services

#### Phase 4: Splunk Application Runtime (Post-Deployment)
- **Splunk Processes**: Run as **`splunk` user** (not root)
- **File Ownership**: `/opt/splunk/` owned by `splunk:splunk`
- **Service Control**: systemd manages splunkd service running as `splunk` user
- **Management Access**: `ansible` user can still SSH in and `sudo` for administration

#### Key User Hierarchy:
1. **Container systemd (root/UID=0)**: Container init and system services
2. **ansible user (UID=1000)**: SSH access + sudo privileges for management
3. **splunk user (UID=varies)**: Runs Splunk application processes
4. **molecule-runner**: External orchestration, connects via SSH to `ansible` user

#### Critical Sudo Requirement:
The `ansible` user **must** be able to `sudo` without password to:
- Create `splunk` user/group
- Install software to `/opt/`
- Change file ownership
- Manage systemd services
- Configure system files

**Critical Fix Focus**: Validate AlmaLinux sudo/PAM behavior using distro defaults (no custom PAM overrides). Repair only if issues persist.

### 🔒 PAM and Login Gating in Containers

Containerized systemd environments can block non-root SSH logins during early boot or due to PAM account policies. This lab applies minimal, distro-appropriate fixes:

- Ubuntu/Debian family
  - Issue: `/run/nologin` may be present during boot; `pam_nologin` denies non-root users with “System is booting up…”.
  - Fix: `systemd-user-sessions.service` enabled in the base image and started in `molecule/lab/prepare.yml`. It removes `/run/nologin` when the system is ready.

- RedHat/AlmaLinux family
  - Issue: PAM account phase can deny the `ansible` user via `pam_sepermit.so` in minimal/container contexts (e.g., SELinux mappings or environment not fully initialized).
  - Fix (image-level): In `almalinux9-systemd-sshd/Dockerfile`, `pam_sepermit` is relaxed from `required` to `optional` in `/etc/pam.d/sshd`.
  - What “optional” means: If a PAM module marked `optional` fails or denies, it does not by itself cause the whole PAM stack to fail. The decision defers to other `sufficient`/`required` modules that follow. This avoids hard-failing SSH logins solely due to `pam_sepermit` in containerized lab setups where SELinux/policy contexts may be atypical. Security tradeoff is acceptable for this isolated test lab; production systems should keep distro defaults.

These changes are intentionally narrow, preserve distro defaults where possible, and are documented/reversible. The Splunk role under test remains untouched.


### Environment Persistence  
The lab environment persists data between runs:
- SSH keys in shared volume (working ✅)
- Splunk configurations and data (planned)
- Container networking and hostname resolution (working ✅)

### Integration Testing
Use this environment to:
- Test ansible-role-for-splunk changes with SSH connectivity ✅
- Validate deployment across multiple OS distributions
- Test cluster operations and maintenance procedures (planned)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test changes: `task infra:test && task day0:test`
4. Verify SSH connectivity: `task diag:ssh`
5. Verify changes work across all container types
6. Submit pull request

## 📖 Documentation

- [CLAUDE.md](../CLAUDE.md) - Complete project documentation and current status
- [PLAN.md](PLAN.md) - Development roadmap and sprint planning
- [Molecule Testing Guide](https://ansible.readthedocs.io/projects/molecule/)

---

**Status: Infrastructure Scenario Complete ✅ - SSH Setup Working ✅ - Container Management Operational ✅ - Ready for Day0 Completion**