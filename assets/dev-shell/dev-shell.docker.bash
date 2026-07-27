# shellcheck shell=bash
# Managed by linux-setup; changes may be replaced on the next setup run.
# Put personal customizations in dev-shell.local.bash.

################################################################
## Docker
################################################################

alias dc='docker compose'
alias dcd='docker compose down'
alias dcl='docker compose logs -f --tail 256'
alias dcu='docker compose up -d && docker compose logs -f'
alias dcp='docker compose pull && docker compose up -d'
alias dcr='docker compose up -d --force-recreate --build'
alias dps='docker ps --format="table {{.Names}}\t{{.Image}}\t{{.Status}}"'

function docker_remove_all_containers {
	local -a containers

	if ! dev_shell_confirm "Stop and remove all Docker containers?"; then
		echo "Cancelled."
		return 0
	fi

	mapfile -t containers < <(docker ps -a -q)
	if [ "${#containers[@]}" -eq 0 ]; then
		echo "No Docker containers found."
		return 0
	fi

	docker stop "${containers[@]}"
	docker rm "${containers[@]}"
}
