#!/bin/bash

set -euo pipefail

# Get the setup directory and derive scripts directory
SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$SETUP_DIR/scripts"

cd "$SETUP_DIR"

# Display system information
LINUX_VERSION=$(lsb_release -rs)
LINUX_CODENAME=$(lsb_release -cs)
LINUX_DESCRIPTION=$(lsb_release -ds)
KERNEL_VERSION=$(uname -r)

echo "===================================================================================================="
echo "== Linux Setup: $LINUX_DESCRIPTION, Codename: $LINUX_CODENAME, Kernel: $KERNEL_VERSION"
echo "===================================================================================================="
echo ""

# Parse arguments
skipArg=${1:-}
function skipQuestions {
	[[ "$skipArg" == "-f" || "$skipArg" == "--force" ]]
}

# Helper function for yes/no prompts (default yes)
function promptYesDefault {
	local prompt="$1"
	read -p "$prompt (Y/n) " -r
	[[ ! $REPLY =~ ^[Nn]$ ]]
}

# Helper function for yes/no prompts (default no)
function promptNoDefault {
	local prompt="$1"
	read -p "$prompt (y/N) " -r
	[[ $REPLY =~ ^[Yy]$ ]]
}

# Configuration defaults (1 = run, 0 = skip)
# Default YES
runUpdate=1
runBashrc=1
runDocker=1
runNode=1
runUtilities=1
runConfigs=1
runNginx=1
runInotify=1

# Default NO
runK3d=0
runSSHKeys=0

# Interactive prompts
if ! skipQuestions; then
	echo "Skip questions with -f or --force"
	echo ""

	promptYesDefault "Run apt update and upgrade?" && runUpdate=1 || runUpdate=0
	promptYesDefault "Install .bashrc?" && runBashrc=1 || runBashrc=0
	promptYesDefault "Install Docker?" && runDocker=1 || runDocker=0
	promptYesDefault "Install Node & Yarn?" && runNode=1 || runNode=0
	promptYesDefault "Install Utilities (git, curl, tmux, ...)?" && runUtilities=1 || runUtilities=0
	promptNoDefault "Install k3d, kubectl, krew, kubectx, kubens, konfig, helm?" && runK3d=1 || runK3d=0
	promptYesDefault "Update nano / tmux / (wsl) configs?" && runConfigs=1 || runConfigs=0
	promptYesDefault "Stop nginx and nginx service?" && runNginx=1 || runNginx=0
	promptYesDefault "Increase the amount of inotify watchers?" && runInotify=1 || runInotify=0
	promptNoDefault "Copy SSH keys to authorized_keys?" && runSSHKeys=1 || runSSHKeys=0

	echo ""
fi

# Execute scripts based on configuration
[[ $runUpdate == 1 ]] && /bin/bash "$SCRIPT_DIR/update.sh"
[[ $runBashrc == 1 ]] && /bin/bash "$SCRIPT_DIR/bashrc.sh"
[[ $runDocker == 1 ]] && /bin/bash "$SCRIPT_DIR/docker.sh"
[[ $runNode == 1 ]] && /bin/bash "$SCRIPT_DIR/node.sh"
[[ $runUtilities == 1 ]] && /bin/bash "$SCRIPT_DIR/utilities.sh"
[[ $runConfigs == 1 ]] && /bin/bash "$SCRIPT_DIR/configs.sh"
[[ $runInotify == 1 ]] && /bin/bash "$SCRIPT_DIR/inotify.sh"
[[ $runNginx == 1 ]] && /bin/bash "$SCRIPT_DIR/stop-nginx.sh"
[[ $runK3d == 1 ]] && /bin/bash "$SCRIPT_DIR/k3d.sh"
[[ $runSSHKeys == 1 ]] && /bin/bash "$SCRIPT_DIR/ssh-keys.sh"

echo ""
echo "===================================================================================================="
echo "== Setup complete!"
echo "===================================================================================================="
