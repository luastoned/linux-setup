#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
KUBE_PS1_FILE="$CONFIG_DIR/dev-shell.kube-ps1.sh"
KUBE_PS1_URL="https://raw.githubusercontent.com/jonmosco/kube-ps1/master/kube-ps1.sh"
forceInstall=0
tmpFile=""

function cleanup {
	[ -z "$tmpFile" ] || rm -f -- "$tmpFile"
}

trap cleanup EXIT

function printUsage {
	cat <<EOF
Usage: bash utilities/install-kube-ps1.sh [options]

Options:
  -f, --force   Install even when Kubernetes tooling/config is not detected.
  -h, --help    Show this help message.
EOF
}

function hasKubernetes {
	commandExists kubectl ||
		commandExists k3d ||
		commandExists helm ||
		[ -n "${KUBECONFIG:-}" ] ||
		[ -f "$HOME/.kube/config" ]
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	-f | --force)
		forceInstall=1
		shift
		;;
	-h | --help)
		printUsage
		exit 0
		;;
	*)
		echo "Unknown option: $1" >&2
		echo "" >&2
		printUsage >&2
		exit 1
		;;
	esac
done

if [[ "$forceInstall" != 1 ]] && ! hasKubernetes; then
	echo "Skipping kube-ps1: no Kubernetes tooling or kubeconfig detected"
	echo "Use --force to install anyway."
	exit 0
fi

install -m 0755 -d "$CONFIG_DIR"
tmpFile="$(mktemp "$CONFIG_DIR/dev-shell.kube-ps1.sh.tmp.XXXXXX")"

echo "Installing kube-ps1 to $KUBE_PS1_FILE..."
curl -fsSL -o "$tmpFile" "$KUBE_PS1_URL"
mv -- "$tmpFile" "$KUBE_PS1_FILE"
tmpFile=""
echo "kube-ps1 installation complete."
