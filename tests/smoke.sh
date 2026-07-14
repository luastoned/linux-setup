#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d /tmp/linux-setup-smoke.XXXXXX)"

function cleanup {
	rm -rf -- "$TMP_ROOT"
}

trap cleanup EXIT

function pass {
	printf 'PASS: %s\n' "$1"
}

function fileHash {
	sha256sum "$1" | cut -d ' ' -f 1
}

cd "$ROOT_DIR"

defaultDryRun="$(./setup.sh --dry-run)"
grep -q 'update.sh' <<<"$defaultDryRun"
if grep -q 'stop-nginx.sh' <<<"$defaultDryRun"; then
	echo "Default dry run unexpectedly selected nginx" >&2
	exit 1
fi
onlyDryRun="$(./setup.sh --dry-run --only nginx)"
grep -q 'stop-nginx.sh' <<<"$onlyDryRun"
pass "setup module selection"

bashrcHome="$TMP_ROOT/bashrc-home"
bashrcConfig="$TMP_ROOT/bashrc-config"
install -m 0755 -d "$bashrcHome" "$bashrcConfig"
printf '# personal bashrc\nexport EXAMPLE=1\n' >"$bashrcHome/.bashrc"
HOME="$bashrcHome" XDG_CONFIG_HOME="$bashrcConfig" bash scripts/bashrc.sh >/dev/null
firstBashrcHash="$(fileHash "$bashrcHome/.bashrc")"
HOME="$bashrcHome" XDG_CONFIG_HOME="$bashrcConfig" bash scripts/bashrc.sh >/dev/null
secondBashrcHash="$(fileHash "$bashrcHome/.bashrc")"
[[ "$firstBashrcHash" == "$secondBashrcHash" ]]
[[ "$(grep -c '^# >>> linux-setup$' "$bashrcHome/.bashrc")" -eq 1 ]]
[[ "$(grep -c '^# <<< linux-setup$' "$bashrcHome/.bashrc")" -eq 1 ]]
pass "bashrc marker idempotence"

malformedHome="$TMP_ROOT/malformed-home"
malformedConfig="$TMP_ROOT/malformed-config"
install -m 0755 -d "$malformedHome"
printf '# >>> linux-setup\nkeep this line\n' >"$malformedHome/.bashrc"
malformedBefore="$(fileHash "$malformedHome/.bashrc")"
if HOME="$malformedHome" XDG_CONFIG_HOME="$malformedConfig" bash scripts/bashrc.sh >/dev/null 2>&1; then
	echo "Malformed bashrc marker unexpectedly succeeded" >&2
	exit 1
fi
[[ "$malformedBefore" == "$(fileHash "$malformedHome/.bashrc")" ]]
[[ ! -e "$malformedConfig" ]]
pass "malformed bashrc marker refusal"

HOME="$bashrcHome" XDG_CONFIG_HOME="$bashrcConfig" EDITOR=touch TERM=xterm-256color \
	bash --noprofile --norc -ic '
		source "$XDG_CONFIG_HOME/dev-shell.bash"
		alias config >/dev/null
		if alias conf >/dev/null 2>&1; then exit 1; fi
		edit_dev_shell
	' 2>/dev/null
[[ -f "$bashrcConfig/dev-shell.local.bash" ]]
HOME="$bashrcHome" XDG_CONFIG_HOME="$bashrcConfig" bash scripts/bashrc.sh >/dev/null
[[ -f "$bashrcConfig/dev-shell.local.bash" ]]
pass "persistent dev-shell local override"

