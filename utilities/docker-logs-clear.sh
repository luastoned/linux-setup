#!/bin/bash

set -euo pipefail

# Clear all Docker container logs
# WARNING: This will permanently delete all container log data

echo "WARNING: This will clear ALL Docker container logs!"
echo "This action cannot be undone."
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
	echo "Operation cancelled."
	exit 0
fi

echo "Clearing Docker container logs..."
sudo truncate -s 0 /var/lib/docker/containers/**/*-json.log
echo "Docker logs cleared successfully."
