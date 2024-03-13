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

  function get_cluster_short {
    echo "$1" | cut -d _ -f 4
  }

  KUBE_PS1_PREFIX=' ('
  KUBE_PS1_CTX_COLOR=yellow
  KUBE_PS1_SYMBOL_ENABLE=false
  # KUBE_PS1_CLUSTER_FUNCTION=get_cluster_short
fi

################################################################
## Colors
################################################################

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux

### Colors to Vars ### {{{
## https://notabug.org/demure/dotfiles/src/master/subbash/prompt
## Inspired by http://wiki.archlinux.org/index.php/Color_Bash_Prompt#List_of_colors_for_prompt_and_Bash
## Terminal Control Escape Sequences: http://www.termsys.demon.co.uk/vtansi.htm
## Consider using some of: https://gist.github.com/bcap/5682077#file-terminal-control-sh
## Can unset with `unset -v {,B,U,I,BI,On_,On_I}{Bla,Red,Gre,Yel,Blu,Pur,Cya,Whi} RCol`

# |       | bash  | hex    | octal   | NOTE                         |
# |-------+-------+--------+---------+------------------------------|
# | start | \e    | \x1b   | \033    |                              |
# | start | \E    | \x1B   | -       | x cannot be capital          |
# | end   | \e[0m | \x1m0m | \033[0m |                              |
# | end   | \e[m  | \x1b[m | \033[m  | 0 is appended if you omit it |
# |       |       |        |         |                              |

RCol='\[\e[0m\]'  # Text Reset

# Regular           Bold                 Underline            High Intensity       BoldHigh Intensity    Background       High Intensity Backgrounds
Bla='\[\e[0;30m\]'; BBla='\[\e[1;30m\]'; UBla='\[\e[4;30m\]'; IBla='\[\e[0;90m\]'; BIBla='\[\e[1;90m\]'; On_Bla='\e[40m'; On_IBla='\[\e[0;100m\]';
Red='\[\e[0;31m\]'; BRed='\[\e[1;31m\]'; URed='\[\e[4;31m\]'; IRed='\[\e[0;91m\]'; BIRed='\[\e[1;91m\]'; On_Red='\e[41m'; On_IRed='\[\e[0;101m\]';
Gre='\[\e[0;32m\]'; BGre='\[\e[1;32m\]'; UGre='\[\e[4;32m\]'; IGre='\[\e[0;92m\]'; BIGre='\[\e[1;92m\]'; On_Gre='\e[42m'; On_IGre='\[\e[0;102m\]';
Yel='\[\e[0;33m\]'; BYel='\[\e[1;33m\]'; UYel='\[\e[4;33m\]'; IYel='\[\e[0;93m\]'; BIYel='\[\e[1;93m\]'; On_Yel='\e[43m'; On_IYel='\[\e[0;103m\]';
Blu='\[\e[0;34m\]'; BBlu='\[\e[1;34m\]'; UBlu='\[\e[4;34m\]'; IBlu='\[\e[0;94m\]'; BIBlu='\[\e[1;94m\]'; On_Blu='\e[44m'; On_IBlu='\[\e[0;104m\]';
Pur='\[\e[0;35m\]'; BPur='\[\e[1;35m\]'; UPur='\[\e[4;35m\]'; IPur='\[\e[0;95m\]'; BIPur='\[\e[1;95m\]'; On_Pur='\e[45m'; On_IPur='\[\e[0;105m\]';
Cya='\[\e[0;36m\]'; BCya='\[\e[1;36m\]'; UCya='\[\e[4;36m\]'; ICya='\[\e[0;96m\]'; BICya='\[\e[1;96m\]'; On_Cya='\e[46m'; On_ICya='\[\e[0;106m\]';
Whi='\[\e[0;37m\]'; BWhi='\[\e[1;37m\]'; UWhi='\[\e[4;37m\]'; IWhi='\[\e[0;97m\]'; BIWhi='\[\e[1;97m\]'; On_Whi='\e[47m'; On_IWhi='\[\e[0;107m\]';
### End Color Vars ### }}}

################################################################
## Commandline
################################################################

MEM_FREE="$(($(sed -n 's/MemFree:[\t ]\+\([0-9]\+\) kB/\1/p' /proc/meminfo) / 1024))"
MEM_TOTAL="$(($(sed -n 's/MemTotal:[\t ]\+\([0-9]\+\) kB/\1/p' /proc/meminfo) / 1024))"
export PS1="${BWhi}\t${RCol} ${IRed}\u${RCol}@${IGre}\h${RCol}:\$(pwd)${IBlu}\$(__git_ps1)${RCol}\$(kube_ps1) ${IRed}>${RCol} "

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
## KREW
################################################################

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
alias kubectx="kubectl ctx"
alias kubens="kubectl ns"

################################################################
## Aliases
################################################################

