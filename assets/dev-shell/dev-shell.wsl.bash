# shellcheck shell=bash
# Managed by linux-setup; changes may be replaced on the next setup run.
# Put personal customizations in dev-shell.local.bash.

################################################################
## WSL
################################################################

PREV_PWD="$(pwd)"
cd /c/ 2>/dev/null || true
WINDOWS_USER="$(/c/Windows/System32/cmd.exe /c 'echo %USERNAME%' 2>/dev/null | sed -e 's/\r//g')"
if [ -n "$WINDOWS_USER" ]; then
	export PATH="/c/Windows/System32:/c/Users/$WINDOWS_USER/AppData/Local/Programs/Microsoft VS Code/bin:$PATH"
fi
cd "$PREV_PWD" || true

unset PREV_PWD WINDOWS_USER

if [[ "$(pwd)" == "/root" ]] && [[ -d "/code" ]]; then
	cd "/code" 2>/dev/null || true
fi
