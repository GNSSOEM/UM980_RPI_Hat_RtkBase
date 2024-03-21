#!/bin/bash
#

BASEDIR=`realpath $(dirname "$0")`
OLDCONF=${BASEDIR}/receiver.conf
com_port=${1}
com_speed=${2}
position=${3}
#echo com_port="${com_port}"  com_speed=${com_speed} position="${position}"

SAVECONF=N
if [[ -f ${OLDCONF} ]]
then
   #echo source ${OLDCONF}
   source ${OLDCONF}
else
   recv_port=${com_port}
   recv_speed=${com_speed}
   recv_position=
   SAVECONF=Y
fi
#echo recv_port=${recv_port} recv_speed=${recv_speed} recv_position=${recv_position}

SETSPEED=Y
SETPOS=Y
if [[ "${com_port}" == "${recv_port}" ]]
then
   if [[ "${com_speed}" == "${recv_speed}" ]]
   then
      SETSPEED=N
   fi
   if [[ "${position}" == "${recv_position}" ]]
   then
      SETPOS=N
   fi
else
   recv_port=${com_port}
   SETSPEED=N
   SAVECONF=Y
fi

if [[ "${position}" == "0.00 0.00 0.00" ]]
then
   SETPOS=N
fi

OLDDEV=/dev/${com_port}:${recv_speed}
DEVICE=/dev/${com_port}:${com_speed}
#echo SETSPEED=${SETSPEED} SETPOS=${SETPOS} OLDDEV=${OLDDEV} DEVICE=${DEVICE}

if [[ ${SETSPEED} == Y ]]
then
   #echo ${BASEDIR}/NmeaConf ${OLDDEV} "CONFIG COM2 ${com_speed}" QUIET
   ${BASEDIR}/NmeaConf ${OLDDEV} "CONFIG COM2 ${com_speed}" QUIET
   if [[ $? == 0 ]]
   then
      #echo ${BASEDIR}/NmeaConf ${DEVICE} saveconfig QUIET
      ${BASEDIR}/NmeaConf ${DEVICE} saveconfig QUIET
      if [[ $? == 0 ]]
      then
         recv_speed=${com_speed}
         SAVECONF=Y
      else
         #echo exit 2
         exit 2
      fi
   else
      #echo exit 1
      exit 1
   fi
fi

if [[ ${SETPOS} == Y ]]
then
   #echo ${BASEDIR}/NmeaConf ${DEVICE} "MODE BASE 1 ${position}" QUIET
   ${BASEDIR}/NmeaConf ${DEVICE} "MODE BASE 1 ${position}" QUIET
   #echo ${BASEDIR}/NmeaConf ${DEVICE} MODE QUIET
   UNICORE_ANSWER=`${BASEDIR}/NmeaConf ${DEVICE} MODE QUIET`
   #echo UNICORE_ANSWER=${UNICORE_ANSWER}
   POSITION_INCORRECT=`echo ${UNICORE_ANSWER} | grep -c "not correct"`
   #echo POSITION_INCORRECT=${POSITION_INCORRECT}
   if [[ ${POSITION_INCORRECT} = "0" ]]
   then
      #echo ${BASEDIR}/NmeaConf ${DEVICE} saveconfig QUIET
      ${BASEDIR}/NmeaConf ${DEVICE} saveconfig QUIET
      recv_position=${position}
   else
      #echo ${BASEDIR}/NmeaConf ${DEVICE} "MODE BASE 1 TIME 60 1" QUIET
      ${BASEDIR}/NmeaConf ${DEVICE} "MODE BASE 1 TIME 60 1" QUIET
      recv_position="BAD"
   fi
   SAVECONF=Y
fi

if [[ ${SAVECONF} == Y ]]
then
   #echo SAVE OLDCONF=${OLDCONF} recv_port=${recv_port} recv_speed=${recv_speed} recv_position=${recv_position}
   echo recv_port=${recv_port}>${OLDCONF}
   echo recv_speed=${recv_speed}>>${OLDCONF}
   echo recv_position=${recv_position}>>${OLDCONF}
fi

#echo ${BASEDIR}/NmeaConf ${DEVICE} MODE QUIET
${BASEDIR}/NmeaConf ${DEVICE} MODE QUIET
