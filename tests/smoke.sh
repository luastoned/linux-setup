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

printf '# local stale managed file\n' >"$bashrcConfig/dev-shell.node.bash"
HOME="$bashrcHome" XDG_CONFIG_HOME="$bashrcConfig" bash scripts/bashrc.sh >/dev/null
cmp -s assets/dev-shell/dev-shell.node.bash "$bashrcConfig/dev-shell.node.bash"
[[ "$(find "$bashrcConfig" -maxdepth 1 -name 'dev-shell.node.bash.bak.*' | wc -l)" -eq 1 ]]
HOME="$bashrcHome" XDG_CONFIG_HOME="$bashrcConfig" bash scripts/bashrc.sh >/dev/null
[[ "$(find "$bashrcConfig" -maxdepth 1 -name 'dev-shell.node.bash.bak.*' | wc -l)" -eq 1 ]]
pass "managed dev-shell backup and idempotence"

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
printf 'another old nano config\n' >"$configHome/.nanorc"
HOME="$configHome" bash scripts/configs.sh >/dev/null
[[ "$(find "$configHome" -maxdepth 1 -name '.nanorc.bak.*' | wc -l)" -eq 2 ]]
pass "user config backup and idempotence"

sshHome="$TMP_ROOT/ssh-home"
sshdConfig="$TMP_ROOT/sshd_config"
install -m 0755 -d "$sshHome/.ssh"
printf 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAITest personal-key\n' >"$sshHome/.ssh/authorized_keys"
printf '#AuthorizedKeysFile .ssh/authorized_keys\n' >"$sshdConfig"
HOME="$sshHome" SSHD_CONFIG_FILE="$sshdConfig" SSHD_BIN=/bin/true bash scripts/ssh-keys.sh >/dev/null
grep -qx 'AuthorizedKeysFile .ssh/authorized_keys' "$sshdConfig"
[[ "$(find "$TMP_ROOT" -maxdepth 1 -name 'sshd_config.bak.*' | wc -l)" -eq 1 ]]
[[ "$(find "$sshHome/.ssh" -maxdepth 1 -name 'authorized_keys.bak.*' | wc -l)" -eq 1 ]]
HOME="$sshHome" SSHD_CONFIG_FILE="$sshdConfig" SSHD_BIN=/bin/true bash scripts/ssh-keys.sh >/dev/null
[[ "$(find "$TMP_ROOT" -maxdepth 1 -name 'sshd_config.bak.*' | wc -l)" -eq 1 ]]
[[ "$(find "$sshHome/.ssh" -maxdepth 1 -name 'authorized_keys.bak.*' | wc -l)" -eq 1 ]]
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
	DOCKER_CONFIG_DIR="$dockerConfig" LOG_MAX_SIZE=25m LOG_MAX_FILE=5 \
		bash utilities/docker-logs-rotation.sh >/dev/null
	[[ "$(find "$dockerConfig" -maxdepth 1 -name 'daemon.json.bak.*' | wc -l)" -eq 1 ]]
	pass "Docker daemon JSON merge and idempotence"
else
	echo "SKIP: Docker daemon JSON merge (jq not installed)"
fi

inotifyFile="$TMP_ROOT/99-linux-setup-inotify.conf"
printf 'fs.inotify.max_user_watches=123\n' >"$inotifyFile"
SYSCTL_FILE="$inotifyFile" APPLY_SYSCTL=0 bash scripts/inotify.sh >/dev/null
grep -qx 'fs.inotify.max_user_instances=8192' "$inotifyFile"
grep -qx 'fs.inotify.max_user_watches=1048576' "$inotifyFile"
grep -qx 'fs.inotify.max_queued_events=2097152' "$inotifyFile"
[[ "$(find "$TMP_ROOT" -maxdepth 1 -name '99-linux-setup-inotify.conf.bak.*' | wc -l)" -eq 1 ]]
SYSCTL_FILE="$inotifyFile" APPLY_SYSCTL=0 bash scripts/inotify.sh >/dev/null
[[ "$(find "$TMP_ROOT" -maxdepth 1 -name '99-linux-setup-inotify.conf.bak.*' | wc -l)" -eq 1 ]]
pass "inotify config backup and no-apply test path"

kubePs1Config="$TMP_ROOT/kube-ps1-config"
kubePs1Source="$TMP_ROOT/kube-ps1-source.sh"
install -m 0755 -d "$kubePs1Config"
printf '# old kube prompt\n' >"$kubePs1Config/dev-shell.kube-ps1.sh"
printf '# test kube prompt\nfunction kube_ps1 { printf test; }\n' >"$kubePs1Source"
XDG_CONFIG_HOME="$kubePs1Config" KUBE_PS1_URL="file://$kubePs1Source" \
	bash utilities/install-kube-ps1.sh --force >/dev/null
cmp -s "$kubePs1Source" "$kubePs1Config/dev-shell.kube-ps1.sh"
[[ "$(find "$kubePs1Config" -maxdepth 1 -name 'dev-shell.kube-ps1.sh.bak.*' | wc -l)" -eq 1 ]]
XDG_CONFIG_HOME="$kubePs1Config" KUBE_PS1_URL="file://$kubePs1Source" \
	bash utilities/install-kube-ps1.sh --force >/dev/null
[[ "$(find "$kubePs1Config" -maxdepth 1 -name 'dev-shell.kube-ps1.sh.bak.*' | wc -l)" -eq 1 ]]
pass "kube-ps1 validation, backup, and idempotence"

iptablesDryRun="$(bash utilities/reset-iptables.sh --dry-run)"
grep -q '\[dry-run\].*iptables.*--flush' <<<"$iptablesDryRun"
[[ "$(grep -c '^\[dry-run\]' <<<"$iptablesDryRun")" -eq 7 ]]
pass "iptables dry run"

echo "All smoke tests passed."
