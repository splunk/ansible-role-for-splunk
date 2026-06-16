# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.0] - 2026-06-15

### Added

- S3 app source (`download_app_source: s3`), mixable with git in one run.
- `apps` list as the primary app-declaration variable (`git_apps` still honored).
- Opt-in app removal via `splunk_apps_to_remove`.
- Fail-fast validation of the app and removal plan.
- S3 support depends on the `amazon.aws` collection and `boto3`/`botocore` on the controller.

### Changed

- App tasks restructured into resolve/stage/install/remove phases under `splunk_apps/`.
- Faster deploys: one batched rsync per destination (previously one per app), and
  git apps cloned concurrently during staging instead of serially.
- Git clones default to shallow, single-branch, and non-recursive (`git_depth: 1`,
  `git_single_branch: true`, `git_recursive: false`; each global or per app),
  changing the previous full/recursive clone. For a commit-SHA `git_version` set
  `git_single_branch: false` (and `git_depth: 0`); set `git_recursive: true` for
  submodule repos.
- Deployment never deletes an app it did not stage; dropping an app from a monorepo
  no longer removes it from targets (use `splunk_apps_to_remove`). Previously a
  trailing-slash `app_relative_path` monorepo pruned dropped apps on the next run.

### Security

- rsync invocations hardened so an app definition cannot inject arguments.

[2.2.0]: https://github.com/splunk/ansible-role-for-splunk/compare/v2.1.7...v2.2.0
