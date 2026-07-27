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
# shellcheck disable=SC2034 # Shared file-install state is consumed by calling scripts.
INSTALL_FILE_CHANGED=0
# shellcheck disable=SC2034 # Shared file-install state is consumed by calling scripts.
LAST_BACKUP_FILE=""

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

function pathExists {
	[ -e "$1" ] || [ -L "$1" ]
}

function systemPathExists {
	sudoCommand test -e "$1" || sudoCommand test -L "$1"
}

function nextBackupPath {
	local targetFile="$1"
	local backupFile
	local suffix=0

	backupFile="$targetFile.bak.$(timestamp)"
	while pathExists "$backupFile"; do
		suffix=$((suffix + 1))
		backupFile="$targetFile.bak.$(timestamp).$suffix"
	done

	printf '%s\n' "$backupFile"
}

function nextSystemBackupPath {
	local targetFile="$1"
	local backupFile
	local suffix=0

	backupFile="$targetFile.bak.$(timestamp)"
	while systemPathExists "$backupFile"; do
		suffix=$((suffix + 1))
		backupFile="$targetFile.bak.$(timestamp).$suffix"
	done

	printf '%s\n' "$backupFile"
}

function backupFile {
	local targetFile="$1"
	local label="${2:-$targetFile}"
	local backupFile

	# shellcheck disable=SC2034 # Shared file-install state is consumed by calling scripts.
	LAST_BACKUP_FILE=""
	pathExists "$targetFile" || return 0

	backupFile="$(nextBackupPath "$targetFile")"
	echo "Backing up $label to $backupFile..."
	cp -a -- "$targetFile" "$backupFile"
	# shellcheck disable=SC2034 # Shared file-install state is consumed by calling scripts.
	LAST_BACKUP_FILE="$backupFile"
}

function backupSystemFile {
	local targetFile="$1"
	local label="${2:-$targetFile}"
	local backupFile

	# shellcheck disable=SC2034 # Shared file-install state is consumed by calling scripts.
	LAST_BACKUP_FILE=""
	systemPathExists "$targetFile" || return 0

	backupFile="$(nextSystemBackupPath "$targetFile")"
	echo "Backing up $label to $backupFile..."
	sudoCommand cp -a -- "$targetFile" "$backupFile"
	# shellcheck disable=SC2034 # Shared file-install state is consumed by calling scripts.
	LAST_BACKUP_FILE="$backupFile"
}

function installUserFile {
	local sourceFile="$1"
	local targetFile="$2"
	local mode="${3:-0644}"
	local label="${4:-$targetFile}"
	local targetDir
	local tmpFile

	# shellcheck disable=SC2034 # Shared file-install state is consumed by calling scripts.
	INSTALL_FILE_CHANGED=0
	# shellcheck disable=SC2034 # Shared file-install state is consumed by calling scripts.
	LAST_BACKUP_FILE=""

	if pathExists "$targetFile" && cmp -s -- "$sourceFile" "$targetFile"; then
		echo "$label is already up to date"
		return 0
	fi

	targetDir="$(dirname "$targetFile")"
	install -m 0755 -d -- "$targetDir"
	tmpFile="$(mktemp "$targetDir/.linux-setup.$(basename "$targetFile").XXXXXX")"

	if ! install -m "$mode" -- "$sourceFile" "$tmpFile"; then
		rm -f -- "$tmpFile"
		return 1
	fi

	backupFile "$targetFile" "$label"
	echo "Installing $label..."
	if ! mv -- "$tmpFile" "$targetFile"; then
		rm -f -- "$tmpFile"
		return 1
	fi

	# shellcheck disable=SC2034 # Shared file-install state is consumed by calling scripts.
	INSTALL_FILE_CHANGED=1
}

function installSystemFile {
	local sourceFile="$1"
	local targetFile="$2"
	local mode="${3:-0644}"
	local label="${4:-$targetFile}"
	local targetDir
	local tmpFile

	# shellcheck disable=SC2034 # Shared file-install state is consumed by calling scripts.
	INSTALL_FILE_CHANGED=0
	# shellcheck disable=SC2034 # Shared file-install state is consumed by calling scripts.
	LAST_BACKUP_FILE=""

	if systemPathExists "$targetFile" && sudoCommand cmp -s -- "$sourceFile" "$targetFile"; then
		echo "$label is already up to date"
		return 0
	fi

	targetDir="$(dirname "$targetFile")"
	sudoCommand install -m 0755 -d -- "$targetDir"
	tmpFile="$(sudoCommand mktemp "$targetDir/.linux-setup.$(basename "$targetFile").XXXXXX")"

	if ! sudoCommand install -m "$mode" -- "$sourceFile" "$tmpFile"; then
		sudoCommand rm -f -- "$tmpFile"
		return 1
	fi

	backupSystemFile "$targetFile" "$label"
	echo "Installing $label..."
	if ! sudoCommand mv -- "$tmpFile" "$targetFile"; then
		sudoCommand rm -f -- "$tmpFile"
		return 1
	fi

	# shellcheck disable=SC2034 # Shared file-install state is consumed by calling scripts.
	INSTALL_FILE_CHANGED=1
}
