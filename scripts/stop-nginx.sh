#!/bin/bash

# stop any running nginx instance
sudo service nginx stop

# prevent nginx from starting on boot
sudo systemctl disable nginx
sudo update-rc.d -f nginx disable
