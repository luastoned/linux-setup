#!/bin/bash

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINUX_SETUP_DIR="$SETUP_DIR"
# shellcheck source=lib/common.sh
source "$SETUP_DIR/lib/common.sh"

SCRIPT_DIR="$LINUX_SETUP_SCRIPTS_DIR"

cd "$SETUP_DIR"

function printUsage {
	cat <<EOF
Usage: ./setup.sh [options]

Options:
  -y, --yes          Run the default selection without prompts.
  -f, --force        Alias for --yes.
      --dry-run      Show selected modules without running them.
      --only LIST    Run only the comma-separated modules in LIST.
      --skip LIST    Skip the comma-separated modules in LIST.
  -h, --help         Show this help message.

Modules:
  update, bashrc, docker, node, utilities, configs, inotify, nginx, k3d, ssh-keys

Examples:
  ./setup.sh
  ./setup.sh --yes
  ./setup.sh --dry-run
  ./setup.sh --only docker,node
  ./setup.sh --skip bashrc,nginx
EOF
}

function normalizeModule {
	case "$1" in
	update) printf '%s\n' "update" ;;
	bashrc | shell) printf '%s\n' "bashrc" ;;
	docker) printf '%s\n' "docker" ;;
	node | nodejs) printf '%s\n' "node" ;;
	utilities | utils) printf '%s\n' "utilities" ;;
	configs | config) printf '%s\n' "configs" ;;
	inotify) printf '%s\n' "inotify" ;;
	nginx | stop-nginx) printf '%s\n' "nginx" ;;
	k3d | kubernetes | k8s) printf '%s\n' "k3d" ;;
	ssh | ssh-key | ssh-keys | sshkeys) printf '%s\n' "ssh-keys" ;;
	*) return 1 ;;
	esac
}

function moduleScript {
	case "$1" in
	update) printf '%s\n' "$SCRIPT_DIR/update.sh" ;;
	bashrc) printf '%s\n' "$SCRIPT_DIR/bashrc.sh" ;;
	docker) printf '%s\n' "$SCRIPT_DIR/docker.sh" ;;
	node) printf '%s\n' "$SCRIPT_DIR/node.sh" ;;
	utilities) printf '%s\n' "$SCRIPT_DIR/utilities.sh" ;;
	configs) printf '%s\n' "$SCRIPT_DIR/configs.sh" ;;
	inotify) printf '%s\n' "$SCRIPT_DIR/inotify.sh" ;;
	nginx) printf '%s\n' "$SCRIPT_DIR/stop-nginx.sh" ;;
	k3d) printf '%s\n' "$SCRIPT_DIR/k3d.sh" ;;
	ssh-keys) printf '%s\n' "$SCRIPT_DIR/ssh-keys.sh" ;;
	*) return 1 ;;
	esac
}

function moduleDescription {
	case "$1" in
	update) printf '%s\n' "System update and upgrade" ;;
	bashrc) printf '%s\n' "Bash configuration" ;;
	docker) printf '%s\n' "Docker" ;;
	node) printf '%s\n' "Node.js and Yarn" ;;
	utilities) printf '%s\n' "Common utilities" ;;
	configs) printf '%s\n' "Nano, tmux, and WSL configs" ;;
	inotify) printf '%s\n' "Inotify limits" ;;
	nginx) printf '%s\n' "Stop and disable nginx" ;;
	k3d) printf '%s\n' "Kubernetes tools" ;;
	ssh-keys) printf '%s\n' "SSH authorized keys" ;;
	*) return 1 ;;
	esac
}

function enableModule {
	local module="$1"
	runModules["$module"]=1
}

function disableModule {
	local module="$1"
	runModules["$module"]=0
}

function setAllModules {
	local value="$1"
	local module

	for module in "${MODULES[@]}"; do
		runModules["$module"]="$value"
	done
}

function applyModuleList {
	local action="$1"
	local rawList="$2"
	local applied=0
	local rawModule
	local module
	local parsedModules

	IFS=',' read -r -a parsedModules <<<"$rawList"
	for rawModule in "${parsedModules[@]}"; do
		rawModule="${rawModule//[[:space:]]/}"
		[ -n "$rawModule" ] || continue

		if ! module="$(normalizeModule "$rawModule")"; then
			echo "Unknown module: $rawModule" >&2
			echo "" >&2
			printUsage >&2
			exit 1
		fi

		case "$action" in
		enable) enableModule "$module" ;;
		disable) disableModule "$module" ;;
		esac
		applied=1
	done

	if [[ "$applied" == 0 ]]; then
		echo "Module list cannot be empty" >&2
		echo "" >&2
		printUsage >&2
		exit 1
	fi
}

function isModuleEnabled {
	[[ "${runModules[$1]}" == 1 ]]
}