configHome="$TMP_ROOT/config-home"
install -m 0755 -d "$configHome"
printf 'old nano config\n' >"$configHome/.nanorc"
printf 'old tmux config\n' >"$configHome/.tmux.conf"
HOME="$configHome" bash scripts/configs.sh >/dev/null
cmp -s assets/.nanorc "$configHome/.nanorc"
cmp -s assets/.tmux.conf "$configHome/.tmux.conf"
[[ "$(find "$configHome" -maxdepth 1 -name '.nanorc.bak.*' | wc -l)" -eq 1 ]]
[[ "$(find "$configHome" -maxdepth 1 -name '.tmux.conf.bak.*' | wc -l)" -eq 1 ]]
HOME="$configHome" bash scripts/configs.sh >/dev/null
[[ "$(find "$configHome" -maxdepth 1 -name '.nanorc.bak.*' | wc -l)" -eq 1 ]]
[[ "$(find "$configHome" -maxdepth 1 -name '.tmux.conf.bak.*' | wc -l)" -eq 1 ]]
pass "user config backup and idempotence"

sshHome="$TMP_ROOT/ssh-home"
sshdConfig="$TMP_ROOT/sshd_config"
install -m 0755 -d "$sshHome"
printf '#AuthorizedKeysFile .ssh/authorized_keys\n' >"$sshdConfig"
HOME="$sshHome" SSHD_CONFIG_FILE="$sshdConfig" SSHD_BIN=/bin/true bash scripts/ssh-keys.sh >/dev/null
grep -qx 'AuthorizedKeysFile .ssh/authorized_keys' "$sshdConfig"
[[ "$(find "$TMP_ROOT" -maxdepth 1 -name 'sshd_config.bak.*' | wc -l)" -eq 1 ]]
HOME="$sshHome" SSHD_CONFIG_FILE="$sshdConfig" SSHD_BIN=/bin/true bash scripts/ssh-keys.sh >/dev/null
[[ "$(find "$TMP_ROOT" -maxdepth 1 -name 'sshd_config.bak.*' | wc -l)" -eq 1 ]]
pass "SSH config validation and idempotence"

invalidSshdConfig="$TMP_ROOT/invalid_sshd_config"
printf '#AuthorizedKeysFile .ssh/authorized_keys\n' >"$invalidSshdConfig"
invalidSshdHash="$(fileHash "$invalidSshdConfig")"
if HOME="$sshHome" SSHD_CONFIG_FILE="$invalidSshdConfig" SSHD_BIN=/bin/false bash scripts/ssh-keys.sh >/dev/null 2>&1; then
	echo "Invalid SSH daemon configuration unexpectedly succeeded" >&2
	exit 1
fi
[[ "$invalidSshdHash" == "$(fileHash "$invalidSshdConfig")" ]]
[[ "$(find "$TMP_ROOT" -maxdepth 1 -name 'invalid_sshd_config.bak.*' | wc -l)" -eq 0 ]]
pass "failed SSH validation preserves original"

if command -v jq >/dev/null 2>&1; then
	dockerConfig="$TMP_ROOT/docker"
	install -m 0755 -d "$dockerConfig"
	printf '{"debug":true,"log-opts":{"labels":"service"}}\n' >"$dockerConfig/daemon.json"
	DOCKER_CONFIG_DIR="$dockerConfig" LOG_MAX_SIZE=25m LOG_MAX_FILE=5 \
		bash utilities/docker-logs-rotation.sh >/dev/null
	jq -e '
		.debug == true
		and .["log-driver"] == "json-file"
		and .["log-opts"].labels == "service"
		and .["log-opts"]["max-size"] == "25m"
		and .["log-opts"]["max-file"] == "5"
	' "$dockerConfig/daemon.json" >/dev/null
	[[ "$(find "$dockerConfig" -maxdepth 1 -name 'daemon.json.bak.*' | wc -l)" -eq 1 ]]
	pass "Docker daemon JSON merge"
else
	echo "SKIP: Docker daemon JSON merge (jq not installed)"
fi

iptablesDryRun="$(bash utilities/reset-iptables.sh --dry-run)"
grep -q '\[dry-run\].*iptables.*--flush' <<<"$iptablesDryRun"
[[ "$(grep -c '^\[dry-run\]' <<<"$iptablesDryRun")" -eq 7 ]]
pass "iptables dry run"

echo "All smoke tests passed."
