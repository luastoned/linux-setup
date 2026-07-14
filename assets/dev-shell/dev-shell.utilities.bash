# shellcheck shell=bash

################################################################
## General Utilities
################################################################

alias h='history'
alias j='jobs -l'
alias reload='source ~/.bashrc'

alias list_size='du -chs *'
alias list_sort='du -chs * | sort -h'
alias symlink='ln -sf'

if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
	alias bat='batcat'
fi

function show_ssh {
	if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
		echo "ED25519:"
		cat "$HOME/.ssh/id_ed25519.pub"
	fi

	if [ -f "$HOME/.ssh/id_rsa.pub" ]; then
		echo "RSA:"
		cat "$HOME/.ssh/id_rsa.pub"
	fi
}

alias show-ssh='show_ssh'

function edit_dev_shell {
	local configDir="${XDG_CONFIG_HOME:-$HOME/.config}"
	local localFile="$configDir/dev-shell.local.bash"

	install -m 0755 -d "$configDir"
	"${EDITOR:-nano}" "$localFile"
	if [ -r "$localFile" ]; then
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
	*.tar.bz2 | *.tbz2) tar xjf "$archive" ;;
	*.tar.gz | *.tgz) tar xzf "$archive" ;;
	*.tar.xz | *.txz) tar xJf "$archive" ;;
	*.bz2) bunzip2 "$archive" ;;
	*.rar) rar x "$archive" ;;
	*.gz) gunzip "$archive" ;;
	*.tar) tar xf "$archive" ;;
	*.zip) unzip "$archive" ;;
	*.Z) uncompress "$archive" ;;
	*.7z) 7z x "$archive" ;;
	*.xz) xz -d "$archive" ;;
	*) echo "'$archive' cannot be extracted via extract()" ;;
	esac
}

alias pack_tar='tar -vcf'
alias pack_targz='tar -vczf'
alias pack_tarxz='tar -vcJf'
alias pack_tarbz2='tar -vcjf'
alias pack_zip='zip -r'
alias pack_bz2='bzip2 --keep'

alias unpack_tar='tar -vxf'
alias unpack_targz='tar -vxzf'
alias unpack_tarxz='tar -vxJf'
alias unpack_tarbz2='tar -vxjf'
alias unpack_zip='unzip'
alias unpack_bz2='bunzip2 --keep --force'

alias ram='top -n 1 | grep "Mem"'
alias cpu='top -n 1 | grep "Cpu"'
alias topn='top -n 1'
alias top_cpu='top -o %CPU'
alias top_ram='top -o %MEM'

alias check_ports1='netstat -ntap'
alias check_ports2='netstat -ntl'
alias check_ports_pid='netstat -lp --inet'
alias wanip='dig +short myip.opendns.com @resolver1.opendns.com'

alias nodemod_list='find . -name "node_modules" -type d -prune'

function nodemod_remove {
	local reply

	read -r -p "Remove all node_modules directories below this directory? (y/N): " reply
	if [[ ! "$reply" =~ ^[Yy]([Ee][Ss])?$ ]]; then
		echo "Cancelled."
		return 0
	fi

	find . -name "node_modules" -type d -prune -exec rm -rf "{}" +
}

function vscode_kill {
	pgrep -f '\.vscode-server.*node' | xargs --no-run-if-empty kill
}

function free_ram {
	sync
	echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null
}
