#!/bin/bash

sudo cpufreq-set -g powersave
MODEL=`cat /proc/cpuinfo | grep Model`
#echo MODEL=${MODEL}
PI4=`echo ${MODEL} | grep "Pi 4"`
#echo PI4=${PI4}
if [[ "${PI4}" != "" ]]
then
   if grep -q '^rtkbase_path=' /etc/environment
   then
      source /etc/environment
   else
      BASEDIR=`realpath $(dirname "$0")`
      rtkbase_path=${BASEDIR}/rtkbase
   fi
   source <( grep '^com_port=' ${rtkbase_path}/settings.conf )
   if [[ "${com_port}" == ttyUSB[0-9] ]] || [[ "${com_port}" == ttyACM[0-9] ]]
   then
       USB_PORT=Y
   fi
   #echo rtkbase_path=${rtkbase_path} com_port=${com_port} USB_PORT=${USB_PORT}
   if [[ "${USB_PORT}" != "Y" ]]
   then
      sudo uhubctl -l 1-1 -a 0 # turn off USB
      #sudo uhubctl -l 2 -a 0
   fi
fi
sudo vcgencmd display_power 0
