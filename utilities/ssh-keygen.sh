#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

function printUsage {
	cat <<EOF
Usage: bash utilities/ssh-keygen.sh [type]

Types:
  ed25519   Generate an ED25519 key.
  rsa       Generate an RSA 4096-bit key.
  both      Generate both key types.

If no type is provided, an interactive prompt is shown.
EOF
}

function generateEd25519 {
	echo "Generating ED25519 key..."
	ssh-keygen -t ed25519
}

function generateRSA {
	echo "Generating RSA 4096-bit key..."
	ssh-keygen -t rsa -b 4096
}

choice="${1:-}"

case "$choice" in
-h | --help)
	printUsage
	exit 0
	;;
"")
	echo "Which SSH key type(s) would you like to generate?"
	echo "1) ED25519 (recommended, modern)"
	echo "2) RSA 4096-bit (traditional, widely compatible)"
	echo "3) Both"
	read -r -p "Enter your choice (1/2/3): " choice
	;;
ed25519 | rsa | both | 1 | 2 | 3) ;;
*)
	echo "Invalid key type: $choice" >&2
	echo "" >&2
	printUsage >&2
	exit 1
	;;
esac

case $choice in
1 | ed25519)
	generateEd25519
	;;
2 | rsa)
	generateRSA
	;;
3 | both)
	generateEd25519
	blankLine
	generateRSA
	;;
*)
	echo "Invalid choice. Exiting."
	exit 1
	;;
esac

echo "SSH key generation complete!"
