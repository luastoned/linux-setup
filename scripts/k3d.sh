#!/bin/bash

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$(dirname "$SCRIPT_DIR")"

echo "===================================================================================================="
echo "== Installing Kubernetes tools (k3d, kubectl, krew, kubectx, kubens, konfig, helm)..."
echo "===================================================================================================="
echo ""

## dependencies
echo "Installing dependencies..."
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y

echo ""
echo "Adding Kubernetes repository..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo ""
echo "Installing kubectl..."
sudo apt update
sudo apt install kubectl -y

echo ""
echo "Installing k3d..."
curl -fsSL https://raw.githubusercontent.com/rancher/k3d/main/install.sh | sudo bash

echo ""
echo "Installing krew..."
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

echo ""
echo "Installing kubectl plugins (ctx, ns, konfig)..."
kubectl krew install ctx
kubectl krew install ns
kubectl krew install konfig

echo ""
echo "Installing Helm..."
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | sudo bash

echo ""
echo "===================================================================================================="
echo "== Kubernetes tools installation complete!"
echo "===================================================================================================="
echo ""
echo "Add krew to your PATH by ensuring this is in your .bashrc:"
echo "  export PATH=\"\${KREW_ROOT:-\$HOME/.krew}/bin:\$PATH\""
echo ""
echo "===================================================================================================="