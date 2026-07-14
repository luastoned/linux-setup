# shellcheck shell=bash

################################################################
## Git Completion and Prompt Helpers
################################################################

if ! complete -p git >/dev/null 2>&1 && [ -r /usr/share/bash-completion/completions/git ]; then
	source /usr/share/bash-completion/completions/git
fi

if [ -r /usr/lib/git-core/git-sh-prompt ]; then
	source /usr/lib/git-core/git-sh-prompt
elif [ -r /etc/bash_completion.d/git-prompt ]; then
	source /etc/bash_completion.d/git-prompt
fi

################################################################
## Git Aliases and Functions
################################################################

alias gs='git status'
alias gp='git pull'
alias gco='git checkout'
alias gsa='git status && git add . && git status'
alias gpp='git pull && git push'
alias gid='git rev-parse --short HEAD'
alias gmo='git fetch origin && git merge origin/development'

function gc {
	git commit -m "$1"
}

function gout {
	git checkout "$1"
}

function gbout {
	git checkout -b "$1"
}

function git_recursive {
	local gitDir
	local repo

	find . -type d -name .git -prune | while IFS= read -r gitDir; do
		repo="${gitDir%/.git}"
		printf '\n%s\n' "$repo"
		(cd "$repo" && git "$@")
	done
}

alias git-recursive='git_recursive'
