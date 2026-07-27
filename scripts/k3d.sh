#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

COMPLETIONS_SCRIPT="$LINUX_SETUP_UTILITIES_DIR/write-shell-completions.sh"
KUBERNETES_STABLE_URL="https://dl.k8s.io/release/stable.txt"
HELM_LATEST_URL="https://get.helm.sh/helm3-latest-version"
K3D_INSTALL_DIR="${K3D_INSTALL_DIR:-/usr/local/bin}"
HELM_INSTALL_DIR="${HELM_INSTALL_DIR:-/usr/local/bin}"
KREW_ROOT="${KREW_ROOT:-$HOME/.krew}"
tmpDir=""

function cleanup {
	[ -z "$tmpDir" ] || rm -rf -- "$tmpDir"
}

trap cleanup EXIT

function releaseArchitecture {
	case "$(dpkg --print-architecture)" in
	amd64) printf '%s\n' "amd64" ;;
	arm64) printf '%s\n' "arm64" ;;
	armhf) printf '%s\n' "arm" ;;
	i386) printf '%s\n' "386" ;;
	*)
		echo "Unsupported architecture: $(dpkg --print-architecture)" >&2
		return 1
		;;
	esac
}

function downloadGitHubReleaseAsset {
	local repository="$1"
	local assetName="$2"
	local outputFile="$3"
	local releaseFile="$tmpDir/github-release.json"
	local downloadUrl
	local digest

	curl -fsSL "https://api.github.com/repos/$repository/releases/latest" -o "$releaseFile"
	downloadUrl="$(jq -er --arg name "$assetName" \
		'.assets[] | select(.name == $name) | .browser_download_url' "$releaseFile")"
	digest="$(jq -r --arg name "$assetName" \
		'.assets[] | select(.name == $name) | .digest' "$releaseFile")"

	if [[ ! "$digest" =~ ^sha256:[[:xdigit:]]{64}$ ]]; then
		echo "Missing or invalid SHA-256 digest for $repository release asset $assetName" >&2
		return 1
	fi

	curl -fsSL "$downloadUrl" -o "$outputFile"
	printf '%s  %s\n' "${digest#sha256:}" "$outputFile" | sha256sum --check -
}

printBanner "Installing Kubernetes tools (k3d, kubectl, krew, kubectx, kubens, konfig, helm) ..."
blankLine

## dependencies
echo "Installing dependencies..."
aptUpdate
installAptPackages apt-transport-https bash-completion ca-certificates curl gnupg jq software-properties-common

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
releaseArch="$(releaseArchitecture)"
k3dBinary="$tmpDir/k3d-linux-$releaseArch"
downloadGitHubReleaseAsset k3d-io/k3d "k3d-linux-$releaseArch" "$k3dBinary"
installSystemFile "$k3dBinary" "$K3D_INSTALL_DIR/k3d" 0755 "k3d"
"$K3D_INSTALL_DIR/k3d" version

blankLine
echo "Writing k3d shell completion..."
bash "$COMPLETIONS_SCRIPT" k3d

blankLine
echo "Installing krew..."
export PATH="$KREW_ROOT/bin:$PATH"
krewPlatform="krew-linux_$releaseArch"
if [ -x "$KREW_ROOT/bin/kubectl-krew" ]; then
	echo "krew is already installed"
else
	krewArchive="$tmpDir/$krewPlatform.tar.gz"
	downloadGitHubReleaseAsset kubernetes-sigs/krew "$krewPlatform.tar.gz" "$krewArchive"
	tar xzf "$krewArchive" -C "$tmpDir"
	"$tmpDir/$krewPlatform" install krew
fi

blankLine
echo "Installing kubectl plugins (ctx, ns, konfig)..."
for plugin in ctx ns konfig; do
	if kubectl krew list | grep -qxF "$plugin"; then
		echo "kubectl plugin $plugin is already installed"
	else
		kubectl krew install "$plugin"
	fi
done

blankLine
echo "Installing Helm..."
helmVersion="$(curl -fsSL "$HELM_LATEST_URL")"
if [[ ! "$helmVersion" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	echo "Unexpected Helm stable version: $helmVersion" >&2
	exit 1
fi
helmArchiveName="helm-$helmVersion-linux-$releaseArch.tar.gz"
helmArchive="$tmpDir/$helmArchiveName"
curl -fsSL "https://get.helm.sh/$helmArchiveName" -o "$helmArchive"
curl -fsSL "https://get.helm.sh/$helmArchiveName.sha256" -o "$helmArchive.sha256"
printf '%s  %s\n' "$(tr -d '[:space:]' <"$helmArchive.sha256")" "$helmArchive" | sha256sum --check -
tar xzf "$helmArchive" -C "$tmpDir"
installSystemFile "$tmpDir/linux-$releaseArch/helm" "$HELM_INSTALL_DIR/helm" 0755 "Helm"
"$HELM_INSTALL_DIR/helm" version --short

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
