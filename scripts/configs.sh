#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

function installUserConfig {
	local sourceFile="$1"
	local targetFile="$2"
	local label="$3"

	if [ ! -f "$sourceFile" ]; then
		echo "Warning: $label not found in assets, skipping..."
		return 0
	fi

	installUserFile "$sourceFile" "$targetFile" 0644 "$label"
}

function installSystemConfig {
	local sourceFile="$1"
	local targetFile="$2"
	local label="$3"

	if [ ! -f "$sourceFile" ]; then
		echo "Warning: $label not found in assets, skipping..."
		return 0
	fi

	installSystemFile "$sourceFile" "$targetFile" 0644 "$label"
}

printBanner "Installing configuration files ..."
blankLine

installUserConfig "$LINUX_SETUP_ASSETS_DIR/.nanorc" "$HOME/.nanorc" ".nanorc"

blankLine
installUserConfig "$LINUX_SETUP_ASSETS_DIR/.tmux.conf" "$HOME/.tmux.conf" ".tmux.conf"

blankLine
if isWSL; then
	installSystemConfig "$LINUX_SETUP_ASSETS_DIR/wsl.conf" /etc/wsl.conf "wsl.conf"
else
	echo "Non-WSL environment detected, skipping wsl.conf"
fi

blankLine
printBanner "Configuration files installation complete!"
