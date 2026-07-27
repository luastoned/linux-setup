# dev-shell.bash
#
# Managed by linux-setup; changes may be replaced on the next setup run.
# Put personal customizations in dev-shell.local.bash.
# Keep this file sourced from ~/.bashrc instead of replacing ~/.bashrc outright.

[[ $- == *i* ]] || return 0

DEV_SHELL_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

function dev_shell_command_exists {
	command -v "$1" >/dev/null 2>&1
}

# shellcheck disable=SC2317 # Called by conditionally sourced Node and Kubernetes assets.
function dev_shell_prepend_path {
	local directory="$1"

	case ":$PATH:" in
	*":$directory:"*) ;;
	*) export PATH="$directory:$PATH" ;;
	esac
}

function dev_shell_confirm {
	local prompt="${1:-Continue?}"
	local reply

	read -r -p "$prompt (y/N): " reply
	[[ "$reply" =~ ^[Yy]([Ee][Ss])?$ ]]
}

function dev_shell_source {
	local name="$1"
	local file="$DEV_SHELL_CONFIG_DIR/dev-shell.$name.bash"

	if [ -r "$file" ]; then
		# shellcheck source=/dev/null
		source "$file"
	fi
}

function dev_shell_is_wsl {
	grep -qi "microsoft" /proc/version 2>/dev/null
}

function dev_shell_is_rpi {
	grep -qi "raspberry" /proc/device-tree/model 2>/dev/null ||
		grep -qi "raspberry" /proc/cpuinfo 2>/dev/null
}

function dev_shell_has_docker {
	dev_shell_command_exists docker ||
		[ -S /var/run/docker.sock ]
}

function dev_shell_has_kubernetes {
	dev_shell_command_exists kubectl ||
		dev_shell_command_exists k3d ||
		dev_shell_command_exists helm ||
		[ -n "${KUBECONFIG:-}" ] ||
		[ -f "$HOME/.kube/config" ]
}

function dev_shell_has_node {
	dev_shell_command_exists node ||
		dev_shell_command_exists yarn ||
		[ -s "$HOME/.nvm/nvm.sh" ] ||
		[ -x "$HOME/.nub/bin/nub" ]
}

dev_shell_source history
dev_shell_source completions
dev_shell_source git
dev_shell_source utilities

dev_shell_has_node && dev_shell_source node
dev_shell_has_docker && dev_shell_source docker
dev_shell_has_kubernetes && dev_shell_source kubernetes
dev_shell_is_wsl && dev_shell_source wsl
dev_shell_is_rpi && dev_shell_source rpi

dev_shell_source prompt
dev_shell_source local

unset -f dev_shell_prepend_path
unset -f dev_shell_source
unset DEV_SHELL_CONFIG_DIR
