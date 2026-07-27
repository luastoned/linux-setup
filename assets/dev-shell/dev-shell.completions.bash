# shellcheck shell=bash
# Managed by linux-setup; changes may be replaced on the next setup run.
# Put personal customizations in dev-shell.local.bash.

################################################################
## Bash Completion
################################################################

if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		source /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		source /etc/bash_completion
	fi
fi

for completionFile in "${XDG_CONFIG_HOME:-$HOME/.config}"/dev-shell.*-completion.bash; do
	# shellcheck source=/dev/null
	[ -r "$completionFile" ] && source "$completionFile"
done
unset completionFile
