#!/bin/bash
　
echo "Removing $1 to br0..."
sudo brctl delif br0 $1
echo "Shutting down $1..."
sudo ifconfig $1 down
　
exit 0
