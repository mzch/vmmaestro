#!/bin/sh

BR="br1"

BRCTL="/sbin/brctl"
IPCTL="/usr/bin/ip"

echo "Executing $0"
echo "Bringing up $1 for bridged mode..."
sudo $IPCTL link set $1 promisc on
sudo $IPCTL link set $1 up
echo "Adding $1 to $BR..."
sudo $BRCTL addif $BR $1

sleep 2
