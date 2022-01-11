#!/bin/bash

## https://github.com/guard/listen/blob/master/README.md#increasing-the-amount-of-inotify-watchers
## https://github.com/fatso83/dotfiles/blob/master/utils/scripts/inotify-consumers

## 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304 8388608
echo fs.inotify.max_user_instances = 8192 | sudo tee -a /etc/sysctl.conf
echo fs.inotify.max_user_watches = 1048576 | sudo tee -a /etc/sysctl.conf
echo fs.inotify.max_queued_events = 2097152 | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
