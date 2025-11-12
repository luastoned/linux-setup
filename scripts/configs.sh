#!/bin/bash

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$SETUP_DIR/assets"

function isWSL {
	grep -q "microsoft" /proc/version
}

echo "===================================================================================================="
echo "== Installing configuration files..."
echo "===================================================================================================="
echo ""

## copy .nanorc
if [ -f "$ASSETS_DIR/.nanorc" ]; then
	echo "Installing .nanorc..."
	cp "$ASSETS_DIR/.nanorc" ~/.nanorc
else
	echo "Warning: .nanorc not found in assets, skipping..."
fi

echo ""
## copy .tmux.conf
if [ -f "$ASSETS_DIR/.tmux.conf" ]; then
	echo "Installing .tmux.conf..."
	cp "$ASSETS_DIR/.tmux.conf" ~/.tmux.conf
else
	echo "Warning: .tmux.conf not found in assets, skipping..."
fi

echo ""
## copy wsl.conf
if isWSL; then
	if [ -f "$ASSETS_DIR/wsl.conf" ]; then
		echo "Installing wsl.conf (WSL detected)..."
		sudo cp "$ASSETS_DIR/wsl.conf" /etc/wsl.conf
	else
		echo "Warning: wsl.conf not found in assets, skipping..."
	fi
else
	echo "Non-WSL environment detected, skipping wsl.conf"
fi

echo ""
echo "===================================================================================================="
echo "== Configuration files installation complete!"
echo "===================================================================================================="
