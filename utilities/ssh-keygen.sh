#!/bin/bash

set -euo pipefail

echo "Which SSH key type(s) would you like to generate?"
echo "1) ED25519 (recommended, modern)"
echo "2) RSA 4096-bit (traditional, widely compatible)"
echo "3) Both"
read -p "Enter your choice (1/2/3): " choice

case $choice in
1)
	echo "Generating ED25519 key..."
	ssh-keygen -t ed25519
	;;
2)
	echo "Generating RSA 4096-bit key..."
	ssh-keygen -t rsa -b 4096
	;;
3)
	echo "Generating ED25519 key..."
	ssh-keygen -t ed25519
	echo ""
	echo "Generating RSA 4096-bit key..."
	ssh-keygen -t rsa -b 4096
	;;
*)
	echo "Invalid choice. Exiting."
	exit 1
	;;
esac

echo "SSH key generation complete!"
