#!/bin/bash

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$(dirname "$SCRIPT_DIR")"

echo "===================================================================================================="
echo "== Increasing inotify watchers..."
echo "===================================================================================================="
echo ""

## https://github.com/guard/listen/blob/master/README.md#increasing-the-amount-of-inotify-watchers
## https://github.com/fatso83/dotfiles/blob/master/utils/scripts/inotify-consumers

echo "Configuring inotify limits..."
echo "  max_user_instances: 8192"
echo "  max_user_watches: 1048576"
echo "  max_queued_events: 2097152"
echo ""

# Check if already configured
if grep -q "fs.inotify.max_user_instances" /etc/sysctl.conf; then
	echo "inotify settings already exist in /etc/sysctl.conf, skipping..."
else
	echo "Adding inotify settings to /etc/sysctl.conf..."
	echo "fs.inotify.max_user_instances=8192" | sudo tee -a /etc/sysctl.conf
	echo "fs.inotify.max_user_watches=1048576" | sudo tee -a /etc/sysctl.conf
	echo "fs.inotify.max_queued_events=2097152" | sudo tee -a /etc/sysctl.conf
fi

echo ""
echo "Applying sysctl settings..."
sudo sysctl -p

echo ""
echo "===================================================================================================="
echo "== Inotify configuration complete!"
echo "===================================================================================================="
echo ""
echo "Current inotify settings:"
sysctl fs.inotify.max_user_instances fs.inotify.max_user_watches fs.inotify.max_queued_events
echo ""
echo "===================================================================================================="
