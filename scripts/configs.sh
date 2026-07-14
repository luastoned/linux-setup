#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

function installUserConfig {
	local sourceFile="$1"
	local targetFile="$2"
	local label="$3"
	local backupFile

	if [ ! -f "$sourceFile" ]; then
		echo "Warning: $label not found in assets, skipping..."
		return 0
	fi

	if [ -f "$targetFile" ] && cmp -s -- "$sourceFile" "$targetFile"; then
		echo "$label is already up to date"
		return 0
	fi

	if [ -e "$targetFile" ]; then
		backupFile="$targetFile.bak.$(timestamp)"
		echo "Backing up $label to $backupFile..."
		cp -- "$targetFile" "$backupFile"
	fi

	echo "Installing $label..."
	install -m 0644 "$sourceFile" "$targetFile"
}

function installSystemConfig {
	local sourceFile="$1"
	local targetFile="$2"
	local label="$3"
	local backupFile

	if [ ! -f "$sourceFile" ]; then
		echo "Warning: $label not found in assets, skipping..."
		return 0
	fi

	if sudoCommand test -f "$targetFile" && sudoCommand cmp -s -- "$sourceFile" "$targetFile"; then
		echo "$label is already up to date"
		return 0
	fi

	if sudoCommand test -e "$targetFile"; then
		backupFile="$targetFile.bak.$(timestamp)"
		echo "Backing up $label to $backupFile..."
		sudoCommand cp -- "$targetFile" "$backupFile"
	fi

	echo "Installing $label..."
	sudoCommand install -m 0644 "$sourceFile" "$targetFile"
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
