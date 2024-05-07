#!/bin/sh

echo Upgrading system

# Just to present hostname to package installation scripts. For example,
# openssh-server generates host keys, and the hostname is filled in
# generated keys
hostname raspberrypi

apt -q update
apt -q -y full-upgrade
apt -q -y autoremove --purge
apt clean

echo System upgraded
