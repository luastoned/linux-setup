#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

DOCKER_CONTAINERS_DIR="${DOCKER_CONTAINERS_DIR:-/var/lib/docker/containers}"

if ! sudoCommand test -d "$DOCKER_CONTAINERS_DIR"; then
	echo "Docker containers directory not found: $DOCKER_CONTAINERS_DIR"
	exit 0
fi

firstLog="$(sudoCommand find "$DOCKER_CONTAINERS_DIR" -type f -name '*-json.log' -print -quit)"
if [ -z "$firstLog" ]; then
	echo "No Docker JSON log files found."
	exit 0
fi

echo "WARNING: This will clear ALL Docker container logs!"
echo "This action cannot be undone."
blankLine
read -r -p "Are you sure you want to continue? (y/N): " confirm

if [[ ! "$confirm" =~ ^[Yy]([Ee][Ss])?$ ]]; then
	echo "Operation cancelled."
	exit 0
fi

echo "Clearing Docker container logs..."
sudoCommand find "$DOCKER_CONTAINERS_DIR" -type f -name '*-json.log' -exec truncate -s 0 -- {} +
echo "Docker logs cleared successfully."
