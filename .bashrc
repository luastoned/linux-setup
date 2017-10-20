# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history.
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
alias ll='ls -alhF'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Bash Completion
if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# Git Completion
if [ -f ~/git-completion.bash ]; then
	source ~/git-completion.bash
fi

# Git Prompt
if [ -f ~/git-prompt.sh ]; then
	source ~/git-prompt.sh
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
export PS1="\t \[$Red\]\u\[$Color_Off\]@\[$Green\]\h\[$Color_Off\]:\$(pwd)\[$IBlue\]\$(__git_ps1) \[$Red\]>\[$Color_Off\] "

################################################################
## PATH
################################################################

#export PATH=$PATH:/home/java/jdk/bin/

################################################################
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

alias h='history'
alias j='jobs -l'

alias box1='ssh box1.luastoned.com -p 443'
alias box2='ssh box2.luastoned.com -p 443'
alias box3='ssh box3.luastoned.com -p 443'

alias list_size='du -chs *'
alias list_sort='du -chs * | sort -h'

alias pack_targz='tar czvf'
alias unpack_targz='tar xzvf'
alias unpack_tarbz2='tar jxvf'

alias check_ports1='netstat -ntap'
alias check_ports2='netstat -ntl'
alias check_ports_pid='netstat -lp --inet'

alias route_usb='route add default gw 192.168.7.1'
alias time_set='dpkg-reconfigure tzdata'
alias time_fix='ntpdate -u ntp.ubuntu.com'

alias wanip='dig +short myip.opendns.com @resolver1.opendns.com'

alias ram='top -n 1 | grep "Mem"'
alias cpu='top -n 1 | grep "Cpu"'
alias topn='top -n 1'
alias top_cpu='top -o %CPU'
alias top_ram='top -o %MEM'

alias lua='rlwrap luajit -l essentials'

alias ..='cd ..'
alias www='cd /var/www'

alias a2s='/etc/init.d/apache2 stop'
alias a2r='a2s && sleep 2 && /etc/init.d/apache2 start'

alias n2s='/etc/init.d/nginx stop'
alias n2r='n2s && sleep 2 && /etc/init.d/nginx start'

alias p2s='/etc/init.d/postfix stop'
alias p2r='p2s && sleep 2 && /etc/init.d/postfix start'

alias i2s='/etc/init.d/icecast2 stop'
alias i2r='i2r && sleep 2 && /etc/init.d/icecast2 start'

alias f2s='/etc/init.d/proftpd stop'
alias f2r='f2s && sleep 2 && /etc/init.d/proftpd start'

alias w2s='/etc/webmin/stop'
alias w2r='w2s && sleep 2 && /etc/webmin/start'

# Installation: pm2 completion >> ~/.bashrc  (or ~/.zshrc)
