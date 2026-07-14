#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
install -m 0755 -d "$CONFIG_DIR"
commands=()
tmpFile=""

function cleanup {
	[ -z "$tmpFile" ] || rm -f -- "$tmpFile"
}

trap cleanup EXIT

function completionFile {
	printf '%s/dev-shell.%s-completion.bash\n' "$CONFIG_DIR" "$1"
}

function writeCompletion {
	local commandName="$1"
	local outputFile

	if ! commandExists "$commandName"; then
		echo "Skipping $commandName completion: command not found"
		return 0
	fi

	outputFile="$(completionFile "$commandName")"
	tmpFile="$(mktemp "$CONFIG_DIR/dev-shell.$commandName-completion.bash.tmp.XXXXXX")"

	if "$commandName" completion bash >"$tmpFile"; then
		mv -- "$tmpFile" "$outputFile"
		tmpFile=""
		echo "Wrote $commandName completion to $outputFile"
	else
		rm -f -- "$tmpFile"
		tmpFile=""
		echo "Warning: failed to generate $commandName completion" >&2
	fi
}

if [[ $# -gt 0 ]]; then
	commands=("$@")
else
	commands=(docker kubectl helm k3d)
fi

for commandName in "${commands[@]}"; do
	case "$commandName" in
	docker | kubectl | helm | k3d) writeCompletion "$commandName" ;;
	*)
		echo "Unknown completion target: $commandName" >&2
		exit 1
		;;
	esac
done
