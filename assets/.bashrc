# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# http://stackoverflow.com/questions/9457233/unlimited-bash-history
HISTSIZE=
HISTFILESIZE=
HISTFILE=~/.bash_eternal_history
PROMPT_COMMAND="history -a; history -n"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm-color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
  xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
  *)
    ;;
esac

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

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
  . /etc/bash_completion
fi

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

# Kube
# https://raw.githubusercontent.com/jonmosco/kube-ps1/master/kube-ps1.sh
if [ -f ~/.kube-ps1.sh ]; then
  source ~/.kube-ps1.sh
fi

################################################################
## Colors
################################################################

# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Underline
UBlack='\e[4;30m'       # Black
URed='\e[4;31m'         # Red
UGreen='\e[4;32m'       # Green
UYellow='\e[4;33m'      # Yellow
UBlue='\e[4;34m'        # Blue
UPurple='\e[4;35m'      # Purple
UCyan='\e[4;36m'        # Cyan
UWhite='\e[4;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

# High Intensity
IBlack='\e[0;90m'       # Black
IRed='\e[0;91m'         # Red
IGreen='\e[0;92m'       # Green
IYellow='\e[0;93m'      # Yellow
IBlue='\e[0;94m'        # Blue
IPurple='\e[0;95m'      # Purple
ICyan='\e[0;96m'        # Cyan
IWhite='\e[0;97m'       # White

# Bold High Intensity
BIBlack='\e[1;90m'      # Black
BIRed='\e[1;91m'        # Red
BIGreen='\e[1;92m'      # Green
BIYellow='\e[1;93m'     # Yellow
BIBlue='\e[1;94m'       # Blue
BIPurple='\e[1;95m'     # Purple
BICyan='\e[1;96m'       # Cyan
BIWhite='\e[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\e[0;100m'   # Black
On_IRed='\e[0;101m'     # Red
On_IGreen='\e[0;102m'   # Green
On_IYellow='\e[0;103m'  # Yellow
On_IBlue='\e[0;104m'    # Blue
On_IPurple='\e[0;105m'  # Purple
On_ICyan='\e[0;106m'    # Cyan
On_IWhite='\e[0;107m'   # White

################################################################
## Commandline
################################################################

MEM_FREE="$(($(sed -n 's/MemFree:[\t ]\+\([0-9]\+\) kB/\1/p' /proc/meminfo) / 1024))"
MEM_TOTAL="$(($(sed -n 's/MemTotal:[\t ]\+\([0-9]\+\) kB/\1/p' /proc/meminfo) / 1024))"
export PS1="\t \[$Red\]\u\[$Color_Off\]@\[$Green\]\h\[$Color_Off\]:\$(pwd)\[$IBlue\]\$(__git_ps1)\$(kube_ps1) \[$Red\]>\[$Color_Off\] "

################################################################
## PATH
################################################################

#export PATH=$PATH:/code/java/jdk/bin/

#################################################################
## Timezone
################################################################

export TZ='Europe/Vienna'

################################################################
## NVM
################################################################

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

################################################################
## Aliases
################################################################

export TERM=xterm-256color

## Command Helpers
alias ..='cd ..'

alias h='history'
alias j='jobs -l'

alias list_size='du -chs *'
alias list_sort='du -chs * | sort -h'

alias symlink='ln -sf'

## Git
alias gc='git commit'
alias gco='git checkout'
alias gs='git status'
alias gpp='git pull && git push'
alias gid='git rev-parse --short HEAD'
alias grh='git reset --hard HEAD'

function gc() {
  git commit -m "$1"
}

function git-recursive() {
  find . -type d -name .git -exec sh -c "cd \"{}\"/../ && pwd && git $1" \;
}

## Docker
alias dc='docker-compose'
# export DOCKER_HOST=localhost:2375
export DOCKER_HOST=unix:///var/run/docker.sock

alias docker_cleanup_images='docker image prune'
alias docker_cleanup_system='docker system prune'

alias docker_remove_dangling_images='docker rmi $(docker images -f "dangling=true" -q)'
alias docker_remove_exited_containers='docker rm -v $(docker ps -a -q -f status=exited)'

## Docker Containers
alias portainer='docker pull portainer/portainer-ce:latest && \
  docker run \
  -d \
  --rm \
  --name portainer \
  -p 9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data portainer/portainer-ce'
# --rm
# --restart unless-stopped

## Packing
alias pack_tar='tar -vcf'
alias pack_targz='tar -vczf'
alias pack_tarxz='tar -vcJf'
alias pack_tarbz2='tar -vcjf'
alias pack_zip='zip -r'
alias pack_bz2='bzip2 --keep'

## Unpacking
alias unpack_tar='tar -vxf'
alias unpack_targz='tar -vxzf'
alias unpack_tarxz='tar -vxJf'
alias unpack_tarbz2='tar -vxjf'
alias unpack_zip='unzip'
alias unpack_bz2='bunzip2 --keep --force'

## Ports
alias check_ports1='netstat -ntap'
alias check_ports2='netstat -ntl'
alias check_ports_pid='netstat -lp --inet'

## Raspberry Pi
alias route_usb='route add default gw 192.168.7.1'
alias time_set='dpkg-reconfigure tzdata'
alias time_fix='ntpdate -u time.cloudflare.com'
alias wanip='dig +short myip.opendns.com @resolver1.opendns.com'

## Status
alias ram='top -n 1 | grep "Mem"'
alias cpu='top -n 1 | grep "Cpu"'
alias topn='top -n 1'
alias top_cpu='top -o %CPU'
alias top_ram='top -o %MEM'

## Misc
alias lua='rlwrap luajit -l essentials'

## WSL
# mount /mnt/c to /c if not already done
# if [ ! -d "/c" ] || [ ! "$(ls -A /c)" ]; then
#   # echo "Requiring root password to $(tput setaf 6)mount --bind /mnt/c /c$(tput sgr 0)"
#   # sudo mkdir -p /c
#   # sudo mount --bind /mnt/c /c
#   mkdir -p /c
#   mount --bind /mnt/c /c
# fi

# Change from /mnt/c/... to /c/...
# if [ "$(pwd | cut -c -7)" == "/mnt/c/" ]; then
# 	cd "$(pwd | cut -c 5-)"
# fi

# if [ "$(umask)" = "0000" ]; then
#   umask 0022
# fi

# if [ "$(pwd)" == "/root" ]; then
#   cd "/code"
# fi

# if [ -z "$(docker ps -a | grep portainer)" ]; then
#   portainer
# fi
