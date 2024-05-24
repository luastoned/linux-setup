#!/bin/bash

## dependencies
sudo apt install software-properties-common gpg-agent jq -y

## yarn repository
# curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
# sudo add-apt-repository "deb https://dl.yarnpkg.com/debian/ stable main"
# echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

YARN_KEY=yarn-keyring.gpg
curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo gpg --dearmour -o /usr/share/keyrings/$YARN_KEY
echo "deb [signed-by=/usr/share/keyrings/$YARN_KEY] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

## nvm
(
  VERSION="$(curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq --raw-output '.tag_name')"
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${VERSION}/install.sh" | bash
)

## install yarn
sudo apt install --no-install-recommends yarn -y
