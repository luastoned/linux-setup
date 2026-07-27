# shellcheck shell=bash
# Managed by linux-setup; changes may be replaced on the next setup run.
# Put personal customizations in dev-shell.local.bash.

################################################################
## Prompt
################################################################

function dev_shell_git_ps1 {
	if declare -F __git_ps1 >/dev/null 2>&1; then
		__git_ps1
	fi
}

function dev_shell_kube_ps1 {
	if declare -F kube_ps1 >/dev/null 2>&1; then
		kube_ps1
	fi
}

DS_RESET='\[\e[0m\]'
DS_WHITE='\[\e[1;37m\]'
DS_RED='\[\e[0;91m\]'
DS_GREEN='\[\e[0;92m\]'
DS_BLUE='\[\e[0;94m\]'

PS1="${DS_WHITE}\t${DS_RESET} ${DS_RED}\u${DS_RESET}@${DS_GREEN}\h${DS_RESET}:\w${DS_BLUE}\$(dev_shell_git_ps1)${DS_RESET}\$(dev_shell_kube_ps1) ${DS_RED}>${DS_RESET} "

case "$TERM" in
xterm* | rxvt*)
	PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
	;;
*) ;;
esac

unset DS_RESET DS_WHITE DS_RED DS_GREEN DS_BLUE
