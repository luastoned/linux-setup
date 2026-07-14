#!/bin/bash

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	echo "lib/common.sh is meant to be sourced, not executed." >&2
	exit 1
fi

if [[ -z "${LINUX_SETUP_DIR:-}" ]]; then
	LINUX_SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

# shellcheck disable=SC2034 # Shared constants are consumed by scripts that source this file.
LINUX_SETUP_ASSETS_DIR="$LINUX_SETUP_DIR/assets"
# shellcheck disable=SC2034 # Shared constants are consumed by scripts that source this file.
LINUX_SETUP_SCRIPTS_DIR="$LINUX_SETUP_DIR/scripts"
# shellcheck disable=SC2034 # Shared constants are consumed by scripts that source this file.
LINUX_SETUP_UTILITIES_DIR="$LINUX_SETUP_DIR/utilities"

function commandExists {
	command -v "$1" >/dev/null 2>&1
}

function linuxDescription {
	if commandExists lsb_release; then
		lsb_release -ds
	elif [ -r /etc/os-release ]; then
		# shellcheck source=/dev/null
		. /etc/os-release
		printf '%s\n' "${PRETTY_NAME:-Linux}"
	else
		printf '%s\n' "Linux"
	fi
}

function linuxCodename {
	if commandExists lsb_release; then
		lsb_release -cs
	elif [ -r /etc/os-release ]; then
		# shellcheck source=/dev/null
		. /etc/os-release
		printf '%s\n' "${VERSION_CODENAME:-unknown}"
	else
		printf '%s\n' "unknown"
	fi
}

function isWSL {
	grep -qi "microsoft" /proc/version 2>/dev/null
}

function printBanner {
	local message="$1"

	echo "===================================================================================================="
	echo "== $message"
	echo "===================================================================================================="
}

function blankLine {
	echo ""
}

function sudoCommand {
	if [[ "$(id -u)" == 0 ]]; then
		"$@"
	else
		sudo "$@"
	fi
}

function installAptPackages {
	sudoCommand apt install "$@" -y
}

function aptUpdate {
	sudoCommand apt update
}

function timestamp {
	date +'%y.%m.%d_%H-%M-%S'
}
