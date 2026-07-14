#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

DOCKER_CONFIG_DIR="${DOCKER_CONFIG_DIR:-/etc/docker}"
DOCKER_DAEMON_FILE="$DOCKER_CONFIG_DIR/daemon.json"
LOG_MAX_SIZE="${LOG_MAX_SIZE:-100m}"
LOG_MAX_FILE="${LOG_MAX_FILE:-3}"
tmpFile=""

function cleanup {
	[ -z "$tmpFile" ] || rm -f -- "$tmpFile"
}

trap cleanup EXIT

if ! commandExists jq; then
	echo "Installing dependencies for log rotation..."
	installAptPackages jq
fi

blankLine
echo "Configuring Docker log rotation..."

sudoCommand install -m 0755 -d "$DOCKER_CONFIG_DIR"

if sudoCommand test -f "$DOCKER_DAEMON_FILE"; then
	echo "Validating existing daemon.json..."
	sudoCommand jq empty "$DOCKER_DAEMON_FILE"

	backupFile="$DOCKER_DAEMON_FILE.bak.$(timestamp)"
	echo "Backing up existing daemon.json to $backupFile..."
	sudoCommand cp "$DOCKER_DAEMON_FILE" "$backupFile"

	tmpFile="$(mktemp)"
	# shellcheck disable=SC2016
	sudoCommand jq \
		--arg maxSize "$LOG_MAX_SIZE" \
		--arg maxFile "$LOG_MAX_FILE" '
			.["log-driver"] = "json-file"
			| .["log-opts"] = (
				(.["log-opts"] // {}) + {
					"max-size": $maxSize,
					"max-file": $maxFile
				}
			)
		' "$DOCKER_DAEMON_FILE" >"$tmpFile"
else
	tmpFile="$(mktemp)"
	# shellcheck disable=SC2016
	jq -n \
		--arg maxSize "$LOG_MAX_SIZE" \
		--arg maxFile "$LOG_MAX_FILE" '
			{
				"log-driver": "json-file",
				"log-opts": {
					"max-size": $maxSize,
					"max-file": $maxFile
				}
			}
		' >"$tmpFile"
fi

sudoCommand install -m 0644 "$tmpFile" "$DOCKER_DAEMON_FILE"
rm -f "$tmpFile"
tmpFile=""

echo "Docker log rotation configured successfully."
echo "  max-size: $LOG_MAX_SIZE"
echo "  max-file: $LOG_MAX_FILE"
