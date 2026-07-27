#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

COMPLETIONS_SCRIPT="$LINUX_SETUP_UTILITIES_DIR/write-shell-completions.sh"
KUBERNETES_STABLE_URL="https://dl.k8s.io/release/stable.txt"
tmpDir=""

function cleanup {
	[ -z "$tmpDir" ] || rm -rf -- "$tmpDir"
}

trap cleanup EXIT

printBanner "Installing Kubernetes tools (k3d, kubectl, krew, kubectx, kubens, konfig, helm) ..."
blankLine

## dependencies
echo "Installing dependencies..."
aptUpdate
installAptPackages apt-transport-https bash-completion ca-certificates curl gnupg software-properties-common

blankLine
echo "Resolving the latest stable Kubernetes release..."
KUBERNETES_VERSION="$(curl -fsSL "$KUBERNETES_STABLE_URL")"
if [[ ! "$KUBERNETES_VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	echo "Unexpected Kubernetes stable version: $KUBERNETES_VERSION" >&2
	exit 1
fi
KUBERNETES_MINOR="${KUBERNETES_VERSION%.*}"
KUBERNETES_REPO_URL="https://pkgs.k8s.io/core:/stable:/$KUBERNETES_MINOR/deb"
echo "Using Kubernetes $KUBERNETES_VERSION from the $KUBERNETES_MINOR package repository."

blankLine
echo "Adding Kubernetes repository..."
tmpDir="$(mktemp -d)"
curl -fsSL "$KUBERNETES_REPO_URL/Release.key" -o "$tmpDir/kubernetes-release.key"
gpg --dearmor --yes --output "$tmpDir/kubernetes-apt-keyring.gpg" "$tmpDir/kubernetes-release.key"
installSystemFile \
	"$tmpDir/kubernetes-apt-keyring.gpg" \
	/etc/apt/keyrings/kubernetes-apt-keyring.gpg \
	0644 \
	"Kubernetes repository key"
printf 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] %s/ /\n' \
	"$KUBERNETES_REPO_URL" >"$tmpDir/kubernetes.list"
installSystemFile \
	"$tmpDir/kubernetes.list" \
	/etc/apt/sources.list.d/kubernetes.list \
	0644 \
	"Kubernetes apt repository"

blankLine
echo "Installing kubectl..."
aptUpdate
installAptPackages kubectl

blankLine
echo "Writing kubectl shell completion..."
bash "$COMPLETIONS_SCRIPT" kubectl

blankLine
echo "Installing k3d..."
curl -fsSL https://raw.githubusercontent.com/rancher/k3d/main/install.sh | sudoCommand bash

blankLine
echo "Writing k3d shell completion..."
bash "$COMPLETIONS_SCRIPT" k3d

blankLine
echo "Installing krew..."
(
	set -x
	tmpDir="$(mktemp -d)"
	trap 'rm -rf "$tmpDir"' EXIT
	cd "$tmpDir" &&
		OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
		ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
		KREW="krew-${OS}_${ARCH}" &&
		curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
		tar zxvf "${KREW}.tar.gz" &&
		./"${KREW}" install krew
)

blankLine
echo "Installing kubectl plugins (ctx, ns, konfig)..."
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
for plugin in ctx ns konfig; do
	if kubectl krew list | grep -qxF "$plugin"; then
		echo "kubectl plugin $plugin is already installed"
	else
		kubectl krew install "$plugin"
	fi
done

blankLine
echo "Installing Helm..."
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | sudoCommand bash

blankLine
echo "Writing Helm shell completion..."
bash "$COMPLETIONS_SCRIPT" helm

blankLine
printBanner "Kubernetes tools installation complete!"
blankLine
echo "Add krew to your PATH by ensuring this is in your .bashrc:"
echo "  export PATH=\"\${KREW_ROOT:-\$HOME/.krew}/bin:\$PATH\""
blankLine
echo "===================================================================================================="
