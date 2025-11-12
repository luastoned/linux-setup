#!/bin/bash

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$(dirname "$SCRIPT_DIR")"

echo "===================================================================================================="
echo "== Running system update and upgrade..."
echo "===================================================================================================="
echo ""

echo "Updating package lists..."
sudo apt update

echo ""
echo "Upgrading installed packages..."
sudo apt upgrade -y

echo ""
echo "Removing unused packages..."
sudo apt autoremove -y

echo ""
echo "===================================================================================================="
echo "== System update complete!"
echo "===================================================================================================="
