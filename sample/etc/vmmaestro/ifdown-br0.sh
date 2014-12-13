#!/bin/sh

BR="br0"

sudo /usr/sbin/brctl delif $BR $1
sudo /sbin/ifconfig $1 down
