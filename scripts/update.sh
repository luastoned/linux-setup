#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

printBanner "Running system update and upgrade ..."
blankLine
echo "Updating package lists ..."
aptUpdate

blankLine
echo "Upgrading installed packages ..."
sudoCommand apt upgrade -y

blankLine
echo "Removing unused packages ..."
sudoCommand apt autoremove -y

blankLine
printBanner "System update complete!"
