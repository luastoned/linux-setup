#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

printBanner "Installing NVM ..."
blankLine

function sourceNVM() {
	export NVM_DIR="$HOME/.nvm"
	# shellcheck source=/dev/null
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}

echo "Installing dependencies..."
aptUpdate
installAptPackages curl jq

blankLine
sourceNVM

# Install nvm if not present
if ! commandExists nvm; then
	echo "Installing NVM..."
	NVM_VERSION="$(curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq --raw-output '.tag_name')"
	tmpFile="$(mktemp)"
	trap 'rm -f -- "$tmpFile"' EXIT
	curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" -o "$tmpFile"
	bash -n "$tmpFile"
	PROFILE=/dev/null bash "$tmpFile"
	rm -f -- "$tmpFile"
	tmpFile=""
	sourceNVM
else
	echo "NVM is already installed"
fi

blankLine
printBanner "NVM installation complete!"
blankLine

if ! commandExists node; then
	echo "NVM is installed without changing shell profile files."
	echo "After loading the managed dev shell, install Node.js with:"
	echo "  source ~/.bashrc"
	echo "  nvm install --lts"
	echo "  nvm use --lts"
else
	echo "Node.js is already installed: $(node --version)"
fi

blankLine

if ! commandExists yarn; then
	echo "To enable the package manager declared by a project, run:"
	echo "  corepack enable"
else
	echo "Yarn is already installed: $(yarn --version)"
fi

blankLine
echo "===================================================================================================="