function printModuleSummary {
	local module
	local script

	echo "Selected setup modules:"
	for module in "${MODULES[@]}"; do
		if isModuleEnabled "$module"; then
			script="$(moduleScript "$module")"
			printf '  - %-10s %s (%s)\n' "$module" "$(moduleDescription "$module")" "$script"
		fi
	done
}

function runModule {
	local module="$1"
	local script

	script="$(moduleScript "$module")"
	if [[ "$dryRun" == 1 ]]; then
		printf '[dry-run] /bin/bash %q\n' "$script"
	else
		/bin/bash "$script"
	fi
}

# Helper function for yes/no prompts (default yes)
function promptYesDefault {
	local prompt="$1"
	read -r -p "$prompt (Y/n) "
	[[ ! $REPLY =~ ^[Nn]$ ]]
}

# Helper function for yes/no prompts (default no)
function promptNoDefault {
	local prompt="$1"
	read -r -p "$prompt (y/N) "
	[[ $REPLY =~ ^[Yy]$ ]]
}

function promptModuleYesDefault {
	local prompt="$1"
	local module="$2"

	if promptYesDefault "$prompt"; then
		enableModule "$module"
	else
		disableModule "$module"
	fi
}

function promptModuleNoDefault {
	local prompt="$1"
	local module="$2"

	if promptNoDefault "$prompt"; then
		enableModule "$module"
	else
		disableModule "$module"
	fi
}

MODULES=(update bashrc docker node utilities configs inotify nginx k3d ssh-keys)
declare -A runModules=(
	[update]=1
	[bashrc]=1
	[docker]=1
	[node]=1
	[utilities]=1
	[configs]=1
	[inotify]=1
	[nginx]=0
	[k3d]=0
	["ssh-keys"]=0
)

skipQuestions=0
dryRun=0
onlyList=""
skipList=""

while [[ $# -gt 0 ]]; do
	case "$1" in
	-y | --yes | -f | --force)
		skipQuestions=1
		shift
		;;
	--dry-run)
		dryRun=1
		skipQuestions=1
		shift
		;;
	--only)
		[ "${2:-}" ] || {
			echo "--only requires a comma-separated module list" >&2
			exit 1
		}
		onlyList="$2"
		skipQuestions=1
		shift 2
		;;
	--only=*)
		onlyList="${1#*=}"
		[ -n "$onlyList" ] || {
			echo "--only requires a comma-separated module list" >&2
			exit 1
		}
		skipQuestions=1
		shift
		;;
	--skip)
		[ "${2:-}" ] || {
			echo "--skip requires a comma-separated module list" >&2
			exit 1
		}
		skipList="$2"
		skipQuestions=1
		shift 2
		;;
	--skip=*)
		skipList="${1#*=}"
		[ -n "$skipList" ] || {
			echo "--skip requires a comma-separated module list" >&2
			exit 1
		}
		skipQuestions=1
		shift
		;;
	-h | --help)
		printUsage
		exit 0
		;;
	*)
		echo "Unknown option: $1" >&2
		echo "" >&2
		printUsage >&2
		exit 1
		;;
	esac
done

if [ -n "$onlyList" ]; then
	setAllModules 0
	applyModuleList enable "$onlyList"
fi

if [ -n "$skipList" ]; then
	applyModuleList disable "$skipList"
fi

LINUX_DESCRIPTION="$(linuxDescription)"
LINUX_CODENAME="$(linuxCodename)"
KERNEL_VERSION=$(uname -r)

printBanner "Linux Setup: $LINUX_DESCRIPTION, Codename: $LINUX_CODENAME, Kernel: $KERNEL_VERSION"
blankLine

# Interactive prompts
if [[ "$skipQuestions" == 0 ]]; then
	echo "Skip questions with -y, --yes, -f, or --force"
	echo ""

	promptModuleYesDefault "Run apt update and upgrade?" update
	promptModuleYesDefault "Install .bashrc?" bashrc
	promptModuleYesDefault "Install Docker?" docker
	promptModuleYesDefault "Install Node & Yarn?" node
	promptModuleYesDefault "Install Utilities (git, curl, tmux, ...)?" utilities
	promptModuleNoDefault "Install k3d, kubectl, krew, kubectx, kubens, konfig, helm?" k3d
	promptModuleYesDefault "Update nano / tmux / (wsl) configs?" configs
	promptModuleNoDefault "Stop nginx and nginx service?" nginx
	promptModuleYesDefault "Increase the amount of inotify watchers?" inotify
	promptModuleNoDefault "Copy SSH keys to authorized_keys?" ssh-keys

	blankLine
fi

printModuleSummary
blankLine

for module in "${MODULES[@]}"; do
	isModuleEnabled "$module" && runModule "$module"
done

blankLine
if [[ "$dryRun" == 1 ]]; then
	printBanner "Dry run complete!"
else
	printBanner "Setup complete!"
fi
