#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

SYSCTL_FILE="${SYSCTL_FILE:-/etc/sysctl.d/99-linux-setup-inotify.conf}"

printBanner "Increasing inotify watchers ..."
blankLine

## https://github.com/guard/listen/blob/master/README.md#increasing-the-amount-of-inotify-watchers
## https://github.com/fatso83/dotfiles/blob/master/utils/scripts/inotify-consumers

echo "Configuring inotify limits..."
echo "  max_user_instances: 8192"
echo "  max_user_watches: 1048576"
echo "  max_queued_events: 2097152"
blankLine

echo "Writing $SYSCTL_FILE..."
sudoCommand tee "$SYSCTL_FILE" >/dev/null <<'EOF'
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
fs.inotify.max_queued_events=2097152
EOF

blankLine
echo "Applying sysctl settings..."
sudoCommand sysctl --system

blankLine
printBanner "Inotify configuration complete!"
blankLine
echo "Current inotify settings:"
sysctl fs.inotify.max_user_instances fs.inotify.max_user_watches fs.inotify.max_queued_events
blankLine
echo "===================================================================================================="
