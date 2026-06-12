# splunk_apps - app deployment and removal

`deployment_task: configure_apps.yml` runs [resolve](../configure_apps.yml#L2) ->
[deploy](../configure_apps.yml#L5) -> [remove](../configure_apps.yml#L9) ->
[flush handlers](../configure_apps.yml#L13). configure_apps.yml is the only
entrypoint; the files in this directory are internal.

## Configuring apps

```yaml
apps:
  - name: my_app                       # bare app id; for git apps, also the repo name
    download_app_source: git           # git or s3
    splunk_app_deploy_path: etc/apps   # optional per-app override
```

- git apps use `git_server`, `git_project`, `git_key`, `git_version` (global or
  per app). `app_relative_path` deploys a repository sub-directory under its own
  name; a single trailing slash deploys every top-level directory in the repo.
- S3 apps use `splunk_app_s3_bucket` (per-app `bucket` override) and
  `splunk_app_s3_bucket_prefix`. Objects live at
  `<prefix>/<app_id>/<version>/<tarball>` with a quoted per-app `version`, or an
  exact `s3_object` key deploys the archive's own top-level directory.
  Set both `s3_access_key_id` and `s3_secret_access_key`, or omit both to use
  the controller's IAM role / credential chain. Requires the `amazon.aws`
  collection and `boto3`/`botocore` on the controller.
- Deploy paths default by group via `splunk_app_group_path_map`; handlers per
  path come from `splunk_app_path_registry`, with `restart splunk` for unlisted
  paths.

## Removing apps

```yaml
splunk_apps_to_remove:
  - name: old_app
    splunk_app_deploy_path: etc/apps   # optional; defaults like deployments, must be an apps dir under etc/
```

Runs after deployment, refuses names the same run deploys or stages, checks SHC
readiness for `etc/shcluster/apps`, and notifies the path's handler. On a
deployment server, remove the app from `serverclass.conf` first.

## Behavior notes

- The whole plan is validated before any change; the play fails on: unconfigured
  git settings, `apps` and `git_apps` both defined, non-string or unquoted
  `version` values, invalid app names or deploy paths, duplicate name+path
  pairs, one deploy path nested under another, and invalid removal entries.
  Earlier releases skipped silently in several of these cases.
- Deployment never deletes apps it did not stage in the same run; dropping an
  entry leaves the app on the target until listed in `splunk_apps_to_remove`.
- `--check` performs the controller-side staging and dry-runs all target
  changes.

## Flow

- [resolve.yml](resolve.yml) - builds one fully-resolved entry per app
  ([plan](resolve.yml#L36), per-entry work dirs) and validates
  [entries](resolve.yml#L20), [deploy paths](resolve.yml#L59),
  [git](resolve.yml#L71) and [S3](resolve.yml#L89) requirements,
  [plan conflicts](resolve.yml#L105), and [removals](resolve.yml#L136).
- [deploy.yml](deploy.yml#L2) - stages then installs; `always:` removes the
  staging directory.
- [stage.yml](stage.yml) - creates the [staging trees](stage.yml#L2), includes
  [fetch_git.yml once for all git apps](stage.yml#L12) and
  [fetch_s3.yml per S3 app](stage.yml#L16), and stages the
  [rsync filter](stage.yml#L22).
- [fetch_git.yml](fetch_git.yml) - runs
  [concurrent git clones](fetch_git.yml#L2), [waits for them](fetch_git.yml#L20),
  [retries failures serially](fetch_git.yml#L35), and
  [places each app](fetch_git.yml#L54) into its destination staging tree.
- [fetch_s3.yml](fetch_s3.yml) - [lists the convention prefix](fetch_s3.yml#L2),
  [downloads](fetch_s3.yml#L37) and [extracts](fetch_s3.yml#L49) the archive,
  validates the extracted directory ([exactly one](fetch_s3.yml#L67),
  [name match](fetch_s3.yml#L74) or [valid app id](fetch_s3.yml#L82),
  [no staging collision](fetch_s3.yml#L100)), and
  [places it](fetch_s3.yml#L107).
- [install.yml](install.yml) - installs [rsync](install.yml#L2), fixes
  [requiretty](install.yml#L9), runs
  [one batched install per destination](install.yml#L23), and sets
  [ownership](install.yml#L32).
- [install_apps.yml](install_apps.yml) - gates on
  [SHC readiness](install_apps.yml#L2), builds the
  [manifest from the staged tree](install_apps.yml#L6), warns about
  [undeployable staged entries](install_apps.yml#L23), and
  [synchronizes](install_apps.yml#L49) the manifest with the staged filter
  applied as a global merge, notifying the path's handler.
- [remove_apps.yml](remove_apps.yml) - [refuses conflicts](remove_apps.yml#L2),
  [gates SHC paths](remove_apps.yml#L13), and
  [removes and notifies](remove_apps.yml#L21).
