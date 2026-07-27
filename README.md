<h1 align="center">
  <br>
  🐧 linux-setup
  <br>
</h1>

<h4 align="center">Opinionated Ubuntu and WSL bootstrap scripts for development machines</h4>

<p align="center">
  <a href="./LICENSE" target="_blank">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square" alt="License">
  </a>
  <a href="https://github.com/luastoned/linux-setup" target="_blank">
    <img src="https://img.shields.io/badge/platform-Ubuntu%20%7C%20WSL-success.svg?style=flat-square" alt="Ubuntu and WSL">
  </a>
  <a href="https://github.com/luastoned/linux-setup" target="_blank">
    <img src="https://img.shields.io/badge/shell-Bash-blueviolet.svg?style=flat-square" alt="Bash">
  </a>
</p>

<p align="center">
  <a href="#-features">Features</a> •
  <a href="#-install">Install</a> •
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-modules">Modules</a> •
  <a href="#-utilities">Utilities</a> •
  <a href="#-safety-notes">Safety Notes</a>
</p>

<br>

## ✨ Features

- 🚀 **One-command bootstrap** — Run an interactive setup flow for a fresh Ubuntu or WSL development environment.
- 🧰 **Common developer tooling** — Install Docker, Node.js via NVM, optional Nub, CLI utilities, shell helpers, and optional Kubernetes tools.
- 🖥️ **Shell-first workflow** — Source a managed dev shell file from `~/.bashrc`, load `bash-completion`, and use generated completions from `~/.config`.
- 🐳 **Docker defaults** — Install Docker CE on non-WSL systems and configure JSON log rotation.
- 🪟 **WSL aware** — Skip native Docker installation under WSL and install WSL-specific config only when WSL is detected.
- 🔧 **Composable scripts** — Run the full installer or execute individual setup modules directly.

## 📦 Install

Clone the repository somewhere stable:

```bash
git clone https://github.com/luastoned/linux-setup.git
cd linux-setup
```

The scripts target Ubuntu-based Linux distributions and Ubuntu on WSL. They
expect Bash and `sudo` access for package installs and system configuration.

## 🚀 Quick Start

Run the interactive installer:

```bash
./setup.sh
```

The installer asks which setup steps to run before applying changes.

To skip prompts and use the default selection:

```bash
./setup.sh --yes
```

`--force` is kept as an alias for `--yes`. The default selection runs most setup
steps, while Nub, nginx disabling, Kubernetes tools, and SSH key installation
remain disabled unless selected interactively.

Preview the selected modules without changing the system:

```bash
./setup.sh --dry-run
```

Run only specific modules:

```bash
./setup.sh --only docker,node
```

Run the default selection except specific modules:

```bash
./setup.sh --skip bashrc,nginx
```

Available module names are `update`, `bashrc`, `docker`, `node`, `nub`,
`utilities`, `configs`, `inotify`, `nginx`, `k3d`, and `ssh-keys`.

## 📚 Modules

The main installer is [`setup.sh`](setup.sh). It orchestrates the setup modules
in `scripts/`.

| Module           | Script                  | Default | Purpose                                                              |
| ---------------- | ----------------------- | ------- | -------------------------------------------------------------------- |
| System update    | `scripts/update.sh`     | Yes     | Run `apt update`, `apt upgrade`, and `apt autoremove`.               |
| Bash config      | `scripts/bashrc.sh`     | Yes     | Back up `~/.bashrc`, install dev shell config, write completions, and manage a source marker. |
| Docker           | `scripts/docker.sh`     | Yes     | Install Docker CE on non-WSL systems and configure log rotation.     |
| Node.js          | `scripts/node.sh`       | Yes     | Install NVM without modifying shell profile files.                   |
| Nub              | `scripts/nub.sh`        | No      | Install the Nub Node.js toolkit without modifying shell profiles.    |
| Utilities        | `scripts/utilities.sh`  | Yes     | Install common CLI tools, 7-Zip, and optional yq and RAR packages.   |
| Config files     | `scripts/configs.sh`    | Yes     | Back up and install nano, tmux, and WSL config files from `assets/`. |
| Inotify limits   | `scripts/inotify.sh`    | Yes     | Raise inotify watcher, instance, and queue limits.                   |
| Nginx disable    | `scripts/stop-nginx.sh` | No      | Stop nginx and disable it from starting on boot.                     |
| Kubernetes tools | `scripts/k3d.sh`        | No      | Install the latest stable kubectl, k3d, krew plugins, and Helm.      |
| SSH keys         | `scripts/ssh-keys.sh`   | No      | Append keys from `assets/.authorized_keys` and update sshd config.   |

