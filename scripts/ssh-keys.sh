#!/bin/bash

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$SETUP_DIR/assets"

echo "===================================================================================================="
echo "== Installing SSH keys..."
echo "===================================================================================================="
echo ""

## ensure .ssh directory exists
if [[ ! -d "$HOME/.ssh" ]]; then
	echo "Creating .ssh directory..."
	mkdir -p "$HOME/.ssh"
	chmod 700 "$HOME/.ssh"
fi

echo ""
## copy authorized_keys
if [ -f "$ASSETS_DIR/.authorized_keys" ]; then
	echo "Adding authorized keys..."
	cat "$ASSETS_DIR/.authorized_keys" >> "$HOME/.ssh/authorized_keys"
	chmod 600 "$HOME/.ssh/authorized_keys"
	echo "Keys added successfully"
else
	echo "Warning: .authorized_keys not found in assets, skipping..."
fi

echo ""
## patch ssh config
if [ -f /etc/ssh/sshd_config ]; then
	echo "Updating SSH daemon configuration..."
	sudo sed --in-place 's/#AuthorizedKeysFile/AuthorizedKeysFile/' /etc/ssh/sshd_config
	echo "SSH configuration updated"
else
	echo "Warning: /etc/ssh/sshd_config not found, skipping..."
fi

echo ""
echo "===================================================================================================="
echo "== SSH keys installation complete!"
echo "===================================================================================================="
echo ""
echo "To apply SSH configuration changes, restart SSH service:"
echo "  sudo systemctl restart sshd"
echo ""
echo "===================================================================================================="
