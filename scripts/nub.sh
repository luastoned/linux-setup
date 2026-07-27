#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

NUB_INSTALL_URL="${NUB_INSTALL_URL:-https://nubjs.com/install.sh}"
NUB_BIN="${NUB_BIN:-$HOME/.nub/bin/nub}"
tmpFile=""

function cleanup {
	[ -z "$tmpFile" ] || rm -f -- "$tmpFile"
}

trap cleanup EXIT

printBanner "Installing Nub ..."
blankLine

echo "Installing dependencies..."
aptUpdate
installAptPackages ca-certificates curl

blankLine
if [ -x "$NUB_BIN" ]; then
	echo "Nub is already installed: $("$NUB_BIN" --version)"
else
	echo "Downloading the Nub installer..."
	tmpFile="$(mktemp)"
	curl -fsSL "$NUB_INSTALL_URL" -o "$tmpFile"
	bash -n "$tmpFile"

	echo "Installing Nub without modifying shell profile files..."
	NUB_NO_MODIFY_PATH=1 bash "$tmpFile"
	rm -f -- "$tmpFile"
	tmpFile=""
fi

blankLine
printBanner "Nub installation complete!"
blankLine
echo "After loading the managed dev shell, try:"
echo "  nub --version"
echo "  nub node install lts"
echo "  nub node"
blankLine
echo "NVM can remain installed; Nub can reuse compatible Node versions from NVM."
blankLine
echo "===================================================================================================="
