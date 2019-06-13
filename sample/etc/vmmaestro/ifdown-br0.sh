#!/bin/sh

BR="br0"

BRCTL="/sbin/brctl"
IPCTL="/usr/bin/ip"

sudo $BRCTL delif $BR $1
sudo $IPCTL link set $1 down
