# ansible-role-for-splunk: An Ansible role for Splunk admins

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)&nbsp;
[![GitHub release](https://img.shields.io/github/v/tag/splunk/ansible-role-for-splunk?sort=semver&label=Version)](https://github.com/splunk/ansible-role-for-splunk/releases)

This repository contains Splunk's official Ansible role for performing Splunk administration of remote hosts over SSH. This role can manage Splunk Enterprise and Universal Forwarders that are on Linux-based platforms (CentOS/Redhat/Ubuntu), as well as deploy configurations from Git repositories. Example playbooks and inventory files are also provided to help new Ansible users make the most out of this project.

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
ansible-role-for-splunk is a single Ansible role for deploying and administering production Splunk deployments. It supports all Splunk deployment roles (Universal Forwarder, Heavy Forwarder, Indexer, Search Head, Deployment Server, Cluster Master, SHC Deployer, DMC, License Master) as well as management of all apps and configurations (via git repositories).

This codebase is used by the Splunk@Splunk team internally to manage our deployment, so it has been thoroughly vetted since it was first developed in late 2018. For more information about Ansible best practices, checkout [our related .conf20 session](https://conf.splunk.com/learn/session-catalog.html?search=TRU1537C) for this project.

#### Design Philosophy
A few different design philosophies have been applied in the development of this project.

First, ansible-role-for-splunk was designed under the "Don't Repeat Yourself (DRY)" philosophy. This means that the project contains minimal code redundancy. If you want to fork this project and change any functionality, you only need to update the code in one place.

Second, ansible-role-for-splunk was designed to be idempotent. This means that if the system is already in the desired state that Ansible expects, it will not make any changes. This even applies to our app management code, which can update apps on search heads without modifying  existing local/ files that may have been created through actions in Splunk Web. For example, if you want to upgrade an app on a search head, and your repository does not contain a local/ folder, Ansible will not touch the existing local/ folder on the search head. This is accomplished using the synchronize module. For more information on that, refer to the `configure_apps.yml` task description.

Third, ansible-role-for-splunk was designed to manage all Splunk configurations as code. What do I mean by that? You're not going to find tasks for installing web certificates, templating indexes.conf, or managing every Splunk configuration possible. Instead, you will find that we have a generic configure_apps.yml task which can deploy any version of any git repository to any path under $SPLUNK_HOME on the hosts in your inventory. We believe that having all configurations in git repositories is the best way to perform version control and configuration management for Splunk deployments. That said, we've made a handful of exceptions:
1. Creation of the local splunk admin user. We are able to do this securely using ansible-vault to encrypt `splunk_admin_password` so that we can create a `user-seed.conf` during the initial installation. Please note that if you do not configure the `splunk_admin_password` variable with a new value, an admin account will not be created when deploying a new Splunk installation via `check_splunk.yml`.
1. Configuring deploymentclient.conf for Deployment Server (DS) clients. We realize that some environments may have hundreds of clientNames configured and that creating a git repository for each variation would be pretty inefficient. Therefore, we support configuring deploymentclient.conf for your Ansible-managed forwarders using variables. The current version is based on a single template that supports only the clientName and targetUri keys. However, this can be easily extended with additional variables (or static content) of your choosing.
1. Deployment of a new search head cluster. In order to initialize a new search head cluster, we cannot rely solely on creating backend files. Therefore, the role supports deploy a new search head cluster using provided variable values that are stored in your Ansible configurations (preferably via group_vars, although host_vars or inventory variables will also work).

## Getting Started
Getting started with this role will requires you to:
1. Install Ansible (version >=v2.7 is supported and should work through v2.10)
1. Setup your inventory correctly
1. Configure the appropriate variables to describe the desired state of your environment
1. Create a playbook or leverage one of the included example playbooks that specifies the deployment_task you'd like to run

#### Ansible Setup
Ansible only needs to be installed on the host that you want to use to manage your Splunk deployments. We recommend having a dedicated server that is used only for Ansible orchestration, but technically you can run Ansible from any host, including your laptop, as long as you have the network connectivity and credentials required to SSH into hosts that are in your Ansible inventory.
* [Ansible Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* [Ansible User Guide](https://docs.ansible.com/ansible/latest/user_guide/index.html)

#### Inventory
The layout of your inventory is critical for the tasks included in ansible-role-for-splunk to run correctly. The "role" of your host is determined by it being a member of one or more inventory groups that define its Splunk role. Ansible expects each host to be a member of one of these groups and uses that membership to determine the package that should be used, the installation path, the default deployment path for app deployments, and several other things. The following group names are currently supported:
* full
* uf
* clustermaster
* deploymentserver
* indexer
* licensemaster
* search
* shdeployer

Note that in Ansible you may nest groups within groups, and groups within those groups, and so on. We depend on this heavily to differentiate a full Splunk installation vs a Universal Forwarder (UF) installation, and to map variables in group_vars to specific groups of hosts. You will see examples of this within the sample `inventory.yml` files that are included in the "environments" folder of this project.

#### Variables
As proper usage of this role requires a thorough understanding of variables, familiarity with [Ansible variable precedence](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#ansible-variable-precedence) is highly recommended. Almost all variables used in this role have been added to [roles/splunk/defaults/main.yml](https://github.com/splunk/ansible-role-for-splunk/blob/master/roles/splunk/defaults/main.yml) (lowest precendence) for reference. Default values of "unconfigured" are automatically ignored at the task level.

Although a number of variables ship with this role, many of them automatically configure themselves when the play is executed. For example, during the upgrade check, the desired version of Splunk that you want to be at is based solely upon the value of `splunk_package_url_full` or `splunk_package_url_uf`. We extract the version and build numbers from the URL automagically, and then compare those values to the output of the "splunk version" command during the `check_splunk.yml` task to determine if an upgrade is required or not.

There are a few variables that need to configure out of the box to use this role with your environment:

```
splunk_uri_lm - The URI for your license master (e.g. https://my_license_master:8089)
ansible_user - The username that you want Ansible to connect as for SSH access
ansible_ssh_private_key_file - The file path to the private key that the Ansible user should use for SSH access authentication
```

In addition, you may want to configure some of the optional variables that are mentioned in [roles/splunk/defaults/main.yml](https://github.com/splunk/ansible-role-for-splunk/blob/master/roles/splunk/defaults/main.yml) to manage things like splunk.secret, send Slack notifications, automatically install useful scripts or additional Linux packages, etc. For a full description of the configurable variables, refer to the comments in [roles/splunk/defaults/main.yml](https://github.com/splunk/ansible-role-for-splunk/blob/master/roles/splunk/defaults/main.yml) and be sure to read-up on the task descriptions in this README file.

As of the v1.0.4 release for this role, an additional variable called `target_shc_group_name` must be defined in the host_vars for each SHC Deployer host. This variable tells Ansible which group of hosts in the inventory contain the SHC members that the SHC Deployer host is managing. This change improves the app deployment process for SHCs by performing a REST call to the first SH in the list from the inventory group whose name matches the value of `target_shc_group_name`. If the SHC is not in a ready state, then the play will halt and no changes will be made. It will also automatically grab the captain URI and use the captain as the deploy target for the `apply shcluster-bundle` handler. An example of how `target_shc_group_name` should be used has been included in the sample inventory at [environments/production/inventory.yml](https://github.com/splunk/ansible-role-for-splunk/blob/master/environments/production/inventory.yml).

In order to use the app management functionality, you will need to configure the following additional variables:
```
git_server: ssh://git@git.mydomain.com
git_key: ~/.ssh/mygit.key
git_project: FOO
git_version: bar
git_apps:
  - name: my_app
    version: master
```
You will find additional examples in the included sample [group_vars](https://github.com/splunk/ansible-role-for-splunk/blob/master/environments/production/group_vars/deploymentserver.yml) and [host_vars](https://github.com/splunk/ansible-role-for-splunk/blob/master/environments/production/host_vars/my-shc-deployer.yml) files. Note that you may also specify `git_server`, `git_key`, `git_project`, and `git_version` within `git_apps` down to the repository (`name`) level.
You may also override the auto-configured `splunk_app_deploy_path` at the repository level as well. For example, to deploy apps to $SPLUNK_HOME/etc/apps on a deployment server rather than the default of $SPLUNK_HOME/etc/deployment-apps. If not set, configure_apps.yml will determine the app deployment path based on the host's group membership within the inventory.
**Tip:** If you only use one git server, you may want to define the `git_server` and related values in an all.yml group_var file.

**Configure local splunk admin password at install**
```
splunk_admin_username: youradminusername (optional, defaults to admin)
splunk_admin_password: yourpassword (required, but see note below about encryption)
```

**Note:** If you do not configure these 2 variables, new Splunk installations will be installed without an admin account present. This has no impact on upgrades to existing installations.

**Configure splunk admin password for existing installations**
We recommend that the `splunk_admin_username` (if not using "admin) and `splunk_admin_password` variables be configured in either group_vars or host_vars. If you use the same username and/or password across your deployment, then an `all.yml` group_vars file is a great location. If you have different passwords for different hosts, then place these variables in a corresponding group_vars or host_vars file. You can then encrypt the password to use in-line with other unencrypted variables by using the following command: `ansible-vault encrypt_string --ask-vault-pass 'var_value_to_encrypt' --name 'splunk_admin_password'`. Once that is done, use either the `--ask-vault-pass` or `--vault-password-file` argument when running the playbook to have Ansible automatically decrypt the value for the play to use.

#### Playbooks
The following example playbooks have been included in this project for your reference:
- **splunk_app_install.yml** - Install or upgrade apps on Splunk hosts using the configure_apps.yml task in the splunk role. Note that the apps you want to deploy should be defined in either host_vars or group_vars, along with a splunk_app_deploy_path. Refer to the documentation for app deployment for details.
- **splunk_install_or_upgrade.yml** - Install or upgrade Splunk (or Splunk UFs) on hosts using the check_splunk.yml task in the splunk role.
- **splunk_shc_deploy.yml** - Installs Splunk and initializes search head clustering on a shdeployer and group of hosts that will serve as a new search head cluster.
- **splunk_upgrade_full_stack.yml** - Example playbook that demonstrates how to upgrade an entire Splunk deployment with a single-site indexer cluster and a search head cluster using the splunk role. Note: This playbook does not upgrade forwarders, although you could easily add an extra play to do that.

## Extended Documentation
This section contains additional reference documentation.
----
#### Task File Descriptions

- **add_crashlog_script.yml** - Installs a bash script and cron job that will automatically clean-up splunkd crash log files. By default, every night at midnight, it will find any crash logs that are more than 7 days old and will delete them. You may change how many days of crash logs are retained by editing the cleanup_crashlogs.sh.j2 template.
- **add_diag_script.yml** - Installs a bash script and cron job that will automatically clean-up splunk diag files. By default, every night at midnight, it will find any diags that are more than 30 days old and will delete them. You may change how many days of splunk diags are retained by editing the cleanup_diags.sh.j2 template.
- **add_pstack_script.yml** - Copies the genpstacks.sh script to $SPLUNK_HOME/genpstacks.sh. This file is useful to have on all of your Splunk servers for when Splunk Support asks you to capture pstacks.

Note: Any task with an **adhoc** prefix means that it can be used independently as a `deployment_task` in a playbook. You can use the tasks to resolve various Splunk problems or perform one-time activities, such as decommissioning an indexer from an indexer cluster.

- **adhoc_clean_dispatch.yml** - This task is intended to be used for restoring service to search heads should the dispatch directory become full. You should need to use this task in a healthy environment, but it is at your disposal should the need arise. The task will stop splunk, remove all files in the dispatch directory, and then start splunk.
- **adhoc_configure_hostname** - Configure a Splunk server's hostname using the value from inventory_hostname. It configures the system hostname, serverName in server.conf and host in inputs.conf. All Splunk configuration changes are made using the ini_file module, which will preserve any other existing configurations that may exist in server.conf and/or inputs.conf.
- **adhoc_decom_indexer.yml** - Executes a splunk offline --enforce-counts command. This is useful when decommissioning one or more indexers from an indexer cluster.
- **adhoc_fix_mongo.yml** - Use when Splunk is in a stopped state to fix mongodb/kvstore issues. This task ensures that permissions are set correctly on mongo's splunk.key file and deletes mongod.lock if it exists.
- **adhoc_fix_server_certificate.yml** - Use to delete an expired server.pem and generate a new one (default certs). Useful if your server.pem certificate has expired and you are using Splunk's default certificate for splunkd. Note that default certificates present a security risk and that their use should be avoided, if possible.
- **adhoc_kill_splunkd.yml** - Some releases of Splunk have a "feature" that leaves zombie splunkd processes after a 'splunk stop'. Use this task after a 'splunk stop' to make sure that it's really stopped. Useful for upgrades on some of the 7.x releases, and automatically called by the upgrade_splunk.yml task.
- **check_splunk.yml** - Check if Splunk is installed. If Splunk is not installed, it will be installed on the host. If Splunk is already installed, the task will execute a "splunk version" command on the host, and then compare the version and build number of Splunk to the version and build number of the expected version of Splunk. Note that the expected version of Splunk does not need to be statically defined; The expected Splunk version and build are automatically extracted from the value of splunk_package_url_full or splunk_package_url_uf using Jinja regex filters. This task will work for both the Universal Forwarder and full Splunk Enterprise packages. You define which host uses what package by organizing it under the appropriate group ('full' or 'uf') in your Ansible inventory.
- **configure_apps.yml** - This task should be called directly from a playbook in order to deploy apps or configurations (from git repositories) to Splunk hosts. Tip: Add a this task to a playbook after the check_splunk.yml play. Doing so will perform a "install (or upgrade) and deploy apps" run, all in one playbook.
- **configure_authentication.yml** - Uses the template identified by the `splunk_authenticationconf` variable to install an authentication.conf file to $SPLUNK_HOME/etc/system/local/authentication.conf. We are including this task here since Ansible is able to securely deploy an authentication.conf configuration by using ansible-vault to encrypt sensitive values such as the value of the `ad_bind_password` variable. Note: If you are using a common splunk.secret file, you can omit this task and instead use configure_apps.yml to deploy an authentication.conf file from a Git repository containing an authentication.conf app with pre-hashed credentials.
- **configure_bash.yml** - Configures bashrc and bash_profile files for the splunk user. Please note that the templates included with this role will overwrite any existing files for the splunk user (if they exist). The templates will define a custom PS1 at the bash prompt, configure the $SPLUNK_HOME environment variable so that you can issue "splunk <command>" without specifying the full path to the Splunk binary, and will enable auto-completion of Splunk CLI commands in bash.
- **configure_deploymentclient.yml** - Generates a new deploymentclient.conf file from the deploymentclient.conf.j2 template and installs it to $SPLUNK_HOME/etc/system/local/deploymentclient.conf. This task is included automatically during new installations when values have been configured for the `clientName` and `splunk_uri_ds` variables.
- **configure_facl.yml** - Configure file system access control lists (FACLs) to allow the splunk user to read /var/log files and add the splunk user's group to /etc/audit/auditd.conf to read /var/log/audit/ directory. This allows the splunk user to read privileged files from a non-privileged system account. Note: This task is performed automatically during new installations when splunk is installed as a non-root user.
- **configure_license.yml** - Configure the license master URI in server.conf for full Splunk installations when `splunk_uri_lm` has been defined. Note: This could also be accomplished using configure_apps.yml with a git repository.
- **configure_os.yml** - Increases ulimits for the splunk user and disables Transparent Huge Pages (THP) per Splunk implementation best practices.
- **configure_shc_captain.yml** - Perform a `bootstrap shcluster-captain` using the server list provided in `splunk_shc_uri_list`.
- **configure_shc_deployer.yml** - Configures a Splunk host to act as a search head deployer by configuring the pass4SymmKey contained in `splunk_shc_key` and the shcluster_label contained in `splunk_shc_label`.
- **configure_shc_members.yml** - Initializes search head clustering on Splunk hosts that will be participating in a new search head cluster. Relies on the values of: `splunk_shc_key`, `splunk_shc_label`, `splunk_shc_deployer`, `splunk_shc_rf`, `splunk_shc_rep_port`, `splunkd_port`, `splunk_admin_username`, and `splunk_admin_password`. Be sure to review the default values for the role for these and configure them appropriately in your group_vars.
- **configure_splunk_forwarder_meta.yml** - Configures a new indexed field called splunk_forwarder and sets its default value to the value of `ansible_hostname`. Note that you will need to install a fields.conf on your search head(s) if you wish to use this custom indexed field.
- **configure_splunk_boot.yml** - Used during installation to automatically configure splunk boot-start to the desired state. This task can also be used to enable boot-start on an existing host that does not have it enabled, or to switch from init.d to systemd, or vice-versa. The desired boot-start method is determined using the boolean value of `splunk_use_initd` (true=initd, false=systemd).
- **configure_splunk_secret.yml** - Configures a common splunk.secret file from the files/authentication/splunk.secret so that pre-hashed passwords can be securely deployed. Note that changing splunk.secret will require re-encryption of any passwords that were encrypted using the previous splunk.secret since Splunk will no longer be able to decrypt them successfully.
- **configure_systemd.yml** - Updates Splunk's systemd file using best practices and tips from the community. Also allows Splunk to start successfully using systemd after an upgrade without the need to run `splunk ftr --accept-license`.
- **configure_thp.yml** - Installs a new systemd service (disable-thp) that disables THP for RedHat|CentOS systems 6.0+. This task is automatically called by the configure_os.yml task.
- **download_and_unarchive.yml** - Downloads the appropriate Splunk package to the Ansible host using `splunk_package_url` (derived automatically from the values of `splunk_package_url_full` or `splunk_package_url_uf` variables). The package is then installed to `splunk_install_path` (derived automatically in main.yml using the `splunk_install_path` and the host's membership of either a `uf` or `full` group in the inventory).
- **install_apps.yml** -  *Do not call install_apps.yml directly! Use configure_apps.yml* - Called by configure_apps.yml to perform app installation on the Splunk host.
- **install_splunk.yml** - *Do not call install_splunk.yml directly! Use check_splunk.yml* - Called by check_splunk.yml to install/upgrade Splunk and Splunk Universal Forwarders, as well as perform any initial configurations. This task is called by check_splunk.yml when the check determines that Splunk is not currently installed. This task will create the splunk user and splunk group, configure the bash profile for the splunk user (by calling configure_bash.yml), configure THP and ulimits (by calling configure_os.ym), download and install the appropriate Splunk package (by calling download_and_unarchive.yml), configure a common splunk.secret (by calling configure_splunk_secret.yml, if configure_secret is defined), create a deploymentclient.conf file with the splunk_ds_uri and clientName (by calling configure_deploymentclient.yml, if clientName is defined), install a user-seed.conf with a prehashed admin password (if used_seed is defined), and will then call the post_install.yml task. See post_install.yml entry for details on post-installation tasks.
- **install_utilities.yml** - Installs Linux packages that are useful for troubleshooting Splunk-related issues when `install_utilities: true` and `linux_packages` is defined with a list of packages to install.
- **main.yml** - This is the main task that will always be called when executing this role. This task sets the appropriate variables for full vs uf packages, sends a Slack notification about the play if the slack_token and slack_channel are defined, checks the current boot-start configuration to determine if it's in the expected state, and then includes the task from the role to execute against, as defined by the value of the deployment_task variable. The deployment_task variable should be defined in your playbook(s). Refer to the included example playbooks to see this in action.
- **post_install.yml** - Executes post-installation tasks. Performs a touch on the .ui_login file which disables the first-time login prompt to change your password, ensures that `splunk_home` is owned by the correct user and group, and optionally configures three scripts to: cleanup crash logs and old diags (by calling add_crashlog_script.yml and add_diag_script.yml, respectively), and a pstack generation shell script for troubleshooting purposes (by calling add_pstack_script.yml). This task will install various Linux troubleshooting utilities (by calling install_utilities.yml) when `install_utilities: true`.
- **set_maintenance_mode.yml** - Enables or disables maintenance mode on a cluster master. Intended to be called by playbooks for indexer cluster upgrades/maintenance. Requires the `state` variable to be defined. Valid values: enabled, disabled
- **set_upgrade_state.yml** - Executes a splunk upgrade-{{ peer_state }} cluster-peers command on the cluster master. This task can be used for upgrading indexer clusters with new minor and maintenance releases of Splunk (assuming you are at Splunk v7.1.0 or higher). Refer to https://docs.splunk.com/Documentation/Splunk/latest/Indexer/Searchablerollingupgrade for more information.
- **splunk_offline.yml** - Runs a splunk offline CLI command. Useful for bringing down indexers non-intrusively by allowing searches to complete before stopping splunk.
- **splunk_restart.yml**  - Restarts splunk via the service module. Used when waiting for a handler to run at the end of the play would be inappropriate.
- **splunk_start.yml** - Starts splunk via the service module. Used when waiting for a handler to run at the end of the play would be inappropriate.
- **splunk_stop.yml** - Stops splunk via the service module.  Used when waiting for a handler to run at the end of the play would be inappropriate.
- **upgrade_splunk.yml** -  *Do not call upgrade_splunk.yml directly! Use check_splunk.yml* - Called by check_splunk.yml. Performs an upgrade of an existing splunk installation. Configures .bash_profile and .bashrc for splunk user (by calling configure_bash.yml), disables THP and increases ulimits (by calling configure_os.yml), kills any stale splunkd processes present (by calling adhoc_kill_splunkd.yml). Note: You should NOT run the upgrade_splunk.yml task directly from a playbook. check_splunk.yml will call upgrade_splunk.yml if it determines that an upgrade is needed; It will then download and unarchive the new version of Splunk (by calling download_and_unarchive.yml), ensure that mongod is in a good stopped state (by calling adhoc_fix_mongo.yml), and will then perform post-installation tasks using the post_install.yml task.

## Frequently Asked Questions
**Q:** What is the difference between this and splunk-ansible?

**A:** The splunk-ansible project was built for the docker-splunk project, which is a completely different use case. The way that docker-splunk works is by spinning-up an image that already has splunk-ansible inside of it, and then any arguments provided to Docker are passed into splunk-ansible so that it can run locally inside of the container to install and configure Splunk there. While it's a cool use case, we didn't feel that splunk-ansible met our needs as Splunk administrators to manage production Splunk deployments, so we wrote our own.
##

**Q:** When using configure_apps.yml, the play fails on the synchronize module. What gives?

**A:** This is due to a [known Ansible bug](https://github.com/ansible/ansible/issues/56629) related to password-based authentication. To workaround this issue, use a key pair for SSH authentication instead by setting the `ansible_user` and `ansible_ssh_private_key_file` variables.
##

## Support
If you have questions or need support, you can:

* Use the [GitHub issue tracker](https://github.com/splunk/splunk-ansible/issues) to submit bugs or request features.
* Post a question to [Splunk Answers](http://answers.splunk.com).
* Join the #ansible channel on [Splunk-Usergroups Slack](https://docs.splunk.com/Documentation/Community/1.0/community/Chat#Join_us_on_Slack).
* Please do not file cases in the Splunk support portal related to this project, as they will not be able to help you.

## License
Copyright 2018-2021 Splunk.

Distributed under the terms of the Apache 2.0 license, ansible-role-for-splunk is free and open-source software.
