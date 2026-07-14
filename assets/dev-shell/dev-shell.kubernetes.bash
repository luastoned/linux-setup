# shellcheck shell=bash

################################################################
## Kubernetes
################################################################

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

if [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/dev-shell.kube-ps1.sh" ]; then
	# shellcheck source=/dev/null
	source "${XDG_CONFIG_HOME:-$HOME/.config}/dev-shell.kube-ps1.sh"

	function dev_shell_kube_cluster_short {
		echo "$1" | cut -d _ -f 4
	}

	# shellcheck disable=SC2034 # kube-ps1 reads these variables when rendering the prompt.
	KUBE_PS1_PREFIX=' ('
	# shellcheck disable=SC2034 # kube-ps1 reads these variables when rendering the prompt.
	KUBE_PS1_CTX_COLOR=yellow
	# shellcheck disable=SC2034 # kube-ps1 reads these variables when rendering the prompt.
	KUBE_PS1_SYMBOL_ENABLE=false
	# KUBE_PS1_CLUSTER_FUNCTION=dev_shell_kube_cluster_short
fi

alias kubectx='kubectl ctx'
alias kubns='kubectl ns'
alias kgp='kubectl get pods'
alias kgd='kubectl get deploy'
alias kgs='kubectl get svc'
alias wkgp='watch kubectl get pods'
