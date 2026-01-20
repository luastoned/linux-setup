#!/bin/bash

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$(dirname "$SCRIPT_DIR")"

echo "===================================================================================================="
echo "== Installing Snitch ..."
echo "===================================================================================================="
echo ""

curl -fsSL https://raw.githubusercontent.com/karol-broda/snitch/master/install.sh | sudo bash

echo ""
echo "===================================================================================================="
echo "== Snitch installation complete!"
echo "===================================================================================================="
