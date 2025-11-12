# ~/.bashrc: executed by bash(1) for non-login shells.

################################################################
## Early Exit for Non-Interactive Shells
################################################################

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

################################################################
## Shell Options
################################################################

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# unlimited bash history
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
HISTSIZE=
HISTFILESIZE=
HISTFILE=~/.bash_eternal_history
PROMPT_COMMAND="history -a; history -n"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

################################################################
## Terminal Setup
################################################################

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# enable 256 color support
export TERM=xterm-256color

################################################################
## Colors Definition
################################################################

# Terminal Control Escape Sequences
# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
# Inspired by http://wiki.archlinux.org/index.php/Color_Bash_Prompt#List_of_colors_for_prompt_and_Bash

RCol='\[\e[0m\]' # Text Reset

# Regular Colors
Bla='\[\e[0;30m\]'; Red='\[\e[0;31m\]'; Gre='\[\e[0;32m\]'; Yel='\[\e[0;33m\]'
Blu='\[\e[0;34m\]'; Pur='\[\e[0;35m\]'; Cya='\[\e[0;36m\]'; Whi='\[\e[0;37m\]'

# Bold Colors
BBla='\[\e[1;30m\]'; BRed='\[\e[1;31m\]'; BGre='\[\e[1;32m\]'; BYel='\[\e[1;33m\]'
BBlu='\[\e[1;34m\]'; BPur='\[\e[1;35m\]'; BCya='\[\e[1;36m\]'; BWhi='\[\e[1;37m\]'

# Underline Colors
UBla='\[\e[4;30m\]'; URed='\[\e[4;31m\]'; UGre='\[\e[4;32m\]'; UYel='\[\e[4;33m\]'
UBlu='\[\e[4;34m\]'; UPur='\[\e[4;35m\]'; UCya='\[\e[4;36m\]'; UWhi='\[\e[4;37m\]'

# High Intensity Colors
IBla='\[\e[0;90m\]'; IRed='\[\e[0;91m\]'; IGre='\[\e[0;92m\]'; IYel='\[\e[0;93m\]'
IBlu='\[\e[0;94m\]'; IPur='\[\e[0;95m\]'; ICya='\[\e[0;96m\]'; IWhi='\[\e[0;97m\]'

# Bold High Intensity Colors
BIBla='\[\e[1;90m\]'; BIRed='\[\e[1;91m\]'; BIGre='\[\e[1;92m\]'; BIYel='\[\e[1;93m\]'
BIBlu='\[\e[1;94m\]'; BIPur='\[\e[1;95m\]'; BICya='\[\e[1;96m\]'; BIWhi='\[\e[1;97m\]'

# Background Colors
On_Bla='\e[40m'; On_Red='\e[41m'; On_Gre='\e[42m'; On_Yel='\e[43m'
On_Blu='\e[44m'; On_Pur='\e[45m'; On_Cya='\e[46m'; On_Whi='\e[47m'

# High Intensity Background Colors
On_IBla='\[\e[0;100m\]'; On_IRed='\[\e[0;101m\]'; On_IGre='\[\e[0;102m\]'; On_IYel='\[\e[0;103m\]'
On_IBlu='\[\e[0;104m\]'; On_IPur='\[\e[0;105m\]'; On_ICya='\[\e[0;106m\]'; On_IWhi='\[\e[0;107m\]'

################################################################
## Prompt Configuration
################################################################

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		color_prompt=yes
	else
		color_prompt=
	fi
fi

# Configure the prompt
if [ "$color_prompt" = yes ]; then
	# Custom colored prompt with time, user, host, pwd, git branch, and kube context
	export PS1="${BWhi}\t${RCol} ${IRed}\u${RCol}@${IGre}\h${RCol}:\$(pwd)${IBlu}\$(__git_ps1)${RCol}\$(kube_ps1) ${IRed}>${RCol} "
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
	PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
	;;
*) ;;
esac

################################################################
## Color Support for Commands
################################################################

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	alias dir='dir --color=auto'
	alias vdir='vdir --color=auto'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

################################################################
## Basic Aliases
################################################################

# ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

################################################################
## Bash Completion
################################################################

# Alias definitions
if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

# enable programmable completion features
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

################################################################
## Git Integration
################################################################

# Git Completion
# https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
if [ -f ~/.git-completion.bash ]; then
	source ~/.git-completion.bash
fi

# Git Prompt
# https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
if [ -f ~/.git-prompt.sh ]; then
	source ~/.git-prompt.sh
fi

################################################################
## Kubernetes Integration
################################################################

# Kube PS1
# https://raw.githubusercontent.com/jonmosco/kube-ps1/master/kube-ps1.sh
if [ -f ~/.kube-ps1.sh ]; then
	source ~/.kube-ps1.sh

	function get_cluster_short {
		echo "$1" | cut -d _ -f 4
	}

	KUBE_PS1_PREFIX=' ('
	KUBE_PS1_CTX_COLOR=yellow
	KUBE_PS1_SYMBOL_ENABLE=false
	# KUBE_PS1_CLUSTER_FUNCTION=get_cluster_short
fi

# Krew (kubectl plugin manager)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
alias kubectx="kubectl ctx"
alias kubns="kubectl ns"

################################################################
## Environment Variables
################################################################

# Timezone
export TZ='Europe/Vienna'

# Docker
export DOCKER_HOST=unix:///var/run/docker.sock
# export DOCKER_HOST=localhost:2375

################################################################
## NVM (Node Version Manager)
################################################################

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

################################################################
## Helper Functions
################################################################

# Check if running in WSL
function isWSL {
	grep -q "microsoft" /proc/version
	return $?
}

# Check if hostname is specific servers
function isCore {
	[[ "$(hostname)" == "23core" ]]
	return $?
}

function isZen {
	[[ "$(hostname)" == "zen23" ]]
	return $?
}

# Extract most types of compressed files
function extract {
	echo "Extracting $1 ..."
	if [ -f "$1" ]; then
		case $1 in
		*.tar.bz2) tar xjf "$1" ;;
		*.tar.gz) tar xzf "$1" ;;
		*.bz2) bunzip2 "$1" ;;
		*.rar) rar x "$1" ;;
		*.gz) gunzip "$1" ;;
		*.tar) tar xf "$1" ;;
		*.tbz2) tar xjf "$1" ;;
		*.tgz) tar xzf "$1" ;;
		*.zip) unzip "$1" ;;
		*.Z) uncompress "$1" ;;
		*.7z) 7z x "$1" ;;
		*.xz) xz -d "$1" ;;
		*) echo "'$1' cannot be extracted via extract()" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}

# Run git command in all subdirectories with .git
function git-recursive {
	find . -type d -name .git -exec sh -c "cd \"{}\"/../ && pwd && git $1" \;
}

################################################################
## General Aliases
################################################################

# Navigation
# alias ..='cd ..'

# Command shortcuts
alias h='history'
alias j='jobs -l'
alias reload='source ~/.bashrc'

# File operations
alias list_size='du -chs *'
alias list_sort='du -chs * | sort -h'
alias symlink='ln -sf'

# Configuration
alias show-ssh='[ -f ~/.ssh/id_ed25519.pub ] && echo "ED25519:" && cat ~/.ssh/id_ed25519.pub; [ -f ~/.ssh/id_rsa.pub ] && echo "RSA:" && cat ~/.ssh/id_rsa.pub'
alias conf="nano ~/.bashrc && source ~/.bashrc"
alias config="nano ~/.bashrc && source ~/.bashrc"

# Tool aliases
alias bat="batcat"
alias yup="yarn upgrade-interactive --latest"
alias pm2-update="pm2 update && pm2 restart all --update-env"

################################################################
## Git Aliases
################################################################

alias gs='git status'
alias gp="git pull"
alias gco="git checkout"
alias gsa="git status && git add . && git status"
alias gpp='git pull && git push'
alias gid='git rev-parse --short HEAD'
alias grh='git reset --hard HEAD'
alias gmo='git fetch origin && git merge origin/development'

# Git commit with message
function gc {
	git commit -m "$1"
}

