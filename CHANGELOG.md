# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## 2025

- **[Added]** GitHub workflows for linting and changelog enforcement ([#XXX](...)) - 2025-12-17 by @dtwersky
  - Added lint workflow with yamllint, ansible-lint, and newline checks
  - Added changelog enforcement workflow for PRs
  - Enabled new-line-at-end-of-file yamllint rule
- **[Fixed]** fix debian 13 boot start error: version OPENSSL_3.4.0 not found ([#250](https://github.com/splunk/ansible-role-for-splunk/pull/250)) - 2025-12-17 by @dtwersky
  - Accept exit code 8 in boot-start tasks to handle OpenSSL library version mismatch on Debian 13 with Splunk 10.0.2
- **[Added]** new splunkupgrader role for remote upgrader service ([#247](https://github.com/splunk/ansible-role-for-splunk/pull/247)) - 2025-11-03 by @dtwersky
  - Adds new role for Splunk Remote Upgrader for Linux Universal Forwarders service with installation script, systemd configuration, and example playbook
- **[Fixed]** Fix version regex to support double-digit major versions ([#248](https://github.com/splunk/ansible-role-for-splunk/pull/248)) - 2025-10-06 by @patstorm
  - Update version detection regex from `\d\.\d+` to `\d+\.\d+` to correctly match Splunk 10.x releases and prevent unnecessary reinstallations
- **[Added]** New task for creating system images ([#245](https://github.com/splunk/ansible-role-for-splunk/pull/245)) - 2025-08-22 by @dtwersky
  - Adds `clone-prep-clear-config` task to remove auto-generated configurations for VM/container image preparation, organized under new `splunk_common` directory
- **[Changed]** Configure Splunk Launch explicitly to prevent future clobbering ([#232](https://github.com/splunk/ansible-role-for-splunk/pull/232)) - 2025-08-04 by @arcsector
  - Add explicit SPLUNK_DB path configuration in splunk-launch.conf to support custom index storage locations
- **[Added]** add splunk_nix_user to additional groups if defined ([#243](https://github.com/splunk/ansible-role-for-splunk/pull/243)) - 2025-07-29 by @dtwersky
  - Allow Splunk user to be added to additional system groups via new `splunk_nix_user_groups` variable
- **[Changed]** Rhel10 and SELinux compatibility ([#241](https://github.com/splunk/ansible-role-for-splunk/pull/241)) - 2025-07-29 by @observable-it
  - Add SELinux restorecon task before Splunk launch, fix variable include logic for RHEL 10, add RedHat10.yml vars file
- **[Fixed]** fix/logrotate_file may not exists ([#240](https://github.com/splunk/ansible-role-for-splunk/pull/240)) - 2025-07-29 by @fbettocchi
  - Add conditional check for logrotate file existence before setting ACLs
- **[Added]** added option to use ssh key for rsync app install ([#239](https://github.com/splunk/ansible-role-for-splunk/pull/239)) - 2025-05-05 by @dtwersky
  - Add SSH key support for rsync-based app installation method
- **[Fixed]** fix vars to dict ([#236](https://github.com/splunk/ansible-role-for-splunk/pull/236)) - 2025-05-01 by @dtwersky
  - Convert vars from list to dict format in playbooks (remove dash from `vars:` declarations)
- **[Changed]** option to customize splunk linux home directory ([#238](https://github.com/splunk/ansible-role-for-splunk/pull/238)) - 2025-04-30 by @dtwersky
  - Add `splunk_nix_home_dir` variable to customize Splunk user's home directory location
- **[Fixed]** fixed conpatibility with newer ansible version ([#234](https://github.com/splunk/ansible-role-for-splunk/pull/234)) - 2025-03-26 by @dtwersky
  - Fix compatibility issues with newer Ansible versions in playbooks and README
- **[Changed]** linted a few truthy ([#233](https://github.com/splunk/ansible-role-for-splunk/pull/233)) - 2025-03-26 by @dtwersky
  - Fix truthy value linting warnings across defaults and task files
- **[Changed]** do basic linting (indent,fqcn,octals,truthy) ([#229](https://github.com/splunk/ansible-role-for-splunk/pull/229)) - 2025-03-20 by @PerfectlyColouredMoose
  - Add ansible-lint, pre-commit, and yamllint configurations; fix indent, FQCN, octal, and truthy issues across all files
- **[Added]** Closes #230 added splunk_package_arch ([#231](https://github.com/splunk/ansible-role-for-splunk/pull/231)) - 2025-01-20 by @jewnix
  - Add `splunk_package_arch` variable to support custom architecture specification for Splunk packages
- **[Fixed]** fix: Add vars file to support RHEL 9 ([#223](https://github.com/splunk/ansible-role-for-splunk/pull/223)) - 2025-01-13 by @Denney-tech
  - Add RedHat9.yml variables file for RHEL 9 support

## 2024

- **[Security]** added no_log to create user-seed task ([#228](https://github.com/splunk/ansible-role-for-splunk/pull/228)) - 2024-09-03 by @cheskyherskovic
  - Add no_log directive to user-seed configuration task to prevent password logging
- **[Fixed]** fix: 20-splunk.rules.j2 template variable ([#218](https://github.com/splunk/ansible-role-for-splunk/pull/218)) - 2024-08-29 by @zyphermonkey
  - Fix incorrect variable name in auditd rules template that caused undefined variable errors

## 2023

- **[Security]** decrypt secrets even in check_mode ([#213](https://github.com/splunk/ansible-role-for-splunk/pull/213)) - 2023-11-27 by @zyphermonkey
  - Always extract and decrypt secrets in check_mode to avoid false "changed" positives
- **[Added]** add auditd filtering tasks/vars ([#207](https://github.com/splunk/ansible-role-for-splunk/pull/207)) - 2023-11-27 by @zyphermonkey
  - Add auditd configuration tasks and variables with custom filtering rules template
- **[Fixed]** Correct Permissions for splunk.secret file ([#202](https://github.com/splunk/ansible-role-for-splunk/pull/202)) - 2023-09-20 by @schneewe
  - Fix splunk.secret file permissions for proper security
- **[Added]** Add missing variables for Amazon Linux 2 ([#200](https://github.com/splunk/ansible-role-for-splunk/pull/200)) - 2023-09-20 by @lowell80
  - Add missing package variables to Amazon2.yml for Amazon Linux 2 support
- **[Fixed]** Fix small typo in upgrade_splunk.yml ([#190](https://github.com/splunk/ansible-role-for-splunk/pull/190)) - 2023-06-07 by @VatsalJagani
  - Correct typo in upgrade task file
- **[Changed]** install_apps: allow GET to run in check_mode ([#188](https://github.com/splunk/ansible-role-for-splunk/pull/188)) - 2023-06-05 by @zyphermonkey
  - Enable GET operations to run in check_mode for app installation tasks
- **[Fixed]** Shcluster fixes ([#184](https://github.com/splunk/ansible-role-for-splunk/pull/184)) - 2023-05-11 by @jewnix
  - Allow custom mgmt_uri and decrypt shclustering pass4SymmKey value
- **[Changed]** notify restart splunk on all changes in configure_license.yml ([#183](https://github.com/splunk/ansible-role-for-splunk/pull/183)) - 2023-05-11 by @jewnix
  - Add restart notifications for all license configuration changes
- **[Changed]** Extend configure license task ([#182](https://github.com/splunk/ansible-role-for-splunk/pull/182)) - 2023-04-25 by @schneewe
  - Extend license configuration task with additional options and add check_decrypted_secret task
- **[Added]** add possibility to check a decrypted value, before setting a password ([#136](https://github.com/splunk/ansible-role-for-splunk/pull/136)) - 2023-04-03 by @schneewe
  - Add check_decrypted_secret task to verify decrypted values before setting passwords in deployment client
- **[Changed]** rolled back to 9.0.4 ([#179](https://github.com/splunk/ansible-role-for-splunk/pull/179)) - 2023-03-23 by @jewnix
  - Roll back default Splunk version to 9.0.4
- **[Security]** feat(no_log): do not log tasks with secrets ([#175](https://github.com/splunk/ansible-role-for-splunk/pull/175)) - 2023-03-20 by @zyphermonkey
  - Add no_log directives to tasks handling secrets in authentication, deployment client, cluster manager, license, and SHC deployer
- **[Changed]** prevent adhoc_kill_splunkd.yml from running by default when upgrading ([#171](https://github.com/splunk/ansible-role-for-splunk/pull/171)) - 2023-02-10 by @jewnix
  - Add conditional variable to prevent adhoc_kill_splunkd.yml from running by default during upgrades
- **[Fixed]** fix(configure_license): use version_compare ([#172](https://github.com/splunk/ansible-role-for-splunk/pull/172)) - 2023-02-08 by @zyphermonkey
  - Use version_compare filter instead of float comparison for Splunk semantic versioning
- **[Added]** Remove Splunk additions ([#161](https://github.com/splunk/ansible-role-for-splunk/pull/161)) - 2023-02-03 by @arcsector
  - Add comprehensive removal tasks for user/group, THP/ulimit, firewall, and ACL configurations
- **[Security]** Add missing no_log directives ([#166](https://github.com/splunk/ansible-role-for-splunk/pull/166)) - 2023-02-02 by @hampusstrom
  - Add no_log directives to DMC, maintenance mode, and upgrade state tasks
- **[Added]** added splunk_install_type conditional for var population ([#164](https://github.com/splunk/ansible-role-for-splunk/pull/164)) - 2023-01-10 by @jewnix
  - Add conditional variable loading based on splunk_install_type

## 2022

- **[Fixed]** Require acl package. Fix logrotate and auditd ([#160](https://github.com/splunk/ansible-role-for-splunk/pull/160)) - 2022-12-21 by @jewnix
  - Require acl package for setting permissions, add platform-specific logrotate file, fix auditd restart for RedHat, add prereqs.yml to main tasks
- **[Changed]** Simple Firewall Configuration ([#157](https://github.com/splunk/ansible-role-for-splunk/pull/157)) - 2022-12-08 by @arcsector
  - Add firewall configuration using firewalld services and UFW with predefined port/protocol combinations, defaults to UFW for Ubuntu and firewalld for RHEL
- **[Fixed]** Fixed pass4SymmKey variable ([#154](https://github.com/splunk/ansible-role-for-splunk/pull/154)) - 2022-12-01 by @jewnix
  - Fix pass4SymmKey variable reference in license configuration
- **[Fixed]** Reset configure_boot_start var Fixes #150 ([#155](https://github.com/splunk/ansible-role-for-splunk/pull/155)) - 2022-11-30 by @jewnix
  - Reset configure_boot_start variable to prevent unwanted behavior
- **[Fixed]** Fixes splunk/ansible-role-for-splunk#109 ([#152](https://github.com/splunk/ansible-role-for-splunk/pull/152)) - 2022-11-23 by @jewnix
  - Add setfacl to /etc/logrotate.d/syslog configuration
- **[Changed]** reconfigure systemd if splunk was upgraded ([#151](https://github.com/splunk/ansible-role-for-splunk/pull/151)) - 2022-11-22 by @jewnix
  - Reconfigure systemd during Splunk upgrades to handle unit file changes
- **[Added]** Add opensuse ([#149](https://github.com/splunk/ansible-role-for-splunk/pull/149)) - 2022-11-21 by @jewnix
  - Add OpenSUSE support with Suse.yml variables, install acl package for FACL, disable KVStore on UF when upgrading from v8 to v9
- **[Added]** Add amazon linux ([#148](https://github.com/splunk/ansible-role-for-splunk/pull/148)) - 2022-11-21 by @jewnix
  - Add Amazon Linux package support with Amazon2.yml variables
- **[Fixed]** changed thp conditional to ansible_service_manager Fixes splunk/ansible-role-for-splunk#146 ([#147](https://github.com/splunk/ansible-role-for-splunk/pull/147)) - 2022-11-21 by @jewnix
  - Change THP conditional to use ansible_service_manager instead of init system detection
- **[Changed]** only daemon-reload when systemd is available ([#145](https://github.com/splunk/ansible-role-for-splunk/pull/145)) - 2022-11-17 by @jewnix
  - Add conditional to daemon-reload handler to check for systemd availability
- **[Fixed]** Fixed least priv mode ([#144](https://github.com/splunk/ansible-role-for-splunk/pull/144)) - 2022-11-17 by @jewnix
  - Fix least privileged mode by moving variables and post-install tasks to correct order
- **[Added]** forcing usage of luseradd/lgroupadd broke some distros ([#143](https://github.com/splunk/ansible-role-for-splunk/pull/143)) - 2022-11-08 by @jewnix
  - Add variables to allow distro-specific user/group commands instead of forcing lgroupadd/luseradd
- **[Changed]** feat(install_utilities): send list to package module ([#138](https://github.com/splunk/ansible-role-for-splunk/pull/138)) - 2022-11-16 by @zyphermonkey
  - Send package list directly to package module instead of looping, move include_vars to main.yml, split linux_package var by OS, add RHEL 8 specific packages
- **[Removed]** feat(install): remove downloaded package after unarchive ([#134](https://github.com/splunk/ansible-role-for-splunk/pull/134)) - 2022-11-16 by @zyphermonkey
  - Remove downloaded package after unarchive to keep disk clean, allow download on ansible host or remote host
- **[Changed]** Explicit Group Init in Boot Config ([#137](https://github.com/splunk/ansible-role-for-splunk/pull/137)) - 2022-11-08 by @arcsector
  - Include group in boot-start command explicitly
- **[Fixed]** Fixed typo: added 'not' ([#140](https://github.com/splunk/ansible-role-for-splunk/pull/140)) - 2022-10-24 by @technimad
  - Fix typo in README by adding missing 'not'
- **[Changed]** Explicitly configure Splunk Group and User locally ([#133](https://github.com/splunk/ansible-role-for-splunk/pull/133)) - 2022-10-07 by @arcsector
  - Force local user and group creation for Splunk
- **[Fixed]** fixes splunk/ansible-role-for-splunk#49 ([#130](https://github.com/splunk/ansible-role-for-splunk/pull/130)) - 2022-08-24 by @jewnix
  - Add variable for app staging directory path to fix deployment flexibility
- **[Changed]** configure restartSplunkd on serverclass level ([#129](https://github.com/splunk/ansible-role-for-splunk/pull/129)) - 2022-08-23 by @jewnix
  - Add restartSplunkd configuration option at serverclass level in serverclass.conf template
- **[Fixed]** fixewd missing quotes ([#128](https://github.com/splunk/ansible-role-for-splunk/pull/128)) - 2022-08-22 by @jewnix
  - Add missing quotes around variables in conditionals
- **[Changed]** Customize systemd unit file name ([#127](https://github.com/splunk/ansible-role-for-splunk/pull/127)) - 2022-08-19 by @jewnix
  - Add variable to customize systemd unit file name
- **[Added]** Additional OOTB Cluster components ([#125](https://github.com/splunk/ansible-role-for-splunk/pull/125)) - 2022-08-17 by @arcsector
  - Add DMC (Distributed Management Console) playbook and configuration task
- **[Changed]** Multiple updates ([#122](https://github.com/splunk/ansible-role-for-splunk/pull/122)) - 2022-08-17 by @jewnix
  - Add license files to .gitignore, add more license configuration options, disable THP using tuned, add version/build variables, update to 9.0.0.1, fix boot-start issues
- **[Added]** feat: add option to create polkit rules file for splunk ([#115](https://github.com/splunk/ansible-role-for-splunk/pull/115)) - 2022-08-17 by @zyphermonkey
  - Add option to create polkit rules file for Splunk service management
- **[Fixed]** Fixing #123 - indexer vs indexers host group ([#124](https://github.com/splunk/ansible-role-for-splunk/pull/124)) - 2022-08-03 by @arcsector
  - Fix host group name inconsistency between indexer and indexers
- **[Added]** Added sysctl to allow read of dmesg ([#119](https://github.com/splunk/ansible-role-for-splunk/pull/119)) - 2022-06-02 by @jewnix
  - Add sysctl configuration to allow non-root users to read dmesg
- **[Changed]** disable-thp.service should be enabled and started ([#116](https://github.com/splunk/ansible-role-for-splunk/pull/116)) - 2022-03-24 by @jewnix
  - Change disable-thp service to be both enabled and started instead of just started

## 2021

- **[Added]** Add missing .rc to configure_idxc_sh ([#103](https://github.com/splunk/ansible-role-for-splunk/pull/103)) - 2021-09-15 by @mason-splunk
- **[Fixed]** Fix location of configure_idxc_sh.yml ([#101](https://github.com/splunk/ansible-role-for-splunk/pull/101)) - 2021-09-14 by @mason-splunk
- **[Changed]** Multiple updates ([#100](https://github.com/splunk/ansible-role-for-splunk/pull/100)) - 2021-09-14 by @mason-splunk
  - Add general pass4SymmKey configuration to configure_license.yml, fix hardcoded splunk home path, move ulimits to template, update documentation, add new task for joining search head to indexer cluster
- **[Fixed]** Fix race condition during idxc configuration ([#87](https://github.com/splunk/ansible-role-for-splunk/pull/87)) - 2021-08-12 by @mason-splunk
- **[Changed]** Rename clustermaster to clustermanager ([#88](https://github.com/splunk/ansible-role-for-splunk/pull/88)) - 2021-08-12 by @mason-splunk
- **[Fixed]** Fix data type for version check in index cluster tasks ([#86](https://github.com/splunk/ansible-role-for-splunk/pull/86)) - 2021-08-12 by @mason-splunk
- **[Fixed]** Bugfix and serverclass generation ([#84](https://github.com/splunk/ansible-role-for-splunk/pull/84)) - 2021-08-06 by @mason-splunk
- **[Added]** Add my-ds to inventory example ([#85](https://github.com/splunk/ansible-role-for-splunk/pull/85)) - 2021-08-06 by @mason-splunk
- **[Fixed]** Fixed table of contents ([#79](https://github.com/splunk/ansible-role-for-splunk/pull/79)) - 2021-07-16 by @graememeyer
- **[Added]** Add indexer clustering configurations ([#72](https://github.com/splunk/ansible-role-for-splunk/pull/72)) - 2021-05-03 by @pham-man
  - Add example playbook to deploy indexer cluster, update variable names, fix conditional configurations
- **[Fixed]** Fix bug related to start_splunk_handler_fired ([#73](https://github.com/splunk/ansible-role-for-splunk/pull/73)) - 2021-05-03 by @mason-splunk
- **[Fixed]** Refactored how license is accepted/fixed systemd issue and eliminated unnecessary splunk restarts ([#71](https://github.com/splunk/ansible-role-for-splunk/pull/71)) - 2021-04-30 by @mason-splunk
  - Fix unnecessary restart after installation, cleanup systemd task, refactor license accept
- **[Removed]** Removed ExecStop from Systemd file ([#70](https://github.com/splunk/ansible-role-for-splunk/pull/70)) - 2021-04-30 by @mason-splunk
- **[Added]** Add support for phoneHomeIntervalInSecs and deployment pass4SymmKey ([#67](https://github.com/splunk/ansible-role-for-splunk/pull/67)) - 2021-04-29 by @mason-splunk
  - Convert deploymentclient.conf from template to ini_file
- **[Changed]** Update configure_systemd.yml ([#63](https://github.com/splunk/ansible-role-for-splunk/pull/63)) - 2021-04-26 by @ForsetiJan
- **[Added]** Add support for disabling and customizing the splunkd mgmt port ([#61](https://github.com/splunk/ansible-role-for-splunk/pull/61)) - 2021-03-29 by @mason-splunk
- **[Changed]** Update configure_systemd.yml ([#60](https://github.com/splunk/ansible-role-for-splunk/pull/60)) - 2021-03-22 by @ForsetiJan
- **[Changed]** only create ulimits.conf file when using init.d ([#54](https://github.com/splunk/ansible-role-for-splunk/pull/54)) - 2021-03-22 by @jewnix
- **[Removed]** Remove RemainAfterExit which has a default value ([#47](https://github.com/splunk/ansible-role-for-splunk/pull/47)) - 2021-03-05 by @mason-splunk
- **[Fixed]** #27 - Correction of the Idempotency of the tasks ([#44](https://github.com/splunk/ansible-role-for-splunk/pull/44)) - 2021-03-05 by @lmnogues
  - Improved idempotency of various tasks to avoid unnecessary changes
- **[Changed]** Modified conditional handlers for restarting auditd in redhat and non redhat Linux distributions ([#43](https://github.com/splunk/ansible-role-for-splunk/pull/43)) - 2021-03-03 by @arengifoc
- **[Removed]** Remove changed_when from configure_splunk_boot.yml ([#41](https://github.com/splunk/ansible-role-for-splunk/pull/41)) - 2021-03-01 by @mason-splunk
- **[Changed]** Miscellaneous updates ([#38](https://github.com/splunk/ansible-role-for-splunk/pull/38)) - 2021-02-26 by @mason-splunk
  - Add missing company name to LICENSE, add author email to role meta, update README.md, update adhoc_configure_hostname.yml
- **[Added]** Add systemd ulimits settings ([#39](https://github.com/splunk/ansible-role-for-splunk/pull/39)) - 2021-02-26 by @mason-splunk
- **[Fixed]** Fixed the Version parsing of splunk package request url ([#36](https://github.com/splunk/ansible-role-for-splunk/pull/36)) - 2021-02-24 by @schneewe
- **[Fixed]** Fix meta ([#34](https://github.com/splunk/ansible-role-for-splunk/pull/34)) - 2021-02-24 by @mason-splunk
  - Fix error in check_splunk.yml, fix spacing in meta.yml
- **[Changed]** Update meta ([#32](https://github.com/splunk/ansible-role-for-splunk/pull/32)) - 2021-02-24 by @mason-splunk
  - Update role meta, add missing license file, add missed slack task update
- **[Fixed]** Fixed most linting warnings and a bug that was encountered when running Ansible against a host that has Splunk in a stopped state ([#31](https://github.com/splunk/ansible-role-for-splunk/pull/31)) - 2021-02-24 by @mason-splunk
  - Fix bug that causes play failure when splunk is stopped in check_splunk_status.yml, fix linting errors
- **[Changed]** Multiple updates ([#30](https://github.com/splunk/ansible-role-for-splunk/pull/30)) - 2021-02-23 by @mason-splunk
  - Created check_splunk_status.yml, moved status checking to return codes, moved splunk.secret filename to a variable, add retries to shc and idxc bundle apply, add basic support for removing splunk
- **[Fixed]** Squashed another systemd bug related to full installs and added SHC deployment support ([#22](https://github.com/splunk/ansible-role-for-splunk/pull/22)) - 2021-02-23 by @mason-splunk
  - Fixed systemd bug and add basic SHC deployment support
- **[Fixed]** Multiple bugfixes related to init.d, systemd, and app installation. Also updated default WGET URLs. ([#21](https://github.com/splunk/ansible-role-for-splunk/pull/21)) - 2021-02-22 by @mason-splunk
  - Remove systemd handler, update task names, update README and example inventory files, remove conditional for reload systemctl daemon, fail play if unable to clone app repo, fix order of operations in install_apps.yml, add systemd updates, add new handler to update splunk init.d with --accept-license
- **[Fixed]** fix-auditd-and-facls ([#19](https://github.com/splunk/ansible-role-for-splunk/pull/19)) - 2021-02-17 by @arengifoc
  - Refactored ACL task using a loop, fixed auditd restart task, added effective ACLs for /var/log files, fixed splunk_use_initd being compared as string instead of boolean
- **[Fixed]** [SAS-5445] Fix issue #15 and minor cleanup in install_apps.yml ([#16](https://github.com/splunk/ansible-role-for-splunk/pull/16)) - 2021-02-12 by @mason-splunk
- **[Changed]** Improved SHC app deployment process ([#10](https://github.com/splunk/ansible-role-for-splunk/pull/10)) - 2021-02-02 by @mason-splunk
  - Disable logging of REST call, remove extra handler steps, update README.md
- **[Removed]** [SAS-5320] Remove disable boot-start task during uprades ([#8](https://github.com/splunk/ansible-role-for-splunk/pull/8)) - 2021-01-19 by @mason-splunk

## 2020

- **[Fixed]** correcting filenames ([#5](https://github.com/splunk/ansible-role-for-splunk/pull/5)) - 2020-10-21 by @lindeskar
  - Correcting filename for multiple files
- **[Changed]** Readme updates ([#4](https://github.com/splunk/ansible-role-for-splunk/pull/4)) - 2020-10-20 by @mason-splunk
  - Update README.md and fix FAQ formatting
- **[Removed]** Remove old README.md ([#3](https://github.com/splunk/ansible-role-for-splunk/pull/3)) - 2020-10-20 by @mason-splunk
- **[Changed]** First commit ([#2](https://github.com/splunk/ansible-role-for-splunk/pull/2)) - 2020-10-20 by @mason-splunk
- **[Changed]** Update readme ([#1](https://github.com/splunk/ansible-role-for-splunk/pull/1)) - 2020-10-10 by @mason-splunk
