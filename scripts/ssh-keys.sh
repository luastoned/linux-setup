#!/bin/bash

## move to assets
cd assets

## copy authorized_keys
sudo mkdir ~/.ssh
sudo cat .authorized_keys >> ~/.ssh/authorized_keys

## patch ssh config
sudo sed --in-place 's/#AuthorizedKeysFile/AuthorizedKeysFile/' /etc/ssh/sshd_config
