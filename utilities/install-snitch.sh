#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

SNITCH_INSTALL_URL="${SNITCH_INSTALL_URL:-https://raw.githubusercontent.com/karol-broda/snitch/master/install.sh}"
assumeYes=0
tmpFile=""

function cleanup {
	[ -z "$tmpFile" ] || rm -f -- "$tmpFile"
}

trap cleanup EXIT

function printUsage {
	cat <<EOF
Usage: ./utilities/install-snitch.sh [options]

Options:
  -y, --yes    Install without prompting.
  -h, --help   Show this help message.
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	-y | --yes)
		assumeYes=1
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

if commandExists snitch; then
	echo "Snitch is already installed: $(command -v snitch)"
	exit 0
fi

echo "The upstream Snitch installer downloads the latest release without an independent checksum."
if [[ "$assumeYes" != 1 ]]; then
	read -r -p "Download and run that installer as root? (y/N) " reply
	[[ "$reply" =~ ^[Yy]$ ]] || {
		echo "Cancelled."
		exit 0
	}
fi

tmpFile="$(mktemp)"
curl -fsSL "$SNITCH_INSTALL_URL" -o "$tmpFile"
bash -n "$tmpFile"
sudoCommand bash "$tmpFile"
rm -f -- "$tmpFile"
tmpFile=""
