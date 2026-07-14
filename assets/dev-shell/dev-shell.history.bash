# shellcheck shell=bash

################################################################
## History
################################################################

HISTCONTROL=ignoreboth
HISTSIZE=
HISTFILESIZE=
HISTFILE="$HOME/.bash_eternal_history"

shopt -s histappend
shopt -s checkwinsize

if [[ "${PROMPT_COMMAND:-}" != *"history -a; history -n"* ]]; then
	if [ -n "${PROMPT_COMMAND:-}" ]; then
		PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"
	else
		PROMPT_COMMAND="history -a; history -n"
	fi
fi
