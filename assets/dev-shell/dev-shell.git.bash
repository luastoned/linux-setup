# shellcheck shell=bash
# Managed by linux-setup; changes may be replaced on the next setup run.
# Put personal customizations in dev-shell.local.bash.

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
alias gid='git rev-parse --short HEAD'
alias gsw='git switch'
alias gsc='git switch --create'
alias grs='git restore'
alias ga='git add'
alias gap='git add --patch'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit --message'
alias gl='git pull --ff-only'

if declare -F __git_complete >/dev/null 2>&1; then
	__git_complete gs _git_status
	__git_complete gsw _git_switch
	__git_complete gsc _git_switch
	__git_complete grs _git_restore
	__git_complete ga _git_add
	__git_complete gap _git_add
	__git_complete gaa _git_add
	__git_complete gc _git_commit
	__git_complete gcm _git_commit
	__git_complete gl _git_pull
fi

function git_recursive {
	if [ $# -eq 0 ]; then
		echo "Usage: git-recursive <git arguments...>"
		return 1
	fi

	local gitMarker
	local repo
	local status=0

	while IFS= read -r -d '' gitMarker; do
		repo="${gitMarker%/.git}"
		printf '\n%s\n' "$repo"
		if ! git -C "$repo" "$@"; then
			status=1
		fi
	done < <(find . -name .git \( -type d -o -type f \) -prune -print0)

	return "$status"
}

alias git-recursive='git_recursive'
