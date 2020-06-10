#!/bin/bash

## dependencies
sudo apt install software-properties-common -y

## certbot repository
sudo add-apt-repository universe -y
sudo add-apt-repository ppa:certbot/certbot -y

## install certbot
sudo apt install certbot python-certbot-nginx -y
