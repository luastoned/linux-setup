#!/bin/bash

## dependencies
sudo apt install software-properties-common gpg-agent jq -y

## yarn repository
curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
sudo add-apt-repository "deb https://dl.yarnpkg.com/debian/ stable main"

## nvm
(
  VERSION="$(curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq --raw-output '.tag_name')"
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${VERSION}/install.sh" | sudo bash
)

## install yarn
sudo apt install --no-install-recommends yarn -y
