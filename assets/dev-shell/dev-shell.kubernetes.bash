# shellcheck shell=bash
# Managed by linux-setup; changes may be replaced on the next setup run.
# Put personal customizations in dev-shell.local.bash.

################################################################
## Kubernetes
################################################################

export KREW_ROOT="${KREW_ROOT:-$HOME/.krew}"
dev_shell_prepend_path "$KREW_ROOT/bin"

if [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/dev-shell.kube-ps1.sh" ]; then
	# shellcheck source=/dev/null
	source "${XDG_CONFIG_HOME:-$HOME/.config}/dev-shell.kube-ps1.sh"

	# shellcheck disable=SC2034 # kube-ps1 reads these variables when rendering the prompt.
	KUBE_PS1_PREFIX=' ('
	# shellcheck disable=SC2034 # kube-ps1 reads these variables when rendering the prompt.
	KUBE_PS1_CTX_COLOR=yellow
	# shellcheck disable=SC2034 # kube-ps1 reads these variables when rendering the prompt.
	KUBE_PS1_SYMBOL_ENABLE=false
fi

if command -v kubectl-ctx >/dev/null 2>&1; then
	alias kubectx='kubectl ctx'
fi

if command -v kubectl-ns >/dev/null 2>&1; then
	alias kubens='kubectl ns'
fi

alias kgp='kubectl get pods'
alias kgd='kubectl get deploy'
alias kgs='kubectl get svc'

function wkgp {
	watch -- kubectl get pods "$@"
}
