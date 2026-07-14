# shellcheck shell=bash

################################################################
## Docker
################################################################

export DOCKER_HOST="${DOCKER_HOST:-unix:///var/run/docker.sock}"

alias dc='docker compose'
alias dcd='docker compose down'
alias dcl='docker compose logs -f --tail 256'
alias dcu='docker compose up -d && docker compose logs -f'
alias dcp='docker compose pull && docker compose up -d'
alias dcr='docker compose up -d --force-recreate --no-deps --build'
alias dps='docker ps --format="table {{.Names}}\t{{.Image}}\t{{.Status}}"'

function dev_shell_confirm {
	local prompt="$1"
	local reply

	read -r -p "$prompt (y/N): " reply
	[[ "$reply" =~ ^[Yy]([Ee][Ss])?$ ]]
}

function drm {
	local containers

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

function docker_cleanup_images {
	docker image prune
}

function docker_cleanup_system {
	docker system prune
}

function docker_remove_dangling_images {
	local images

	mapfile -t images < <(docker images -f "dangling=true" -q)
	if [ "${#images[@]}" -eq 0 ]; then
		echo "No dangling Docker images found."
		return 0
	fi

	docker rmi "${images[@]}"
}

function docker_remove_exited_containers {
	local containers

	mapfile -t containers < <(docker ps -a -q -f status=exited)
	if [ "${#containers[@]}" -eq 0 ]; then
		echo "No exited Docker containers found."
		return 0
	fi

	docker rm -v "${containers[@]}"
}

function portainer {
	docker pull portainer/portainer-ee:latest
	docker run -d --rm --name portainer -p 9000:9000 \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v portainer_data:/data portainer/portainer-ee:latest
}

function dtop {
	docker run --rm -it --name=ctop \
		--volume /var/run/docker.sock:/var/run/docker.sock:ro \
		quay.io/vektorlab/ctop:latest
}
