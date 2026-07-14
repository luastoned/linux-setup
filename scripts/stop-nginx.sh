#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

printBanner "Stopping and disabling Nginx ..."
blankLine
## stop any running nginx instance
echo "Stopping Nginx service ..."
sudoCommand service nginx stop 2>/dev/null || echo "Nginx service not running"

blankLine
## prevent nginx from starting on boot
echo "Disabling Nginx from starting on boot ..."
sudoCommand systemctl disable nginx 2>/dev/null || true
sudoCommand update-rc.d -f nginx disable 2>/dev/null || true

blankLine
printBanner "Nginx stopped and disabled!"