### Extract Function ### {{{
## Extract most types of compressed files
function extract {
  echo Extracting $1 ...
  if [ -f $1 ]; then
  case $1 in
      *.tar.bz2)  tar xjf $1      ;;
      *.tar.gz)   tar xzf $1      ;;
      *.bz2)      bunzip2 $1      ;;
      *.rar)      rar x $1        ;;
      *.gz)       gunzip $1       ;;
      *.tar)      tar xf $1       ;;
      *.tbz2)     tar xjf $1      ;;
      *.tgz)      tar xzf $1      ;;
      *.zip)      unzip $1        ;;
      *.Z)        uncompress $1   ;;
      *.7z)       7z x $1         ;;
      *.xz)       xz -d $1        ;;
      *)          echo "'$1' cannot be extracted via extract()" ;;
    esac
    else
    echo "'$1' is not a valid file"
  fi
}
### End Extract ### }}}

export TERM=xterm-256color

## Functions

function git-recursive {
  find . -type d -name .git -exec sh -c "cd \"{}\"/../ && pwd && git $1" \;
}

function isWSL {
  grep -q "microsoft" /proc/version
  return
}

function isCore {
  [[ "$(hostname)" == "23core" ]]
  return
}

function isZen {
  [[ "$(hostname)" == "zen23" ]]
  return
}

## Command Helpers
alias ..='cd ..'

alias h='history'
alias j='jobs -l'

alias list_size='du -chs *' # --max-depth=1
alias list_sort='du -chs * | sort -h'

alias symlink='ln -sf'

alias show-ssh="cat ~/.ssh/id_rsa.pub"

alias conf="nano ~/.bashrc && source ~/.bashrc"

alias yup="yarn upgrade-interactive --latest"
alias pm2-update="pm2 update && pm2 restart all --update-env"

## Git
# alias gc='git commit'
alias gco="git checkout"
alias gs='git status'
alias gp="git pull"
alias gsa="git status && git add . && git status"
alias gpp='git pull && git push'
alias gid='git rev-parse --short HEAD'
alias grh='git reset --hard HEAD'
alias gmo='git fetch origin && git merge origin/development'

function gc {
  git commit -m "$1"
}

function gout {
	git checkout $1
}

function gbout {
	git checkout -b $1
}

## Docker
alias dc='docker compose'
alias dcd="docker compose down"
alias dcl="docker compose logs -f --tail 256"
alias dcu="docker compose up -d && docker compose logs -f"
alias dcp='docker compose pull && docker compose up -d'
alias dcr='docker compose up -d --force-recreate --no-deps --build'

# export DOCKER_HOST=localhost:2375
export DOCKER_HOST=unix:///var/run/docker.sock

alias drm="docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)"
alias dps='docker ps --format="table {{.Names}}\t{{.Image}}\t{{.Status}}"'

## Kubernetes
alias kgp="kubectl get pods"
alias kgd="kubectl get deploy"
alias kgs="kubectl get svc"
alias wkgp="watch kubectl get pods"

alias docker_cleanup_images='docker image prune'
alias docker_cleanup_system='docker system prune'

alias docker_remove_dangling_images='docker rmi $(docker images -f "dangling=true" -q)'
alias docker_remove_exited_containers='docker rm -v $(docker ps -a -q -f status=exited)'

alias vscode_kill='ps aux | grep .vscode-server | grep [n]ode | "{print \$2}" | xargs kill'

## Docker Containers
alias portainer='docker pull portainer/portainer-ce:latest && \
  docker run \
  -d \
  --rm \
  --name portainer \
  -p 9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data portainer/portainer-ce:latest'
# --rm
# --restart unless-stopped

alias dtop='docker run --rm -it --name=ctop --volume /var/run/docker.sock:/var/run/docker.sock:ro quay.io/vektorlab/ctop:latest'

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

alias nodemod_list='find . -name "node_modules" -type d -prune'
alias nodemod_remove='find . -name "node_modules" -type d -prune -exec rm -rf "{}" +'

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

# https://stackoverflow.com/questions/669452/is-double-square-brackets-preferable-over-single-square-brackets-in-ba

if [[ isWSL && "$(pwd)" == "/root" ]]; then
  cd "/code"
fi

# use Windows' git when working under C:\ drive
# function git() {
#   if $(pwd -P | grep -q "^\/mnt\/c\/*"); then
#     git.exe "$@"
#   else
#     command git "$@"
#   fi
# }

# if [ -z "$(docker ps -a | grep portainer)" ]; then
#   portainer
# fi


# 01  function i_should(){
# 02      uname="$(uname -a)"
# 03
# 04      [[ "$uname" =~ Darwin ]] && return
# 05
# 06      if [[ "$uname" =~ Ubuntu ]]; then
# 07          release="$(lsb_release -a)"
# 08          [[ "$release" =~ LTS ]]
# 09          return
# 10      fi
# 11
# 12      false
# 13  }
# 14
# 15  function do_it(){
# 16      echo "Hello, old friend."
# 17  }
# 18
# 19  if i_should; then
# 20    do_it
# 21  fi
