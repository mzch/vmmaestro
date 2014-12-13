#!/bin/sh

BR="br0"

sudo /sbin/brctl delif $BR $1
sudo /sbin/ifconfig $1 down
