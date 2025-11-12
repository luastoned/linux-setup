#!/bin/bash

set -euo pipefail

echo "Installing dependencies for log rotation..."
sudo apt install jq -y

echo ""
echo "Configuring Docker log rotation..."

# Backup existing daemon.json if it exists
[ -f /etc/docker/daemon.json ] && sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak

# Update daemon.json with log rotation settings
if [ -f /etc/docker/daemon.json ]; then
	sudo jq -n \
		--slurpfile e /etc/docker/daemon.json '
	    ($e[0] // {})
	    | .["log-opts"] = (
	        (.["log-opts"] // {}) + {
	          "max-size": "100m",
	          "max-file": "3"
	        }
	      )
	    | .["log-driver"] = "json-file"
	  ' | sudo tee /etc/docker/daemon.json.tmp >/dev/null
else
	sudo jq -n '
	    {
	      "log-driver": "json-file",
	      "log-opts": {
	        "max-size": "100m",
	        "max-file": "3"
	      }
	    }
	  ' | sudo tee /etc/docker/daemon.json.tmp >/dev/null
fi

sudo mv /etc/docker/daemon.json.tmp /etc/docker/daemon.json

echo "Docker log rotation configured successfully."
