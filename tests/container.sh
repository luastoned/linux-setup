#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXPECTED_UBUNTU_VERSION="${EXPECTED_UBUNTU_VERSION:?EXPECTED_UBUNTU_VERSION must be set}"

# shellcheck source=/dev/null
source /etc/os-release

if [[ "${ID:-}" != ubuntu || "${VERSION_ID:-}" != "$EXPECTED_UBUNTU_VERSION" ]]; then
	echo "Expected Ubuntu $EXPECTED_UBUNTU_VERSION, found ${PRETTY_NAME:-unknown system}." >&2
	exit 1
fi

export DEBIAN_FRONTEND=noninteractive
export HOME=/tmp/linux-setup-home

install -m 0755 -d "$HOME"
cd "$ROOT_DIR"

echo "Testing linux-setup on ${PRETTY_NAME}..."
echo "Installing the utilities module without the remote Snitch installer..."
SKIP_SNITCH=1 bash scripts/utilities.sh

dpkg-query --show --showformat='${Status}\n' 7zip | grep -qxF "install ok installed"
echo "PASS: required 7zip package is installed"

for package in yq 7zip-rar; do
	if apt-cache show "$package" >/dev/null 2>&1; then
		dpkg-query --show --showformat='${Status}\n' "$package" | grep -qxF "install ok installed"
		echo "PASS: optional $package package is available and installed"
	else
		echo "PASS: optional $package package is unavailable and was skipped"
	fi
done

echo "Running repository checks..."
bash -n setup.sh scripts/*.sh utilities/*.sh tests/*.sh assets/dev-shell/*.bash lib/common.sh
shfmt -d setup.sh scripts utilities tests assets/dev-shell/*.bash lib/common.sh
shellcheck -x setup.sh scripts/*.sh utilities/*.sh tests/*.sh lib/common.sh assets/dev-shell/*.bash
bash tests/smoke.sh

echo "All Ubuntu $EXPECTED_UBUNTU_VERSION container tests passed."
