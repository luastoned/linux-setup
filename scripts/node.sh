#!/bin/bash

## dependencies
sudo apt install software-properties-common gpg-agent -y

## yarn repository
curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
sudo add-apt-repository "deb https://dl.yarnpkg.com/debian/ stable main"

## nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash

## install yarn
sudo apt install --no-install-recommends yarn -y
