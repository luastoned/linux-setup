#!/bin/bash

## dependencies
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y

## remove old versions
sudo apt remove docker docker-engine docker.io containerd runc

## docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

## install docker
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose -y

## create docker group
sudo groupadd docker

## add user to docker group
sudo usermod -aG docker ${USER}
