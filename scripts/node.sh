#!/bin/bash

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$(dirname "$SCRIPT_DIR")"

echo "===================================================================================================="
echo "== Installing Node.js (via NVM)..."
echo "===================================================================================================="
echo ""

function isCommand() {
	command -v "$1" >/dev/null 2>&1
}

function sourceNVM() {
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}

## dependencies
echo "Installing dependencies..."
sudo apt install jq -y

echo ""
# Install nvm if not present
if ! isCommand nvm; then
	echo "Installing NVM..."
	NVM_VERSION="$(curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq --raw-output '.tag_name')"
	curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
else
	echo "NVM is already installed"
fi

# Source nvm to make it available in this script
sourceNVM

echo ""
echo "===================================================================================================="
echo "== NVM installation complete!"
echo "===================================================================================================="
echo ""

if ! isCommand node; then
	echo "To install Node.js, run:"
	echo "  source ~/.bashrc"
	echo "  nvm install --lts"
	echo "  nvm use --lts"
else
	echo "Node.js is already installed: $(node --version)"
fi

echo ""

if ! isCommand yarn; then
	echo "To install Yarn, run:"
	echo "  corepack enable"
	echo "  yarn set version berry"
else
	echo "Yarn is already installed: $(yarn --version)"
fi

echo ""
echo "===================================================================================================="
