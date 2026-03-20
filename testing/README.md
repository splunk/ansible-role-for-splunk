# Local testing harness

This directory contains a Docker + Molecule harness for exercising this role against systemd-based container topologies.

Goals:
- repeatable local integration testing for role changes
- realistic SSH connectivity (instead of docker connection for converge)
- optional web terminal into the controller for interactive debugging

## Prereqs
- Docker

## Quick start
```bash
# one-time setup: secrets, images, downloads, network
./testing/run-tests.sh setup

# run the full test suite (infra, day0, day1, destroy)
./testing/run-tests.sh workflow:full

# quick workflow (infra + day0, keeps containers for debugging)
./testing/run-tests.sh workflow:quick

# list all available commands
./testing/run-tests.sh --list

# force rebuild the molecule-runner image
./testing/run-tests.sh --rebuild

# rebuild and then run a task
./testing/run-tests.sh --rebuild setup
```

## Environments
Select a topology via `MOLECULE_ENV`:
- `small` (default): 2 Splunk nodes + controller
- `dev`: 1 Splunk node + controller
- `prod`: 9 Splunk nodes + controller (+ git-server)

Examples:
```bash
MOLECULE_ENV=dev ./testing/run-tests.sh workflow:full
MOLECULE_ENV=prod ./testing/run-tests.sh workflow:full
```

## Splunk version
The Splunk version is set in each environment's group_vars:
```yaml
# testing/molecule/environments/<env>/group_vars/all.yml
splunk_package_version: 9.4.2
build_id: e9664af3d956
```
Download URLs and architecture suffixes are derived automatically from the role defaults. After changing the version, re-run `./testing/run-tests.sh download:splunk` to fetch the new binaries.

## Secrets
`run-tests.sh` creates secrets if they don't exist in `testing/.secrets/`:
- `inventory/group_vars/all.yml` - YAML vars file with `splunk_admin_password` and `gitea_secret_key`
- `id_rsa` / `id_rsa.pub` - SSH keys for container communication
- `ansible_password` - password for the ansible user on the web terminal

Secrets are loaded as an Ansible inventory source, making them available as regular variables. None of these files are committed to the repository.

## Web terminal (password-protected)
After running `./testing/run-tests.sh setup` followed by `./testing/run-tests.sh infra:setup`, a web terminal is exposed at `http://localhost:3000/ttyd`.
- Auth is enabled (`ansible:<password>`).
- The password is in `testing/.secrets/ansible_password`.

## Cleanup
```bash
# targeted cleanup: test containers, volumes, and network only
./testing/run-tests.sh reset
```
Docker volumes are prefixed with `ansible-splunk-test-` to avoid conflicts with other resources on your workstation.
