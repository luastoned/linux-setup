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

if [ -d "$HOME/.nub/bin" ]; then
	export PATH="$HOME/.nub/bin:$PATH"
fi

if [ -d "$HOME/.nub/node-shim" ]; then
	export PATH="$HOME/.nub/node-shim:$PATH"
fi

alias pm2-update='pm2 update && pm2 restart all --update-env'
