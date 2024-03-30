#!/bin/sh

apt -q update
apt -q -y full-upgrade
#apt -q -y dist-upgrade
apt -q autoremove
apt clean
