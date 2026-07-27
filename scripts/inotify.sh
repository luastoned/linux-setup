#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

SYSCTL_FILE="${SYSCTL_FILE:-/etc/sysctl.d/99-linux-setup-inotify.conf}"
APPLY_SYSCTL="${APPLY_SYSCTL:-1}"
SYSCTL_BIN="${SYSCTL_BIN:-sysctl}"
tmpFile=""

function cleanup {
	[ -z "$tmpFile" ] || rm -f -- "$tmpFile"
}

trap cleanup EXIT

if [[ "$APPLY_SYSCTL" != 0 && "$APPLY_SYSCTL" != 1 ]]; then
	echo "APPLY_SYSCTL must be 0 or 1" >&2
	exit 1
fi

printBanner "Increasing inotify watchers ..."
blankLine

## https://github.com/guard/listen/blob/master/README.md#increasing-the-amount-of-inotify-watchers
## https://github.com/fatso83/dotfiles/blob/master/utils/scripts/inotify-consumers

echo "Configuring inotify limits..."
echo "  max_user_instances: 8192"
echo "  max_user_watches: 1048576"
echo "  max_queued_events: 2097152"
blankLine

tmpFile="$(mktemp)"
cat >"$tmpFile" <<'EOF'
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
fs.inotify.max_queued_events=2097152
EOF
installSystemFile "$tmpFile" "$SYSCTL_FILE" 0644 "inotify sysctl configuration"
rm -f -- "$tmpFile"
tmpFile=""

blankLine
if [[ "$APPLY_SYSCTL" == 1 && "$INSTALL_FILE_CHANGED" == 1 ]]; then
	echo "Applying sysctl settings..."
	sudoCommand "$SYSCTL_BIN" --system
elif [[ "$APPLY_SYSCTL" == 0 ]]; then
	echo "Skipping sysctl apply (APPLY_SYSCTL=0)."
else
	echo "Inotify sysctl configuration is unchanged; no apply needed."
fi

blankLine
printBanner "Inotify configuration complete!"
if [[ "$APPLY_SYSCTL" == 1 ]]; then
	blankLine
	echo "Current inotify settings:"
	"$SYSCTL_BIN" fs.inotify.max_user_instances fs.inotify.max_user_watches fs.inotify.max_queued_events
fi
blankLine
echo "===================================================================================================="
