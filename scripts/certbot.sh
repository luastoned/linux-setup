#!/bin/bash

## dependencies
sudo apt install software-properties-common -y

## certbot repository
if [[ "$(lsb_release -sr)" != "20.04" ]]; then
  sudo add-apt-repository universe -y
  sudo add-apt-repository ppa:certbot/certbot -y
fi

## install certbot
sudo apt install certbot python-certbot-nginx -y
