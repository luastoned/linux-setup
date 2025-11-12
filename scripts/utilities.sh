#!/bin/bash

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$(dirname "$SCRIPT_DIR")"

echo "===================================================================================================="
echo "== Installing utilities..."
echo "===================================================================================================="
echo ""

echo "Installing essential utilities..."
sudo apt install \
	bat \
	build-essential \
	cpuid \
	curl \
	dnsutils \
	git \
	htop \
	jq \
	libssl-dev \
	lshw \
	nano \
	ncdu \
	net-tools \
	netcat-openbsd \
	p7zip \
	p7zip-full \
	p7zip-rar \
	pkg-config \
	rar \
	ripgrep \
	rlwrap \
	rsync \
	smartmontools \
	socat \
	tmux \
	traceroute \
	tree \
	unzip \
	vim \
	wget \
	yq \
	zip \
	-y

echo ""
echo "===================================================================================================="
echo "== Utilities installation complete!"
echo "===================================================================================================="
