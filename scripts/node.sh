#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

# https://nubjs.com/
# curl -fsSL https://nubjs.com/install.sh | bash

printBanner "Installing Node.js (via NVM) ..."
blankLine

function sourceNVM() {
	export NVM_DIR="$HOME/.nvm"
	# shellcheck source=/dev/null
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}

## dependencies
echo "Installing dependencies..."
aptUpdate
installAptPackages curl jq

blankLine
sourceNVM

# Install nvm if not present
if ! commandExists nvm; then
	echo "Installing NVM..."
	NVM_VERSION="$(curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq --raw-output '.tag_name')"
	curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
	sourceNVM
else
	echo "NVM is already installed"
fi

blankLine
printBanner "NVM installation complete!"
blankLine

if ! commandExists node; then
	echo "To install Node.js, run:"
	echo "  source ~/.bashrc"
	echo "  nvm install --lts"
	echo "  nvm use --lts"
else
	echo "Node.js is already installed: $(node --version)"
fi

blankLine

if ! commandExists yarn; then
	echo "To install Yarn, run:"
	echo "  corepack enable"
	echo "  yarn set version berry"
else
	echo "Yarn is already installed: $(yarn --version)"
fi

blankLine
echo "===================================================================================================="
