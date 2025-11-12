#!/bin/bash

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$(dirname "$SCRIPT_DIR")"

echo "===================================================================================================="
echo "== Stopping and disabling Nginx..."
echo "===================================================================================================="
echo ""

## stop any running nginx instance
echo "Stopping Nginx service..."
sudo service nginx stop 2>/dev/null || echo "Nginx service not running"

echo ""
## prevent nginx from starting on boot
echo "Disabling Nginx from starting on boot..."
sudo systemctl disable nginx 2>/dev/null || true
sudo update-rc.d -f nginx disable 2>/dev/null || true

echo ""
echo "===================================================================================================="
echo "== Nginx stopped and disabled!"
echo "===================================================================================================="
