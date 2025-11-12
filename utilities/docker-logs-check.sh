#!/bin/bash

set -euo pipefail

# Check Docker container log sizes
# This script displays the disk space used by Docker container logs
# Useful for identifying containers with excessive logging

echo "Checking Docker container log sizes..."
echo ""

sudo du -ch /var/lib/docker/containers/*/*-json.log

echo ""
echo "Total log size shown above. Consider rotating or clearing large logs."