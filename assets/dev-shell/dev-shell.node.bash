# shellcheck shell=bash

################################################################
## Node.js
################################################################

export NVM_DIR="$HOME/.nvm"
export NVM_SYMLINK_CURRENT=true

if [ -s "$NVM_DIR/nvm.sh" ]; then
	# shellcheck source=/dev/null
	source "$NVM_DIR/nvm.sh"
fi

if [ -s "$NVM_DIR/bash_completion" ]; then
	# shellcheck source=/dev/null
	source "$NVM_DIR/bash_completion"
fi

alias yup='yarn upgrade-interactive --latest'
alias gup='yarn global upgrade-interactive --latest'
alias pm2-update='pm2 update && pm2 restart all --update-env'