# Git checkout branch
function gout {
	git checkout "$1"
}

# Git checkout new branch
function gbout {
	git checkout -b "$1"
}

################################################################
## Docker Aliases
################################################################

alias dc='docker compose'
alias dcd="docker compose down"
alias dcl="docker compose logs -f --tail 256"
alias dcu="docker compose up -d && docker compose logs -f"
alias dcp='docker compose pull && docker compose up -d'
alias dcr='docker compose up -d --force-recreate --no-deps --build'

# Docker process management
alias drm='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'
alias dps='docker ps --format="table {{.Names}}\t{{.Image}}\t{{.Status}}"'

# Docker cleanup
alias docker_cleanup_images='docker image prune'
alias docker_cleanup_system='docker system prune'
alias docker_remove_dangling_images='docker rmi $(docker images -f "dangling=true" -q)'
alias docker_remove_exited_containers='docker rm -v $(docker ps -a -q -f status=exited)'

# Docker containers
alias portainer='docker pull portainer/portainer-ee:latest && \
  docker run -d --rm --name portainer -p 9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data portainer/portainer-ee:latest'

alias dtop='docker run --rm -it --name=ctop \
  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
  quay.io/vektorlab/ctop:latest'

################################################################
## Kubernetes Aliases
################################################################

alias kgp="kubectl get pods"
alias kgd="kubectl get deploy"
alias kgs="kubectl get svc"
alias wkgp="watch kubectl get pods"

################################################################
## Archive/Compression Aliases
################################################################

# Packing
alias pack_tar='tar -vcf'
alias pack_targz='tar -vczf'
alias pack_tarxz='tar -vcJf'
alias pack_tarbz2='tar -vcjf'
alias pack_zip='zip -r'
alias pack_bz2='bzip2 --keep'

# Unpacking
alias unpack_tar='tar -vxf'
alias unpack_targz='tar -vxzf'
alias unpack_tarxz='tar -vxJf'
alias unpack_tarbz2='tar -vxjf'
alias unpack_zip='unzip'
alias unpack_bz2='bunzip2 --keep --force'

################################################################
## System Monitoring Aliases
################################################################

alias ram='top -n 1 | grep "Mem"'
alias cpu='top -n 1 | grep "Cpu"'
alias topn='top -n 1'
alias top_cpu='top -o %CPU'
alias top_ram='top -o %MEM'

################################################################
## Network Aliases
################################################################

alias check_ports1='netstat -ntap'
alias check_ports2='netstat -ntl'
alias check_ports_pid='netstat -lp --inet'
alias wanip='dig +short myip.opendns.com @resolver1.opendns.com'

################################################################
## Maintenance Aliases
################################################################

alias nodemod_list='find . -name "node_modules" -type d -prune'
alias nodemod_remove='find . -name "node_modules" -type d -prune -exec rm -rf "{}" +'
alias vscode_kill='ps aux | grep .vscode-server | grep [n]ode | awk "{print \$2}" | xargs kill'
alias free_ram='sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null'

# Raspberry Pi specific
alias route_usb='route add default gw 192.168.7.1'
alias time_set='dpkg-reconfigure tzdata'
alias time_fix='ntpdate -u time.cloudflare.com'

################################################################
## WSL Specific Configuration
################################################################

if isWSL; then
	PREV_PWD=$(pwd)
	cd /c/ 2>/dev/null || true
	WINDOWS_USER=$(/c/Windows/System32/cmd.exe /c 'echo %USERNAME%' 2>/dev/null | sed -e 's/\r//g')
	if [ -n "$WINDOWS_USER" ]; then
		export PATH="/c/Windows/System32:/c/Users/$WINDOWS_USER/AppData/Local/Programs/Microsoft VS Code/bin:$PATH"
	fi
	cd "$PREV_PWD" || true
fi

# Auto-navigate to /code if starting in /root
if [[ "$(pwd)" == "/root" ]] && [[ -d "/code" ]]; then
	cd "/code" 2>/dev/null || true
fi

################################################################
## End of .bashrc
################################################################