Run a single module directly when you only need one part of the setup:

```bash
./scripts/utilities.sh
./scripts/docker.sh
./scripts/node.sh
./scripts/nub.sh
```

NVM remains the conservative default. Nub is an opt-in companion: it can use a
compatible Node already available through NVM, or provision a pinned stock Node
into its own cache when running through `nub`. See the
[Nub Node manager documentation](https://nubjs.com/docs/node). The managed
Node shell asset adds `~/.nub/bin` when present; it also honors Nub's optional
`~/.nub/node-shim` without forcing the shim on NVM users.

## 🧩 Assets

Files in `assets/` are copied into the user or system environment by the setup
scripts.

| Asset                     | Destination                                        |
| ------------------------- | -------------------------------------------------- |
| Managed `assets/dev-shell/*.bash` | `~/.config/dev-shell*.bash`                |
| `assets/dev-shell/dev-shell.local.bash` | Created once as `~/.config/dev-shell.local.bash` |
| `assets/.nanorc`          | `~/.nanorc`                                        |
| `assets/.tmux.conf`       | `~/.tmux.conf`                                     |
| `assets/wsl.conf`         | `/etc/wsl.conf` on WSL                             |
| `assets/.authorized_keys` | Appended to `~/.ssh/authorized_keys`               |
| Generated completions     | Written as `~/.config/dev-shell.*-completion.bash` |
| Optional kube-ps1 prompt  | Written as `~/.config/dev-shell.kube-ps1.sh`       |

`scripts/bashrc.sh` backs up a changed `~/.bashrc` before inserting or updating
the managed linux-setup source block. Changed managed dev-shell files are backed
up as well. The installed `dev-shell.bash` file is a small orchestrator that
sources focused files for history, completions, Git, utilities, Node.js,
Docker, Kubernetes, WSL, Raspberry Pi, prompt, and optional local overrides.

Use the `config` shell alias to edit `~/.config/dev-shell.local.bash`. This file
is created from a commented template only when absent, is sourced last, and is
never overwritten by setup. Put personal aliases, functions, exports, and
prompt changes there instead of editing managed `dev-shell.*.bash` files.

Git completion is handled by the distro `bash-completion` package and its
packaged Git completion file. The dev shell also sources Git's packaged prompt
helper when it is available, so no downloaded Git completion or prompt files are
installed.

## 🗂️ References

Historical and host-side examples live in `references/` and are not installed
by `setup.sh`. This includes legacy complete Bash configurations, the terminal
color test, and the Windows-host `.wslconfig` file.

For WSL, `assets/wsl.conf` configures the Linux guest and is installed to
`/etc/wsl.conf`. To configure the Windows host, manually copy
`references/wsl/.wslconfig` to `%UserProfile%\.wslconfig`.

The guest config is intentionally opinionated: Windows drives mount at `/c`,
the Windows PATH is not appended, systemd is enabled, and the WSL default user
is `root`. Review or remove the `[user]` section before installation if the
distribution's normal non-root default should be preserved. The asset is never
installed on native Ubuntu.

## 🛠️ Utilities

Additional helper scripts live in `utilities/`.

| Script                               | Purpose                                      |
| ------------------------------------ | -------------------------------------------- |
| `utilities/docker-logs-check.sh`     | Show Docker JSON log file sizes.             |
| `utilities/docker-logs-clear.sh`     | Prompt before truncating Docker JSON logs.   |
| `utilities/docker-logs-rotation.sh`  | Write Docker daemon log rotation settings.   |
| `utilities/write-shell-completions.sh` | Generate Bash completions for Docker, kubectl, Helm, and k3d. |
| `utilities/install-kube-ps1.sh`      | Optionally install the jonmosco/kube-ps1 prompt helper when Kubernetes is detected. |
| `utilities/install-snitch.sh`        | Explicitly confirm and run the upstream Snitch installer. |
| `utilities/reset-iptables.sh`        | Confirm and reset iptables rules, with a non-mutating dry run. |
| `utilities/ssh-keygen.sh`            | Generate ED25519, RSA, or both SSH key types. |

Run helpers directly:

```bash
./utilities/ssh-keygen.sh --help
./utilities/docker-logs-rotation.sh
./utilities/install-snitch.sh
./utilities/reset-iptables.sh --dry-run
./utilities/write-shell-completions.sh
```

Docker log helpers use `/var/lib/docker/containers` by default. Override
`DOCKER_CONTAINERS_DIR` for testing or non-standard Docker data roots.
`docker-logs-rotation.sh` writes `/etc/docker/daemon.json` by default and
supports `DOCKER_CONFIG_DIR`, `LOG_MAX_SIZE`, `LOG_MAX_FILE`, and
`DOCKERD_BIN`. It validates candidate JSON, uses `dockerd --validate` when
available, and only creates a backup when content changes. Pass `--restart` to
restart `docker.service`; a failed restart restores the previous config.

Snitch is not part of the default utilities module. Its standalone installer
requires confirmation and warns that the upstream installer does not provide
an independently verified checksum.

Install the optional Kubernetes prompt helper after Kubernetes tooling or a
kubeconfig exists:

```bash
./utilities/install-kube-ps1.sh
```

Use `--force` to install kube-ps1 even when Kubernetes is not detected.
`KUBE_PS1_URL` can override its download source for testing.

For non-applying inotify tests, point `SYSCTL_FILE` at a temporary path and set
`APPLY_SYSCTL=0`. Kubernetes binary destinations can be overridden with
`K3D_INSTALL_DIR` and `HELM_INSTALL_DIR`.

## ⚠️ Safety Notes

This repository is intended for personal development machines. Review the
scripts before running them on shared, production, or security-sensitive hosts.

- Several scripts install packages and write to `/etc`, so they require `sudo`.
- Managed user and system files are compared first. Changed files are copied to
  collision-safe `*.bak.<timestamp>` paths and replacements are staged beside
  the target before an atomic move.
- This backup policy covers Bash/dev-shell assets, nano/tmux/WSL config,
  `authorized_keys`, sshd config, inotify sysctl config, Docker daemon config,
  apt repository/keyring files, kube-ps1, k3d, and Helm.
- `dev-shell.local.bash` is user-owned: setup creates it only when missing and
  never replaces or backs it up.
- Generated completions are reproducible and replaced only when content changes,
  without accumulating backups. Package-managed files and newly created
  tool-owned caches are left to their package or tool manager.
- Intentional destructive utilities, such as Docker log clearing and iptables
  reset, use confirmation instead of backing up potentially large or transient
  state.
- NVM and Nub installers are downloaded to temporary files, syntax checked, and
  prevented from editing shell profiles. Nub's installer verifies its release
  checksum; k3d, krew, and Helm release artifacts are verified before install.
- The utilities module skips optional `yq` and `7zip-rar` packages when they are unavailable from the enabled repositories.
- The SSH key setup merges keys from this repository into `authorized_keys`.
- The optional nginx step disables nginx startup.
- The iptables reset utility flushes firewall rules and requires confirmation unless `--yes` is used.
- Docker installation is skipped automatically on WSL.

## ✅ Development Checks

Basic syntax check:

```bash
bash -n setup.sh scripts/*.sh utilities/*.sh tests/*.sh assets/dev-shell/*.bash lib/common.sh
```

Format check, if `shfmt` is installed:

```bash
shfmt -d setup.sh scripts utilities tests assets/dev-shell/*.bash lib/common.sh
```

Shell linting, if `shellcheck` is installed:

```bash
shellcheck -x setup.sh scripts/*.sh utilities/*.sh tests/*.sh lib/common.sh assets/dev-shell/*.bash
```

Run the non-mutating and temp-path smoke tests:

```bash
./tests/smoke.sh
```

### Ubuntu Container Matrix

Use Docker Compose to run the package installer and repository checks against
the supported Ubuntu LTS releases:

```bash
docker compose run --rm test-22
docker compose run --rm test-24
docker compose run --rm test-26
```

Run the complete matrix sequentially:

```bash
for version in 22 24 26; do
	docker compose run --rm "test-$version"
done
```

Each service bind-mounts the repository read-only and installs packages only
inside its disposable container. The test verifies required `7zip` and optional
`yq`/`7zip-rar` behavior, then runs syntax, formatting, ShellCheck, and smoke
checks.

These containers validate Ubuntu userland and package compatibility. They do
not emulate WSL or validate systemd services, kernel settings, firewall
changes, or a running Docker daemon.

## 📄 License

[MIT](./LICENSE) License © 2024-PRESENT [LuaStoned](https://github.com/luastoned)
