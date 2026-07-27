#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

DOCKER_CONFIG_DIR="${DOCKER_CONFIG_DIR:-/etc/docker}"
DOCKER_DAEMON_FILE="$DOCKER_CONFIG_DIR/daemon.json"
LOG_MAX_SIZE="${LOG_MAX_SIZE:-100m}"
LOG_MAX_FILE="${LOG_MAX_FILE:-3}"
DOCKERD_BIN="${DOCKERD_BIN:-$(command -v dockerd || true)}"
restartDocker=0
tmpFile=""

function cleanup {
	[ -z "$tmpFile" ] || rm -f -- "$tmpFile"
}

trap cleanup EXIT

function printUsage {
	cat <<EOF
Usage: ./utilities/docker-logs-rotation.sh [options]

Options:
      --restart   Restart docker.service after a changed configuration.
  -h, --help      Show this help message.
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	--restart)
		restartDocker=1
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

if ! commandExists jq; then
	echo "Installing dependencies for log rotation..."
	installAptPackages jq
fi

blankLine
echo "Configuring Docker log rotation..."

sudoCommand install -m 0755 -d "$DOCKER_CONFIG_DIR"

if systemPathExists "$DOCKER_DAEMON_FILE"; then
	echo "Validating existing daemon.json..."
	sudoCommand jq empty "$DOCKER_DAEMON_FILE"

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

echo "Validating generated daemon.json..."
jq empty "$tmpFile"
if [ -n "$DOCKERD_BIN" ]; then
	"$DOCKERD_BIN" --validate --config-file="$tmpFile"
else
	echo "Warning: dockerd was not found; skipping Docker-specific configuration validation."
fi

installSystemFile "$tmpFile" "$DOCKER_DAEMON_FILE" 0644 "Docker daemon configuration"
backupFile="$LAST_BACKUP_FILE"
configurationChanged="$INSTALL_FILE_CHANGED"

rm -f -- "$tmpFile"
tmpFile=""

if [[ "$configurationChanged" == 1 && "$restartDocker" == 1 ]]; then
	if ! commandExists systemctl; then
		echo "Warning: systemctl was not found; restart Docker manually to apply the configuration."
	elif ! sudoCommand systemctl restart docker.service; then
		echo "Docker restart failed; rolling back daemon.json..." >&2
		restoreSystemFile "$DOCKER_DAEMON_FILE" "$backupFile"
		sudoCommand systemctl restart docker.service || true
		exit 1
	else
		echo "Restarted docker.service."
	fi
elif [[ "$configurationChanged" == 1 ]]; then
	echo "Restart Docker to apply this configuration."
fi

echo "Docker log rotation configured successfully."
echo "  max-size: $LOG_MAX_SIZE"
echo "  max-file: $LOG_MAX_FILE"
