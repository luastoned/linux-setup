#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

printBanner "Installing utilities ..."
blankLine
echo "Installing essential utilities ..."
installAptPackages \
	bash-completion \
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
	shfmt \
	shellcheck \
	smartmontools \
	socat \
	tmux \
	traceroute \
	tree \
	unzip \
	vim \
	wget \
	yq \
	zip

blankLine
echo "Installing Snitch port scanner..."
curl -fsSL https://raw.githubusercontent.com/karol-broda/snitch/master/install.sh | sudoCommand bash

blankLine
printBanner "Utilities installation complete!"
