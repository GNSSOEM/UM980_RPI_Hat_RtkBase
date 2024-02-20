#!/bin/bash
#

BASEDIR=$(dirname "$0")
com_port=$1
position=$2
#echo com_port="${com_port}"  position="${position}"
#echo ${BASEDIR}/NmeaConf /dev/${com_port} "MODE BASE 1 ${position}" QUIET
${BASEDIR}/NmeaConf /dev/${com_port} "MODE BASE 1 ${position}" QUIET
#echo ${BASEDIR}/NmeaConf /dev/${com_port} MODE QUIET
UNICORE_ANSWER=`${BASEDIR}/NmeaConf /dev/${com_port} MODE QUIET`
#echo UNICORE_ANSWER=${UNICORE_ANSWER}
POSITION_INCORRECT=`echo ${UNICORE_ANSWER} | grep -c "not correct"`
#echo POSITION_INCORRECT=${POSITION_INCORRECT}
if [[ ${POSITION_INCORRECT} = "0" ]]
then
   #echo ${BASEDIR}/NmeaConf /dev/${com_port} saveconfig QUIET
   ${BASEDIR}/NmeaConf /dev/${com_port} saveconfig QUIET
else
   #echo ${BASEDIR}/NmeaConf /dev/${com_port} "MODE BASE 1 TIME 60 1" QUIET
   ${BASEDIR}/NmeaConf /dev/${com_port} "MODE BASE 1 TIME 60 1" QUIET
fi
#echo ${BASEDIR}/NmeaConf /dev/${com_port} MODE QUIET
#${BASEDIR}/NmeaConf /dev/${com_port} MODE QUIET
