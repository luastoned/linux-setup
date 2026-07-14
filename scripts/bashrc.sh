#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

COMPLETIONS_SCRIPT="$LINUX_SETUP_UTILITIES_DIR/write-shell-completions.sh"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BASHRC_FILE="$HOME/.bashrc"
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

function backupBashrc {
	if [ -f "$BASHRC_FILE" ]; then
		echo "Backing up existing .bashrc..."
		cp "$BASHRC_FILE" "$HOME/.bashrc_backup_$(timestamp)"
	else
		echo "Creating .bashrc..."
		touch "$BASHRC_FILE"
	fi
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
	local block

	block="$(managedBlock)"
	tmpFile="$(mktemp)"

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
	' "$BASHRC_FILE" >"$tmpFile"

	chmod --reference="$BASHRC_FILE" "$tmpFile" 2>/dev/null || true
	mv "$tmpFile" "$BASHRC_FILE"
	tmpFile=""
}

function installDevShellFiles {
	local sourceFile
	local targetFile

	for sourceFile in "$LINUX_SETUP_ASSETS_DIR"/dev-shell/*.bash; do
		[ -e "$sourceFile" ] || continue
		targetFile="$CONFIG_DIR/$(basename "$sourceFile")"
		echo "Installing $(basename "$sourceFile")..."
		install -m 0644 "$sourceFile" "$targetFile"
	done
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
echo "Writing shell completions for installed tools..."
bash "$COMPLETIONS_SCRIPT"

blankLine
backupBashrc

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
