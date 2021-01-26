#!/bin/bash

## https://github.com/guard/listen/wiki/Increasing-the-amount-of-inotify-watchers
## https://github.com/fatso83/dotfiles/blob/master/utils/scripts/inotify-consumers

echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
