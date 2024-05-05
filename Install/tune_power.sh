#!/bin/bash

sudo cpufreq-set -g powersave
sudo uhubctl -l 1-1 -a 0
#sudo uhubctl -l 2 -a 0
sudo vcgencmd display_power 0
