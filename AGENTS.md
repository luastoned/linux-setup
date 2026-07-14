# AGENTS.md

Guidance for agents working in this repository.

## Repository Shape

- This is a single-project Bash repository for Ubuntu/WSL machine setup.
- `setup.sh` is the root orchestrator for install modules in `scripts/`.
- `scripts/` contains setup modules that may install packages or write system/user config.
- `utilities/` contains focused helper scripts that should be safe to run independently when documented.
- `assets/` contains files copied or sourced by setup scripts; treat these as user-facing shell/config assets, not generated output.
- `references/` contains historical or host-side examples that are not installed by `setup.sh`.
- `tests/` contains temp-path smoke tests that must not mutate the host.

## Working Rules

- Keep changes small, explicit, and consistent with the existing Bash style.
- Preserve the repo's safety posture: prefer dry-run paths, prompts, backups, idempotent writes, and clear output for system changes.
- Do not run setup scripts that install packages, modify `/etc`, truncate logs, alter SSH config, or overwrite user config unless the user explicitly asks.
- When testing system-mutating helpers, use environment overrides and temp paths where available, such as `DOCKER_CONTAINERS_DIR`, `DOCKER_CONFIG_DIR`, `SSHD_CONFIG_FILE`, `SSHD_BIN`, `LOG_MAX_SIZE`, and `LOG_MAX_FILE`.
- Do not reintroduce downloaded Git completion or prompt assets. Git completion/prompt support should use distro-provided `bash-completion` and packaged Git helpers.
- Keep optional Kubernetes prompt support opt-in through `utilities/install-kube-ps1.sh`.

## Shell Guidance

- Repo scripts and utilities are Bash scripts with `#!/bin/bash`, `set -euo pipefail`, and `lib/common.sh` sourced near the top.
- Quote variable expansions unless intentional word splitting is required.
- Use arrays for Bash argument lists, especially command prefixes such as optional `sudo`.
- Prefer `find` or explicit globs over parsing `ls`.
- Use `mktemp` and `trap` cleanup for temporary files.
- Use `--` before user-controlled or path-like values passed to commands that parse options.
- Keep environment-variable contracts near the top of scripts and document useful overrides in the README.
- Prefer generated CLI completions over vendored completion files when the command can produce them.

## Validation

Run the smallest relevant checks for the files touched:

```bash
bash -n setup.sh scripts/*.sh utilities/*.sh tests/*.sh assets/dev-shell/*.bash lib/common.sh
shfmt -d setup.sh scripts utilities tests assets/dev-shell/*.bash lib/common.sh
```

When touching docs or assets only, inspect the rendered Markdown/source and run syntax checks only for changed shell files.

When changing utility behavior, prefer temp-path tests, for example:

```bash
DOCKER_CONTAINERS_DIR=/tmp/linux-setup-log-test ./utilities/docker-logs-check.sh
DOCKER_CONFIG_DIR=/tmp/linux-setup-docker-config ./utilities/docker-logs-rotation.sh
XDG_CONFIG_HOME=/tmp/linux-setup-config ./utilities/write-shell-completions.sh docker
./utilities/reset-iptables.sh --dry-run
./tests/smoke.sh
```

Run `shellcheck -x setup.sh scripts/*.sh utilities/*.sh tests/*.sh lib/common.sh assets/dev-shell/*.bash` when ShellCheck is installed. If a relevant check cannot be run because it would mutate the host or requires unavailable tools/network access, state that in the final response.

## Commits

- Follow Conventional Commits with gitmoji, matching the existing history:
  `<type>[optional scope][optional !]: <gitmoji> <description>`.
- Keep unrelated areas in separate commits when practical, especially root orchestration, setup modules, utilities, and assets.
- Stage deletions of obsolete assets together with the script changes that stop using them.
