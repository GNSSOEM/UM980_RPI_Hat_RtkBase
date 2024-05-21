#!/bin/bash

sudo cpufreq-set -g powersave
MODEL=`cat /proc/cpuinfo | grep Model`
#echo MODEL=${MODEL}
PI4=`echo ${MODEL} | grep "Pi 4"`
#echo PI4=${PI4}
if [[ "${PI4}" != "" ]]
then
   sudo uhubctl -l 1-1 -a 0
   #sudo uhubctl -l 2 -a 0
fi
sudo vcgencmd display_power 0
