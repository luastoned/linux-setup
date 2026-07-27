#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

SKIP_SNITCH="${SKIP_SNITCH:-0}"

function installOptionalAptPackage {
	local package="$1"
	local description="$2"

	if apt-cache show "$package" >/dev/null 2>&1; then
		echo "Installing optional $description..."
		installAptPackages "$package"
	else
		echo "Skipping optional $description: $package is not available from the enabled repositories."
	fi
}

printBanner "Installing utilities ..."
blankLine
echo "Updating package lists..."
aptUpdate

blankLine
echo "Installing essential utilities ..."
installAptPackages \
	7zip \
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
	pkg-config \
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
	zip

blankLine
installOptionalAptPackage yq "YAML processor"

blankLine
installOptionalAptPackage 7zip-rar "RAR codec for 7-Zip"

blankLine
if [[ "$SKIP_SNITCH" == 1 ]]; then
	echo "Skipping Snitch port scanner installation (SKIP_SNITCH=1)."
else
	echo "Installing Snitch port scanner..."
	curl -fsSL https://raw.githubusercontent.com/karol-broda/snitch/master/install.sh | sudoCommand bash
fi

blankLine
printBanner "Utilities installation complete!"
