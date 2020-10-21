# ansible-role-for-splunk: An Ansible role for Splunk admins

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)&nbsp;
[![GitHub release](https://img.shields.io/github/v/tag/splunk/ansible-role-for-splunk?sort=semver&label=Version)](https://github.com/splunk/ansible-role-for-splunk/releases)

This repository contains an official Ansible role from Splunk that can manage Splunk Enterprise and Splunk Universal Forwarders on Linux-based platforms. Example playbooks and inventory files are also provided to help new Ansible users make the most out of this project.

ansible-role-for-splunk is used by the Splunk@Splunk team to manage Splunk's corporate deployment of Splunk.

----

## Table of Contents

1. [Purpose](#purpose)
1. [Getting Started](#gettingstarted)
1. [Extended Documentation](#gettingstarted)
1. [Frequently Asked Questions](#faq)
1. [Support](#support)
1. [Contributing](#contributing)
1. [License](#license)

----

## Purpose

#### What is ansible-role-for-splunk?
ansible-role-for-splunk is a single Ansible role for managing Splunk deployments remotely over SSH. It supports all Splunk deployment roles (Universal Forwarder, Heavy Forwarder, Indexer, Search Head, Deployment Server, Cluster Master, SHC Deployer, DMC, License Master) as well as management of all apps and configurations (via git repositories).

This codebase is used by the Splunk@Splunk team internally to manage our deployment, so it has been thoroughly vetted since its development in late 2018. For more information, checkout [our related .conf20 session](https://conf.splunk.com/learn/session-catalog.html?search=TRU1537C) for this project.

#### Design Philosophy
A few different design philosophies have been applied in the development of this project.

First, ansible-role-for-splunk was designed under the "Don't Repeat Yourself (DRY)" philosophy. This means that the project contains minimal code redundancy. If you want to fork this project and change any functionality, you only need to update the code in one place.

Second, ansible-role-for-splunk was designed to be idempotent. This means that if the system is already in the desired state that Ansible expects, it will not make any changes. This even applies to our app management code. For example, if you want to upgrade an app on a search head, and your repository does not contain a local/ folder, Ansible will not touch the existing local/ folder on the search head. This is accomplished using the synchronize module. For more information on that, refer to the configure_apps.yml task description.

Third, ansible-role-for-splunk was designed to manage all Splunk configurations as code. What do I mean by that? You're not going to find tasks for installing web certificates, disabling the REST port, templating indexes, or managing every Splunk configuration possible. Instead, you will find that we have a generic configure_apps.yml task which can deploy any version of any git repository to any path under $SPLUNK_HOME on the hosts in your inventory. We believe that having all configurations in git repositories is the best way to perform version control and configuration management for Splunk deployments. That said, we've made two exceptions:
1. Creation of the local splunk admin user. We are able to do this securely using ansible-vault to create the user-seed.conf during the initial installation, so we support that functionality, should you choose to use it. We are aware that this is not the only way to manage local user accounts in Splunk, so this functionality is disabled by default.
1. Configuring deploymentclient.conf for Deployment Server (DS) clients. We realize that some environments may have hundreds of clientNames configured and that creating a git repository for each variation would be pretty inefficient. Therefore, we support configuring deploymentclient.conf for your Ansible-managed forwarders using variables. The current version is based on a single template that supports only the clientName and targetUri keys. However, this can be easily extended with additional variables (or static content) of your choosing.

## Getting Started
Getting started with this role will requires you to:
1. Have Ansible installed (minimum v2.7 but this role is compatible with newer versions through v2.11)
1. Setup your inventory correctly
1. Configure the appropriate variables to describe the desired state of your environment
1. Create a playbook or leverage one of the included example playbooks

#### Ansible Setup
Ansible only needs to be installed on the host that you want to use to manage your Splunk deployments. We recommend having a dedicated server that is used only for Ansible orchestration, but technically you can run Ansible from any host, including your laptop, as long as you have the network connectivity required to SSH into the Splunk hosts that you want Ansible to manage.
* [Ansible Installation Guide](https://docs.ansible.com/ansible/devel/installation_guide/index.html)
* [Ansible User Guide](https://docs.ansible.com/ansible/devel/user_guide/index.html#getting-started)

#### Inventory
The layout of your inventory is critical to the tasks included in ansible-role-for-splunk. The "role" of your host is determined by it being a member of one or more inventory groups that define its Splunk role.  The following group names are currently supported:
* full
* uf
* clustermaster
* deploymentserver
* indexer
* licensemaster
* search
* shdeployer

Note that in Ansible you may nest groups within groups, and we depend on this heavily to differentiate a full Splunk installation vs a Univerasl Forwarder (UF) installation. You will see examples of this within the sample inventory.yml files included in the "environments" folder of this project.

You may also specify additional groups for provide further layers of abstraction nested within the aforementioned required groups. e.g. full -> indexer -> cluster_a | cluster_b | cluster_c

#### Variables
As proper usage of this role requires a thorough understanding of variables, familiarity with [Ansible variable precedence](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#ansible-variable-precedence) is highly recommended. Almost all variables used in this role have been added to [roles/splunk/defaults/main.yml](https://github.com/splunk/ansible-role-for-splunk/blob/master/roles/splunk/defaults/main.yml) (lowest precendence) for reference. Default values of "unconfigured" are automatically ignored at the task level.

A number of variables ship with this role, but many of them automatically configure themselves when the play is executed. For example, during the upgrade check, the desired version of Splunk that you want to be at is based solely upon the value of `splunk_package_url_full` or `splunk_package_url_uf`. We extract the version and build numbers from the URL automagically, and then compare those to the output of the "splunk version" command during the check_splunk.yml task to determine if an upgrade is required or not.

That said, there are a few variables that you'll definitely need to configure to use this role with your environment:

```
splunk_uri_lm - The URI for your license master (e.g. https://my_license_master:8089)
ansible_user - The username that you want Ansible to connect as for SSH access
ansible_ssh_private_key_file - The file path to the private key that the Ansible user should use for SSH access authentication
```

In addition, you may want to configure some of the optional variables that are mentioned in [roles/splunk/defaults/main.yml](https://github.com/splunk/ansible-role-for-splunk/blob/master/roles/splunk/defaults/main.yml) to manage things like splunk.secret, send Slack notifications, automatically install useful scripts, additional Linux packages, and so on.

In order to use the app management functionality, you will need to configure the following additional variables:
```
git_server: ssh://git@git.mydomain.com
git_key: ~/.ssh/mygit.key
git_project: FOO
git_version: bar
git_apps:
  - name: myapp
```

You will find additional examples in the included sample [group_vars](https://github.com/splunk/ansible-role-for-splunk/blob/master/environments/production/group_vars/deploymentserver.yml) and [host_vars](https://github.com/splunk/ansible-role-for-splunk/blob/master/environments/production/host_vars/my-shc-deployer.yml) files. Note that you may also specify `git_server`, `git_key`, `git_project`, and `git_version` within `git_apps` down to the repository (`name`) level.
**Tip:** If you only use one git server, you may want to define the `git_server` and related values in an all.yml group_var file.

**Configure local splunk admin password at install**
```
splunk_user_seed: true
splunk_admin_password: yourpassword
```

**Note:** If you do not configure these 2 variables, new Splunk installations will be installed without an admin account present. This has no impact on upgrades to existing installations.

#### Playbooks
The following example playbooks have been included in this project for your reference:
- **splunk_app_install.yml** - Install or upgrade apps on Splunk hosts using the configure_apps.yml task in the splunk role. Note that the apps you want to deploy should be defined in either host_vars or group_vars, along with a splunk_app_deploy_path. Refer to the documentation for app deployment for details.
- **splunk_install_or_upgrade.yml** - Install or upgrade Splunk (or Splunk UFs) on hosts using the check_splunk.yml task in the splunk role.
- **splunk_upgrade_full_stack.yml** - Example playbook that demonstrates how to upgrade an entire Splunk deployment with a single-site indexer cluster and a search head cluster using the splunk role. Note: This playbook does not upgrade forwarders, although you could easily add an extra play to do that.

## Extended Documentation
This section contains additional reference documentation.
----
#### Task File Descriptions

- **add_crashlog_script.yml** - Installs a bash script and cron job that will automatically clean-up splunkd crash log files. By default, every night at midnight, it will find any crash logs that are more than 7 days old and will delete them. You may change how many days of crash logs are retained by editing the cleanup_crashlogs.sh.j2 template.
- **add_diag_script.yml** - Installs a bash script and cron job that will automatically clean-up splunk diag files. By default, every night at midnight, it will find any diags that are more than 30 days old and will delete them. You may change how many days of splunk diags are retained by editing the cleanup_diags.sh.j2 template.
- **add_pstack_script.yml** - Copies the genpstacks.sh script to $SPLUNK_HOME/genpstacks.sh. This file is useful to have on all of your Splunk servers for when Splunk Support asks you to capture pstacks.

Note: Any task with an **adhoc** prefix means that it is intended to be used adhoc. These tasks are not included or used by others tasks. Instead, adhoc tasks tasks were developed for resolving various incidents that we've encountered, and rather than strip those automations out, we've opted to include them as bonus content.

- **adhoc_clean_dispatch.yml** - This task is intended to be used for restoring service to search heads should the dispatch directory become full. You should need to use this task in a healthy environment, but it is at your disposal should the need arise. The task will stop splunk, remove all files in the dispatch directory, and then start splunk.
- **adhoc_configure_hostname** - Renames a Splunk host. First, it configure's the system hostname using the Ansible inventory_hostname, then it updates server.conf with ansible_hostname, and finally it updates inputs.conf with the ansible_hostname. All Splunk configuration changes are made using the lineinfile module, which acts to preserve other configurations that may exist in server.conf and/or inputs.conf.
- **adhoc_decom_indexer.yml** - Executes a splunk offline --enforce-counts command. This is useful when decommissioning one or more indexers from an indexer cluster.
- **adhoc_fix_mongo.yml** - Use when Splunk is in a stopped state to fix mongodb/kvstore issues. Ensures that permissions are set correctly on mongo's splunk.key file and deletes mongod.lock if it exists.
- **adhoc_fix_server_certificate.yml** - Use to delete an expired server.pem and generate a new one (default certs). Useful if your server.pem certificate has expired and you are using Splunk's default certificate for splunkd. Note that default certificates present a security risk and that their use should be avoided, if possible.
- **adhoc_kill_splunkd.yml** - Some releases of Splunk have a "feature" that leaves zombie splunkd processes after a 'splunk stop'. Use this task after a 'splunk stop' to make sure that it's really stopped. Useful for upgrades on some of the 7.x releases.
- **check_splunk.yml** - Check if Splunk is installed. If Splunk is not installed, it will be installed on the host. If Splunk is already installed, the task will execute a "splunk version" command on the host, and then compare the version and build number of Splunk to the version and build number of the expected version of Splunk. Note that the expected version of Splunk does not need to be statically defined; The expected Splunk version and build are automatically extracted from the value of splunk_package_url_full or splunk_package_url_uf using Jinja regex filters. This task will work for both the Universal Forwarder and full Splunk Enterprise packages. You define which host uses what package by organizing it under the appropriate group ('full' or 'uf') in your Ansible inventory.
- **configure_apps.yml** - This task can be called directly from a playbook in order to deploy apps or configurations (i.e. git repositories) to Splunk hosts. You may also include this task within install_splunk.yml to do a "install and deploy apps" all in one play (or simply add a second play to your playbook to call this task after check_splunk.yml).
- **configure_authentication.yml** - Uses the template identified by the splunk_authenticationconf variable to install an authentication.conf file to $SPLUNK_HOME/etc/system/local/authentication.conf. We are including this task here since Ansible is able to securely deploy an authentication.conf configuration by using ansible-vault to encrypt sensitive values such as ad_bind_password. If you are using a common splunk.secret file, you can omit this task and instead use configure_apps.yml to deploy an authentication.conf file from a Git repository containing an authentication.conf app with pre-hashed credentials.
- **configure_bash.yml** - Configures bashrc and bash_profile files for the splunk user. Please note that the templates included with this role will overwrite any existing files for the splunk user (if they exist). The templates will define a custom PS1 at the bash prompt, configure the $SPLUNK_HOME environment variable so that you can issue "splunk <command>" without specifying the full path to the Splunk binary, and will enable auto-completion of Splunk CLI commands in bash.
- **configure_deploymentclient.yml** - Generates a new deploymentclient.conf file from the deploymentclient.conf.j2 template and installs it to $SPLUNK_HOME/etc/system/local/deploymentclient.conf. Note that this task requires two variables to be defined: clientName and splunk_uri_ds. Included automatically by install_splunk.yml.
- **configure_facl.yml** - Configure file system access control lists (FACLs) to allow the splunk user to read /var/log files and add the splunk user's group to /etc/audit/auditd.conf to read /var/log/audit/ directory.
- **configure_license.yml** - Configure the license master URI in server.conf for full Splunk installations when splunk_uri_lm has been defined. Note: This could also be accomplished using configure_apps.yml with a git repository.
- **configure_os.yml** - Increases ulimits for the splunk user and disables Transparent Huge Pages (THP) per Splunk implementation best practices.
- **configure_splunk_forwarder_meta.yml** - Configures a new indexed field called splunk_forwarder and sets its default value to the value of ansible_hostname. Note that you will need to install a fields.conf on your search head if you wish to use this custom indexed field.
- **configure_splunk_secret.yml** - Configures a common splunk.secret file from the files/authentication/splunk.secret so that pre-hashed passwords can be securely deployed. Note that changing splunk.secret will require re-encryption of any passwords that were encrypted using the previous splunk.secret since Splunk will no longer be able to decrypt them successfully.
- **configure_thp.yml** - Installs a custom systemd service that disables THP for RedHat|CentOS systems 6.0+. Note that this task is automatically called by the configure_os.yml task.
- **download_and_unarchive.yml** - Downloads the appropriate Splunk package to the Ansible hsot using the splunk_package_url (derived automatically from the values of the splunk_package_url_full and splunk_package_url_uf variables). The package is then installed to splunk_install_path (derived automatically in main.yml using the splunk_install_path and the package type). Calls handlers for enabling splunk boot-start (using init.d) and adding the configuration of ulimits to splunk's init.d file.
- **install_apps.yml** - Called by configure_apps.yml to perform app installation on the Splunk host. Do not call install_apps.yml directly!
- **install_splunk.yml** - Called by check_splunk.yml to install/upgrade Splunk and Splunk Universal Forwarders, as well as perform any initial configurations. This task is called by check_splunk.yml when the check determines that Splunk is not currently installed. This task will create the splunk user and splunk group, configure the bash profile for the splunk user (by calling configure_bash.yml), configure THP and ulimits (by calling configure_os.ym), download and install the appropriate Splunk package (by calling download_and_unarchive.yml), configure a common splunk.secret (by calling configure_splunk_secret.yml, if configure_secret is defined), create a deploymentclient.conf file with the splunk_ds_uri and clientName (by calling configure_deploymentclient.yml, if clientName is defined), install a user-seed.conf with a prehashed admin password (if used_seed is defined), and will then call the post_install.yml task. See post_install.yml entry for details on post-installation tasks.
- **install_utilities.yml** - Installs Linux packages that are useful for troubleshooting Splunk-related issues when install_utilities == true and linux_packages is defined with a list of packages to install.
- **main.yml** - This is the main task that will always be called when executing this role. This task sets the appropriate variables for full vs uf packages, sends a Slack notification about the play if the slack_token and slack_channel are defined, and then includes the task from the role to execute against, as defined by the value of the deployment_task variable. The deployment_task variable should be defined in your playbook(s). Refer to the included example playbooks to see this in action.
- **post_install.yml** - Executes post-installation tasks. Performs a touch on the .ui_login file which disables the first-time login prompt to change your password, ensures that splunk_home is owned by the correct user and group, and optionally configures three scripts to: cleanup crash logs and old diags (by calling add_crashlog_script.yml and add_diag_script.yml, respectively), and a pstack generation shell script for troubleshooting purposes (by calling add_pstack_script.yml). This task will install various Linux troubleshooting utilities (by calling install_utilities.yml) if install_utilities == true.
- **set_maintenance_mode.yml** - Enables or disables maintenance mode on a cluster master. Intended to be called by playbooks for indexer cluster upgrades/maintenance. Requires the "state" variable to be defined. Valid values: enabled, disabled
- **set_upgrade_state.yml** - Runs a splunk upgrade-{{ peer_state }} cluster-peers command on the cluster master. This task can be used for upgrading indexer clusters with new minor and maintenance releases of Splunk (assuming you are at Splunk v7.1.0 or higher). Refer to https://docs.splunk.com/Documentation/Splunk/latest/Indexer/Searchablerollingupgrade for more information.
- **splunk_offline.yml** - Runs a splunk offline CLI command. Useful for bringing down indexers non-intrusively by allowing searches to complete before stopping splunk.
- **splunk_restart.yml**  - Restarts splunk via CLI command. Used when waiting for a handler to run at the end of the play would be inappapropriate.
- **splunk_start.yml** - Starts splunk via CLI command. This task will also accept the license and answers yes for any prompts.  Used when waiting for a handler to run at the end of the play would be inappapropriate.
- **splunk_stop.yml** - Stops splunk via CLI command.  Used when waiting for a handler to run at the end of the play would be inappapropriate.
- **upgrade_splunk.yml** - Called by check_splunk.yml. Performs an upgrade of an existing splunk installation. Configures .bash_profile and .bashrc for splunk user (by calling configure_bash.yml), disables THP and increases ulimits (by calling configure_os.yml), disables boot-start (this addresses a bug in 7.2.x -- it gets re-enabled by a hander at the end), kills any stale splunkd processes present (by calling adhoc_kill_splunkd.yml). Note: You should NOT run the upgrade_splunk.yml task directly from a playbook. check_splunk.yml will call upgrade_splunk.yml if it determines that an upgrade is needed; It will then download and unarchive the new version of Splunk (by calling download_and_unarchive.yml), ensure that mongod is in a good stopped state (by calling adhoc_fix_mongo.yml), and will then perform post-installation tasks using the post_install.yml task.

## Frequently Asked Questions
**Q:** What is the difference between this and splunk-ansible?

**A:** The splunk-ansible project was built for the docker-splunk project, which is a completely different use case. The way that docker-splunk works is by spinning-up an image that already has splunk-ansible inside of it, and then any arguments provided to Docker are passed into splunk-ansible so that it can run locally inside of the container to install and configure Splunk there. While it's a cool use case, we didn't feel that splunk-ansible met our needs as Splunk administrators to manage production Splunk deployments, so we wrote our own.
##

**Q:** When using configure_apps.yml, the play fails on the synchronize module. What gives?

**A:** This is due to a [known Ansible bug](https://github.com/ansible/ansible/issues/56629) related to password-based authentication. To workaround this issue, use a key pair for SSH authentication instead by setting the `ansible_user` and `ansible_ssh_private_key_file` variables.
##

## Support
Use the [GitHub issue tracker](https://github.com/splunk/splunk-ansible/issues) to submit bugs or request features.

If you have questions or need support, you can:
* Post a question to [Splunk Answers](http://answers.splunk.com).
* Join the #ansible channel on [Splunk-Usergroups Slack](https://docs.splunk.com/Documentation/Community/1.0/community/Chat#Join_us_on_Slack).
* Please do note file cases in the Splunk support portal related to this project, as they will not be able to help you.

## License
Copyright 2018-2020 Splunk.

Distributed under the terms of the Apache 2.0 license, ansible-role-for-splunk is free and open-source software.
