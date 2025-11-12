#!/bin/bash

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$SETUP_DIR/assets"

echo "===================================================================================================="
echo "== Installing .bashrc and extensions..."
echo "===================================================================================================="
echo ""

cd "$ASSETS_DIR"

echo "Downloading git and kube extensions..."
curl -fsSL -o git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
curl -fsSL -o git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
curl -fsSL -o kube-ps1.sh https://raw.githubusercontent.com/jonmosco/kube-ps1/master/kube-ps1.sh

echo ""
echo "Backing up existing .bashrc..."
cp ~/.bashrc ~/".bashrc_backup_$(date +'%y.%m.%d_%H-%M-%S')"

echo ""
echo "Installing new .bashrc and extensions..."
cp .bashrc ~/.bashrc
cp git-prompt.sh ~/.git-prompt.sh
cp git-completion.bash ~/.git-completion.bash
cp kube-ps1.sh ~/.kube-ps1.sh

echo ""
echo "===================================================================================================="
echo "== .bashrc installation complete!"
echo "===================================================================================================="
echo ""
echo "To apply changes, run:"
echo "  source ~/.bashrc"
echo "  [opt] kubeoff -g"
echo ""
echo "===================================================================================================="
