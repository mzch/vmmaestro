#!/bin/bash
　
echo "Bringing up $1 for bridged mode..."
sudo ifconfig $1 0.0.0.0 promisc up
echo "Adding $1 to br0..."
sudo brctl addif br0 $1
　
exit 0
