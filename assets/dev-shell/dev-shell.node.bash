# shellcheck shell=bash
# Managed by linux-setup; changes may be replaced on the next setup run.
# Put personal customizations in dev-shell.local.bash.

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
	dev_shell_prepend_path "$HOME/.nub/bin"
fi

if [ -d "$HOME/.nub/node-shim" ]; then
	dev_shell_prepend_path "$HOME/.nub/node-shim"
fi

alias pm2-update='pm2 update && pm2 restart all --update-env'
