#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

if isWSL; then
	printBanner "WSL detected - skipping Docker installation"
	blankLine
	echo "Use Docker Desktop for Windows instead."
	blankLine
	echo "===================================================================================================="
	exit 0
fi

COMPLETIONS_SCRIPT="$LINUX_SETUP_UTILITIES_DIR/write-shell-completions.sh"
TARGET_USER="${SUDO_USER:-$USER}"

printBanner "Installing Docker ..."
blankLine
echo "Installing dependencies..."
aptUpdate
installAptPackages ca-certificates curl

blankLine
echo "Removing old Docker versions..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
	sudoCommand apt remove "$pkg" -y 2>/dev/null || true
done

blankLine
echo "Adding Docker's GPG key..."
sudoCommand install -m 0755 -d /etc/apt/keyrings
sudoCommand curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudoCommand chmod a+r /etc/apt/keyrings/docker.asc

blankLine
echo "Adding Docker repository..."
ARCH="$(dpkg --print-architecture)"

# shellcheck source=/dev/null
. /etc/os-release
UBUNTU_CODENAME="${UBUNTU_CODENAME:-$VERSION_CODENAME}"

echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable" | sudoCommand tee /etc/apt/sources.list.d/docker.list >/dev/null

blankLine
echo "Installing Docker packages..."
aptUpdate
installAptPackages bash-completion docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

blankLine
echo "Configuring Docker group..."
sudoCommand groupadd docker 2>/dev/null || true
sudoCommand usermod -aG docker "$TARGET_USER"

blankLine
bash "$LINUX_SETUP_UTILITIES_DIR/docker-logs-rotation.sh"

blankLine
echo "Writing Docker shell completion..."
bash "$COMPLETIONS_SCRIPT" docker

blankLine
printBanner "Docker installation complete!"
blankLine
echo "To apply group changes, log out and log back in, or run:"
echo "  newgrp docker"
blankLine
echo "===================================================================================================="
