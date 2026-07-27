# shellcheck shell=bash
# Managed by linux-setup; changes may be replaced on the next setup run.
# Put personal customizations in dev-shell.local.bash.

################################################################
## Raspberry Pi
################################################################

alias route_usb='route add default gw 192.168.7.1'
alias time_set='dpkg-reconfigure tzdata'
alias time_fix='ntpdate -u time.cloudflare.com'
