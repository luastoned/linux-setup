#!/bin/sh

IPT="/sbin/iptables"

# Set default policies for all three default chains
$IPT -P INPUT ACCEPT
$IPT -P FORWARD ACCEPT
$IPT -P OUTPUT ACCEPT

# Flush old rules, old custom tables
$IPT --flush
$IPT --delete-chain
$IPT -t nat --flush
$IPT -t mangle --flush
