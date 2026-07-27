#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

AUTHORIZED_KEYS_SOURCE="$LINUX_SETUP_ASSETS_DIR/.authorized_keys"
AUTHORIZED_KEYS_TARGET="$HOME/.ssh/authorized_keys"
SSHD_CONFIG_FILE="${SSHD_CONFIG_FILE:-/etc/ssh/sshd_config}"
SSHD_BIN="${SSHD_BIN:-$(command -v sshd || true)}"
tmpFile=""

function cleanup {
	[ -z "$tmpFile" ] || rm -f -- "$tmpFile"
}

trap cleanup EXIT

function updateSshdConfig {
	if [ -z "$SSHD_BIN" ]; then
		echo "Warning: sshd was not found; skipping SSH daemon configuration update."
		return 0
	fi

	tmpFile="$(mktemp)"
	sudoCommand cp -- "$SSHD_CONFIG_FILE" "$tmpFile"
	sed -E --in-place 's/^([[:space:]]*)#[[:space:]]*(AuthorizedKeysFile[[:space:]].*)$/\1\2/' "$tmpFile"

	if sudoCommand cmp -s -- "$SSHD_CONFIG_FILE" "$tmpFile"; then
		echo "SSH daemon configuration is already up to date"
		rm -f -- "$tmpFile"
		tmpFile=""
		return 0
	fi

	echo "Validating updated SSH daemon configuration..."
	sudoCommand "$SSHD_BIN" -t -f "$tmpFile"

	installSystemFile "$tmpFile" "$SSHD_CONFIG_FILE" 0644 "SSH daemon configuration"

	rm -f -- "$tmpFile"
	tmpFile=""
	echo "SSH configuration updated"
}

printBanner "Installing SSH keys ..."
blankLine

echo "Ensuring .ssh directory exists..."
install -m 0700 -d "$HOME/.ssh"

blankLine
if [ -f "$AUTHORIZED_KEYS_SOURCE" ]; then
	echo "Adding authorized keys ..."
	tmpFile="$(mktemp)"
	if [ -f "$AUTHORIZED_KEYS_TARGET" ]; then
		cp -- "$AUTHORIZED_KEYS_TARGET" "$tmpFile"
	fi

	while IFS= read -r key; do
		[ -n "$key" ] || continue
		if ! grep -qxF "$key" "$tmpFile"; then
			printf '%s\n' "$key" >>"$tmpFile"
		fi
	done <"$AUTHORIZED_KEYS_SOURCE"

	installUserFile "$tmpFile" "$AUTHORIZED_KEYS_TARGET" 0600 "authorized_keys"
	rm -f -- "$tmpFile"
	tmpFile=""
	echo "Keys added successfully"
else
	echo "Warning: .authorized_keys not found in assets, skipping..."
fi

blankLine
if sudoCommand test -f "$SSHD_CONFIG_FILE"; then
	echo "Updating SSH daemon configuration..."
	updateSshdConfig
else
	echo "Warning: $SSHD_CONFIG_FILE not found, skipping..."
fi

blankLine
printBanner "SSH keys installation complete!"
blankLine
echo "To apply SSH configuration changes, restart SSH service:"
echo "  sudo systemctl restart ssh.service"
blankLine
echo "===================================================================================================="
