#!/bin/bash

## move to assets
cd assets

## copy authorized_keys
if [[ ! -d "~/.ssh" ]]; then
  sudo mkdir ~/.ssh
fi

sudo cat .authorized_keys >> ~/.ssh/authorized_keys

## patch ssh config
sudo sed --in-place 's/#AuthorizedKeysFile/AuthorizedKeysFile/' /etc/ssh/sshd_config
