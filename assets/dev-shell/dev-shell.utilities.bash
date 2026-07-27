# shellcheck shell=bash
# Managed by linux-setup; changes may be replaced on the next setup run.
# Put personal customizations in dev-shell.local.bash.

################################################################
## General Utilities
################################################################

alias h='history'
alias j='jobs -l'
alias reload='source ~/.bashrc'

function sizes {
	(
		shopt -s dotglob nullglob
		local -a entries=(*)

		if [ "${#entries[@]}" -eq 0 ]; then
			echo "No files or directories found."
			return 0
		fi

		du -sh -- "${entries[@]}" | sort -h
	)
}

if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
	alias bat='batcat'
fi

function show_ssh {
	local keyFile
	local found=0

	if [ ! -d "$HOME/.ssh" ]; then
		echo "No SSH public keys found."
		return 0
	fi

	while IFS= read -r -d '' keyFile; do
		found=1
		printf '%s:\n' "${keyFile##*/}"
		cat -- "$keyFile"
	done < <(find "$HOME/.ssh" -maxdepth 1 -type f -name '*.pub' ! -name '*-cert.pub' -print0)

	if [ "$found" -eq 0 ]; then
		echo "No SSH public keys found."
	fi
}

alias show-ssh='show_ssh'

function edit_dev_shell {
	local configDir="${XDG_CONFIG_HOME:-$HOME/.config}"
	local localFile="$configDir/dev-shell.local.bash"
	local -a editorCommand

	read -r -a editorCommand <<<"${VISUAL:-${EDITOR:-nano}}"

	install -m 0755 -d "$configDir"
	"${editorCommand[@]}" "$localFile"
	if [ -r "$localFile" ]; then
		if ! bash -n "$localFile"; then
			echo "Not loading $localFile because it contains a syntax error."
			return 1
		fi

		# shellcheck source=/dev/null
		source "$localFile"
	fi
}

alias config='edit_dev_shell'

function extract {
	if [ $# -eq 0 ]; then
		echo "Usage: extract <archive>"
		return 1
	fi

	local archive="$1"
	echo "Extracting $archive ..."

	if [ ! -f "$archive" ]; then
		echo "'$archive' is not a valid file"
		return 1
	fi

	case "$archive" in
	*.tar.bz2 | *.tbz2) tar -xjf "$archive" ;;
	*.tar.gz | *.tgz) tar -xzf "$archive" ;;
	*.tar.xz | *.txz) tar -xJf "$archive" ;;
	*.tar.zst | *.tzst) tar --zstd -xf "$archive" ;;
	*.bz2) bunzip2 --keep -- "$archive" ;;
	*.rar) 7z x -- "$archive" ;;
	*.gz) gunzip --keep -- "$archive" ;;
	*.tar) tar -xf "$archive" ;;
	*.zip) unzip -- "$archive" ;;
	*.Z) uncompress "$archive" ;;
	*.7z) 7z x -- "$archive" ;;
	*.xz) xz --decompress --keep -- "$archive" ;;
	*.zst) zstd --decompress --keep -- "$archive" ;;
	*)
		echo "'$archive' cannot be extracted via extract()"
		return 1
		;;
	esac
}

function pack {
	if [ $# -lt 2 ]; then
		echo "Usage: pack <archive> <file-or-directory...>"
		return 1
	fi

	local archive="$1"
	shift

	if [ -e "$archive" ]; then
		echo "Refusing to overwrite existing archive: $archive"
		return 1
	fi

	case "$archive" in
	*.tar.gz | *.tgz) tar -czf "$archive" -- "$@" ;;
	*.tar.xz | *.txz) tar -cJf "$archive" -- "$@" ;;
	*.tar.bz2 | *.tbz2) tar -cjf "$archive" -- "$@" ;;
	*.tar.zst | *.tzst) tar --zstd -cf "$archive" -- "$@" ;;
	*.tar) tar -cf "$archive" -- "$@" ;;
	*.zip) zip -r -- "$archive" "$@" ;;
	*.7z) 7z a -- "$archive" "$@" ;;
	*)
		echo "Unsupported archive extension: $archive"
		return 1
		;;
	esac
}

alias memory='free -h'
alias top_cpu='top -o %CPU'
alias top_ram='top -o %MEM'

alias ports='ss -lntup'
alias public_ip='dig +short myip.opendns.com @resolver1.opendns.com'

alias nodemod_list='find . -name "node_modules" -type d -prune'

function nodemod_remove {
	local -a directories

	mapfile -d '' -t directories < <(find . -name node_modules -type d -prune -print0)
	if [ "${#directories[@]}" -eq 0 ]; then
		echo "No node_modules directories found."
		return 0
	fi

	printf 'Found %d node_modules directories:\n' "${#directories[@]}"
	printf '  %s\n' "${directories[@]}"

	if ! dev_shell_confirm "Remove these directories?"; then
		echo "Cancelled."
		return 0
	fi

	rm -rf -- "${directories[@]}"
}

function vscode_kill {
	local -a pids

	mapfile -t pids < <(pgrep -u "$(id -u)" -f '\.vscode-server.*node' || true)
	if [ "${#pids[@]}" -eq 0 ]; then
		echo "No VS Code server processes found for the current user."
		return 0
	fi

	if ! dev_shell_confirm "Stop ${#pids[@]} VS Code server process(es)?"; then
		echo "Cancelled."
		return 0
	fi

	kill -- "${pids[@]}"
}
