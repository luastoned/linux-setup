# shellcheck shell=bash

################################################################
## Raspberry Pi
################################################################

alias route_usb='route add default gw 192.168.7.1'
alias time_set='dpkg-reconfigure tzdata'
alias time_fix='ntpdate -u time.cloudflare.com'
