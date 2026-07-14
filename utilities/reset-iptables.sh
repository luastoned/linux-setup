#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

IPT="${IPTABLES_BIN:-/sbin/iptables}"
assumeYes=0
dryRun=0

function printUsage {
	cat <<EOF
Usage: bash utilities/reset-iptables.sh [options]

Reset the filter, NAT, and mangle tables and set the built-in chain policies
to ACCEPT.

Options:
  -y, --yes      Skip the confirmation prompt.
      --dry-run  Print the iptables commands without running them.
  -h, --help     Show this help message.
EOF
}

function runIptables {
	if [[ "$dryRun" == 1 ]]; then
		printf '[dry-run] sudo'
		printf ' %q' "$IPT" "$@"
		printf '\n'
	else
		sudoCommand "$IPT" "$@"
	fi
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	-y | --yes)
		assumeYes=1
		shift
		;;
	--dry-run)
		dryRun=1
		shift
		;;
	-h | --help)
		printUsage
		exit 0
		;;
	*)
		echo "Unknown option: $1" >&2
		blankLine >&2
		printUsage >&2
		exit 1
		;;
	esac
done

printBanner "Resetting iptables rules ..."
blankLine

if [[ "$dryRun" != 1 && "$assumeYes" != 1 ]]; then
	read -r -p "This will flush the current iptables rules. Continue? (y/N): " reply
	if [[ ! "$reply" =~ ^[Yy]([Ee][Ss])?$ ]]; then
		echo "Operation cancelled."
		exit 0
	fi
fi

if [[ "$dryRun" != 1 && ! -x "$IPT" ]]; then
	echo "iptables command not found or not executable: $IPT" >&2
	exit 1
fi

# Set default policies for all three default chains
runIptables -P INPUT ACCEPT
runIptables -P FORWARD ACCEPT
runIptables -P OUTPUT ACCEPT

# Flush old rules, old custom tables
runIptables --flush
runIptables --delete-chain
runIptables -t nat --flush
runIptables -t mangle --flush

blankLine
printBanner "iptables reset complete!"
