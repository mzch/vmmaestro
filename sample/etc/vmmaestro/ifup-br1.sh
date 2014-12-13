#!/bin/sh

BR="br1"

echo "Executing $0"
echo "Bringing up $1 for bridged mode..."
sudo /sbin/ifconfig $1 0.0.0.0 promisc up
echo "Adding $1 to $BR..."
sudo /sbin/brctl addif $BR $1

#sleep 10
