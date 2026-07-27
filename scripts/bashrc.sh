#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

COMPLETIONS_SCRIPT="$LINUX_SETUP_UTILITIES_DIR/write-shell-completions.sh"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BASHRC_FILE="$HOME/.bashrc"
LOCAL_SHELL_FILE="$CONFIG_DIR/dev-shell.local.bash"
LOCAL_SHELL_TEMPLATE="$LINUX_SETUP_ASSETS_DIR/dev-shell/dev-shell.local.bash"
MARKER_START="# >>> linux-setup"
MARKER_END="# <<< linux-setup"
tmpFile=""

function cleanup {
	[ -z "$tmpFile" ] || rm -f -- "$tmpFile"
}

trap cleanup EXIT

function managedBlock {
	cat <<'EOF'
# >>> linux-setup
if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/dev-shell.bash" ]; then
	source "${XDG_CONFIG_HOME:-$HOME/.config}/dev-shell.bash"
fi
# <<< linux-setup
EOF
}

function validateBashrcMarkers {
	[ -f "$BASHRC_FILE" ] || return 0

	awk \
		-v start="$MARKER_START" \
		-v end="$MARKER_END" '
		$0 == start {
			start_count++
			if (in_block || start_count > 1) {
				invalid = 1
			}
			in_block = 1
			next
		}

		$0 == end {
			end_count++
			if (!in_block || end_count > 1) {
				invalid = 1
			}
			in_block = 0
			next
		}

		END {
			if (invalid || in_block || start_count != end_count) {
				exit 1
			}
		}
	' "$BASHRC_FILE"
}

function updateBashrcMarker {
	local bashrcMode=0644
	local block
	local inputFile=/dev/null

	block="$(managedBlock)"
	tmpFile="$(mktemp)"
	if [ -f "$BASHRC_FILE" ]; then
		inputFile="$BASHRC_FILE"
		bashrcMode="$(stat -c '%a' "$BASHRC_FILE")"
	fi

	awk \
		-v start="$MARKER_START" \
		-v end="$MARKER_END" \
		-v block="$block" '
		$0 == start {
			if (!printed) {
				print block
				printed = 1
			}
			in_block = 1
			next
		}

		$0 == end && in_block {
			in_block = 0
			next
		}

		!in_block {
			print
		}

		END {
			if (!printed) {
				if (NR > 0) {
					print ""
				}
				print block
			}
		}
	' "$inputFile" >"$tmpFile"

	installUserFile "$tmpFile" "$BASHRC_FILE" "$bashrcMode" ".bashrc"
	rm -f -- "$tmpFile"
	tmpFile=""
}

function installDevShellFiles {
	local sourceFile
	local targetFile

	for sourceFile in "$LINUX_SETUP_ASSETS_DIR"/dev-shell/*.bash; do
		[ -e "$sourceFile" ] || continue
		[ "$sourceFile" != "$LOCAL_SHELL_TEMPLATE" ] || continue
		targetFile="$CONFIG_DIR/$(basename "$sourceFile")"
		installUserFile "$sourceFile" "$targetFile" 0644 "$(basename "$sourceFile")"
	done
}

function createLocalShellFile {
	if pathExists "$LOCAL_SHELL_FILE"; then
		echo "Preserving existing dev-shell.local.bash"
		return 0
	fi

	installUserFile "$LOCAL_SHELL_TEMPLATE" "$LOCAL_SHELL_FILE" 0644 "dev-shell.local.bash"
}

printBanner "Installing dev shell config and extensions ..."
blankLine

if ! validateBashrcMarkers; then
	echo "Error: malformed linux-setup marker block in $BASHRC_FILE" >&2
	echo "Refusing to modify .bashrc; fix or remove the unmatched/duplicate markers first." >&2
	exit 1
fi

echo "Ensuring config directory exists..."
install -m 0755 -d "$CONFIG_DIR"

blankLine
installDevShellFiles

blankLine
createLocalShellFile

blankLine
echo "Writing shell completions for installed tools..."
bash "$COMPLETIONS_SCRIPT"

blankLine
echo "Updating .bashrc linux-setup marker..."
updateBashrcMarker

blankLine
printBanner "Dev shell installation complete!"
blankLine
echo "To apply changes, run:"
echo "  source ~/.bashrc"
blankLine
echo "===================================================================================================="
