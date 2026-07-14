#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

DOCKER_CONTAINERS_DIR="${DOCKER_CONTAINERS_DIR:-/var/lib/docker/containers}"

echo "Checking Docker container log sizes..."
blankLine

if ! sudoCommand test -d "$DOCKER_CONTAINERS_DIR"; then
	echo "Docker containers directory not found: $DOCKER_CONTAINERS_DIR"
	exit 0
fi

firstLog="$(sudoCommand find "$DOCKER_CONTAINERS_DIR" -type f -name '*-json.log' -print -quit)"
if [ -z "$firstLog" ]; then
	echo "No Docker JSON log files found."
	exit 0
fi

sudoCommand find "$DOCKER_CONTAINERS_DIR" -type f -name '*-json.log' -exec du -ch {} +

blankLine
echo "Total log size shown above. Consider rotating or clearing large logs."
