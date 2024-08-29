#!/bin/bash

## install essentials
sudo apt install bat curl git vim tree tmux jq lshw rlwrap dnsutils net-tools p7zip p7zip-full p7zip-rar rar zip unzip -y

## install build related things
sudo apt install build-essential libssl-dev -y
