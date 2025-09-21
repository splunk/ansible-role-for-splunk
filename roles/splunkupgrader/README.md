# Splunk Upgrader Role

This Ansible role installs and configures the Splunk Remote Upgrader utility, which enables remote upgrading of Splunk Universal Forwarders across your infrastructure.

## Description

The Splunk Remote Upgrader is a utility that allows administrators to centrally manage and upgrade Splunk Universal Forwarders without manual intervention on each host. This role automates the installation and configuration of the upgrader daemon on target systems.

## Requirements

- Ansible 2.9 or higher
- Target systems must be Linux-based
- Root privileges on target systems
- **Splunk Remote Upgrader package**: Must be downloaded from [Splunk's official site](https://help.splunk.com/en/splunk-enterprise/forward-and-process-data/splunk-remote-upgrader-for-linux-universal-forwarders/10.0/installation/download-your-remote-upgrader) and placed in the `files/` directory

## Role Variables

### Default Variables

The following variables can be overridden in your playbooks or inventory:

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `upgrader_version` | `102` | Version of the Splunk Upgrader to install |
| `SPLUNK_UPDATER_USER` | `splunkupgrader` | Username for the upgrader service |
| `SPLUNK_UPDATER_GROUP` | `splunkupgrader` | Group name for the upgrader service |
| `MONITOR_PKG_INTERVAL_SEC` | `5` | Package monitoring interval in seconds (5-300) |
| `FWD_UPGRADE_TIMEOUT_SEC` | `300` | Forwarder upgrade timeout in seconds (60-600) |
| `FWD_UPGRADE_MAX_RETRY` | `3` | Maximum retry attempts for upgrade |
| `ROTATE_HISTORY_LOG_DAYS` | `30` | Number of days to retain history logs (0-360) |
| `upgrader_package_file` | `splunk-upgrader-linux-{{ upgrader_version }}.tgz` | Name of the upgrader package file |
| `upgrader_package_dest` | `/tmp/` | Destination directory for package extraction |
| `upgrader_install_base` | `/opt/` | Base installation directory |
| `upgrader_install_path` | `{{ upgrader_install_base }}splunkupgrader/` | Full installation path |

## Dependencies

None

## Example Playbook

### Basic Usage

```yaml
---
- hosts: splunk_forwarders
  become: yes
  roles:
    - splunkupgrader
```

### Custom Configuration

```yaml
---
- hosts: splunk_forwarders
  become: yes
  vars:
    upgrader_version: 102
    SPLUNK_UPDATER_USER: custom_upgrader
    MONITOR_PKG_INTERVAL_SEC: 10
    FWD_UPGRADE_TIMEOUT_SEC: 600
  roles:
    - splunkupgrader
```

### Using with Serial Execution

```yaml
---
- hosts: splunk_forwarders
  become: yes
  serial: 50  # Process 50 hosts at a time
  roles:
    - splunkupgrader
```

## What This Role Does

1. **Package Deployment**: Extracts the Splunk Upgrader package to the target system
2. **Configuration**: Creates a customized configuration file based on your variables
3. **Installation**: Runs the upgrader installation script with license acceptance
   - The installation script automatically creates a systemd service for the upgrader daemon
   - The installation script automatically creates the upgrader user and group as specified

## Required Files

### Splunk Remote Upgrader Package

This role requires the Splunk Remote Upgrader package, which must be downloaded separately from Splunk's official website:

1. **Download Location**: Visit [Splunk's Remote Upgrader download page](https://help.splunk.com/en/splunk-enterprise/forward-and-process-data/splunk-remote-upgrader-for-linux-universal-forwarders/10.0/installation/download-your-remote-upgrader)
2. **Package Name**: Download `splunk-remote-upgrader-for-linux-universal-forwarders_102.tgz`
3. **Extract and Place**:
   - Extract the downloaded archive
   - Navigate to `default/packages/` within the extracted content
   - Copy `splunk-upgrader-linux-102.tgz` (or the version specified by `upgrader_version`) to the `files/` directory of this role

**Note**: The package is not included in this repository due to licensing restrictions. You must download it directly from Splunk.

### Files Included in This Role

- `templates/local_config_102.j2` - Configuration template for the upgrader

## Post-Installation

After running this role, the Splunk Remote Upgrader will be:

- Installed in `/opt/splunkupgrader/` (by default)
- Running as a systemd service (`splunk-upgrader.service`)
- Configured with your specified parameters
- Ready to monitor for upgrade packages and perform remote upgrades

### Service Management

```bash
# Check service status
sudo systemctl status splunk-upgrader

# Start/stop the service
sudo systemctl start splunk-upgrader
sudo systemctl stop splunk-upgrader

# View logs
sudo journalctl -u splunk-upgrader -f
```

### Configuration Updates

To modify the upgrader configuration after installation:

1. Edit `/opt/splunkupgrader/config/local_config`
2. Restart the service: `sudo systemctl restart splunk-upgrader`

## Security Considerations

- The upgrader runs with the permissions of the configured user/group
- Installation requires root privileges
- Configuration files contain sensitive settings that should be managed carefully
- The upgrader monitors `/tmp/SPLUNK_UPDATER_MONITORED_DIR` for packages by default

## Troubleshooting

### Common Issues

1. **Permission Errors**: Ensure the role is run with `become: yes`
2. **Service Won't Start**: Check systemd logs with `journalctl -u splunk-upgrader`
3. **Package Not Found**:
   - Verify the upgrader package file exists in the `files/` directory
   - Download `splunk-remote-upgrader-for-linux-universal-forwarders_102.tgz` from [Splunk's official site](https://help.splunk.com/en/splunk-enterprise/forward-and-process-data/splunk-remote-upgrader-for-linux-universal-forwarders/10.0/installation/download-your-remote-upgrader)
   - Extract the downloaded file and copy `splunk-upgrader-linux-102.tgz` from `default/packages/` to the role's `files/` directory
   - Ensure the filename matches the `upgrader_package_file` variable
4. **Configuration Errors**: Review `/opt/splunkupgrader/config/local_config`

### Log Locations

- Service logs: `journalctl -u splunk-upgrader`
- Upgrader logs: `/opt/splunkupgrader/log/`

## License

See the main repository LICENSE file.

## Author Information

This role is part of the ansible-role-for-splunk project.

## Contributing

Please refer to the main repository for contribution guidelines.

---

For more information about the Splunk Remote Upgrader utility, consult the official Splunk documentation.
