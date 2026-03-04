# PROGRESS.md - AI Progress Tracking

This file tracks development progress for AI assistants working on this project.

## ✅ Completed: Parameterized Scenarios (2025-12-05)

### What Was Done
1. **Created unified `infra/` scenario** with `MOLECULE_ENV` variable support
2. **Created unified `day0/` scenario** with `MOLECULE_ENV` variable support
3. **Added environment inventories**: `small/` (2 nodes), `prod/` (9 nodes), `dev/` (1 node)
4. **Updated Taskfile.yml** with parameterized tasks and backward-compatible aliases
5. **Removed old directories**: `infra_small/`, `day0_small/`

### Current Architecture
```
molecule/
├── environments/           # Environment-specific inventories
│   ├── small/             # 2 nodes (1 indexer + 1 license/search) - default
│   ├── prod/              # 9 nodes (full cluster topology)
│   └── dev/               # 1 node (single all-in-one)
├── infra/                 # Unified infrastructure scenario
├── day0/                  # Unified deployment scenario
└── day1/                  # Operations scenario
```

### Working Commands
```bash
task setup                       # One-time setup
task infra:test                  # Test with small env (default)
MOLECULE_ENV=prod task infra:test # Test with prod env
MOLECULE_ENV=dev task infra:test  # Test with dev env
task day0:test                   # Deploy Splunk

# Backward compatible aliases
task infra_small:test            # Same as default (small)
task day0_small:test             # Same as default (small)
```

---

## ✅ Verified: Small + Dev Smoke Tests (2026-01-22)

### What Was Verified
1. **Molecule stable release**: `molecule-runner` updated to use `molecule==25.12.0` (stable)
2. **infra (small)**: create → prepare → verify → destroy succeeds
3. **day0 (small)**: converge + verify succeeds (Splunk up, systemd-managed)
4. **day1 (small)**: converge + verify succeeds (restart + health checks)
5. **infra (dev)**: create → prepare → verify → destroy succeeds

### Commands Run
```bash
cd testing
MOLECULE_ENV=small task infra:test
MOLECULE_ENV=small task infra:setup
MOLECULE_ENV=small task day0:test
MOLECULE_ENV=small task day1:test

MOLECULE_ENV=dev task infra:test
```

### Notes / Known Warnings
- Molecule prints `CRITICAL 'molecule/default/molecule.yml' glob failed` (harmless; shared state disabled).
- Docker platform mismatch warning on Apple Silicon (amd64 images on arm64 host).
- Upstream role `configure_splunk_boot.yml` attempts an init.d stop even when using systemd; it is `ignore_errors: true` and did not block day0.

### Remaining Coverage
- `prod` (9-node) end-to-end (infra/day0/day1) not yet run.

---

## ✅ Verified: Small Workflow + Prod Infra (2026-01-27)

### What Was Verified
1. **infra prepare (docker connection)**: force `ansible_user: root` to avoid tmp dir creation failures during docker-based prepare
2. **infra verify (systemd check)**: switched to `/proc/1/comm` so AlmaLinux containers without `ps` still validate PID 1
3. **workflow:full (small)**: infra:setup → day0:test → day1:test → infra:destroy succeeds
4. **infra:test (prod)**: create → prepare → verify → destroy succeeds

### Commands Run
```bash
cd testing
MOLECULE_ENV=small task workflow:full
MOLECULE_ENV=prod task infra:test
```

---

## 🎯 Next Priorities

1. **Complete day0 Splunk deployment** - Full installation testing
2. **Implement day1 operations** - Restart, backup, maintenance scenarios
3. **Add verification playbooks** - Test Splunk services, cluster health
4. **CI/CD integration** - GitHub Actions workflow

---

## Historical Progress

### SSH Architecture Fixed (2025-01-08)
- SSH keys generated in setup phase (`testing/.secrets/`)
- Key distribution via Ansible to all containers
- SSH connectivity verified from molecule-runner to all hosts

### Infrastructure Scenarios Working (2025-09)
- Container creation via Docker API
- Web terminal (ttyd) with nginx proxy
- Shared inventory driving all scenarios

### Project Cleanup (2025-08)
- Moved testing files to `testing/` directory
- Removed host dependencies (containerized approach)
- Consolidated scenarios (removed getting-started, lab)

---
*Last Updated: 2026-01-27*
