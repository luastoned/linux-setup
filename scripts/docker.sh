#!/bin/bash

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$(dirname "$SCRIPT_DIR")"

function isWSL {
	grep -q "microsoft" /proc/version
}

if isWSL; then
	echo "===================================================================================================="
	echo "== WSL detected - skipping Docker installation"
	echo "===================================================================================================="
	echo ""
	echo "Use Docker Desktop for Windows instead."
	echo ""
	echo "===================================================================================================="
	exit 0
fi

echo "===================================================================================================="
echo "== Installing Docker..."
echo "===================================================================================================="
echo ""

## dependencies
echo "Installing dependencies..."
sudo apt install jq -y

echo ""
echo "Removing old Docker versions..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
	sudo apt remove "$pkg" -y 2>/dev/null || true
done

echo ""
echo "Adding Docker's GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo ""
echo "Adding Docker repository..."
ARCH="$(dpkg --print-architecture)"

. /etc/os-release
UBUNTU_CODENAME="${UBUNTU_CODENAME:-$VERSION_CODENAME}"

echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

echo ""
echo "Installing Docker packages..."
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

echo ""
echo "Configuring Docker group..."
sudo groupadd docker 2>/dev/null || true
sudo usermod -aG docker "${USER}"

echo ""
echo "Configuring log rotation..."
[ -f /etc/docker/daemon.json ] && sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak

sudo jq -n \
	--slurpfile e /etc/docker/daemon.json '
    ($e[0] // {})
    | .["log-opts"] = (
        (.["log-opts"] // {}) + {
          "max-size": "100m",
          "max-file": "3"
        }
      )
    | .["log-driver"] = "json-file"
  ' | sudo tee /etc/docker/daemon.json.tmp >/dev/null

sudo mv /etc/docker/daemon.json.tmp /etc/docker/daemon.json

echo ""
echo "===================================================================================================="
echo "== Docker installation complete!"
echo "===================================================================================================="
echo ""
echo "To apply group changes, log out and log back in, or run:"
echo "  newgrp docker"
echo ""
echo "===================================================================================================="
