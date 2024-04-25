#!/bin/bash
#

BASEDIR=`realpath $(dirname "$0")`
OLDCONF=${BASEDIR}/receiver.conf
BADPOSFILE=${BASEDIR}/GNSS_coordinate_error.flg
#DEBUGLOG="${BASEDIR}/debug.log"
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
TIMEPOS=N
BADPOS=
if [[ "${com_port}" == "${recv_port}" ]]
then
   if [[ "${com_speed}" == "${recv_speed}" ]]
   then
      SETSPEED=N
   fi
   if [[ "${position}" == "${recv_position}" ]]
   then
      SETPOS=N
   else
      if [[ "${position}" == "0.00 0.00 0.00" ]]
      then
         TIMEPOS=Y
         SETPOS=N
         BADPOS=N
      fi
   fi
else
   recv_port=${com_port}
   SETSPEED=N
   SAVECONF=Y
fi

OLDDEV=/dev/${com_port}:${recv_speed}
DEVICE=/dev/${com_port}:${com_speed}
#echo SETSPEED=${SETSPEED} SETPOS=${SETPOS} TIMEPOS=${TIMEPOS} BADPOS=${BADPOS} OLDDEV=${OLDDEV} DEVICE=${DEVICE}

RECVCOM=COM1
if [[ ${SETSPEED} == Y ]]
then
   if [[ "${com_port}" == "ttyS0" ]]
   then
      RECVCOM=COM2
   fi
   #echo ${BASEDIR}/NmeaConf ${OLDDEV} "CONFIG ${RECVCOM} ${com_speed}" QUIET
   ${BASEDIR}/NmeaConf ${OLDDEV} "CONFIG ${RECVCOM} ${com_speed}" QUIET
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

CHECKPOS=N
SAVEPOS=N
if [[ ${SETPOS} == Y ]]
then
   #echo ${BASEDIR}/NmeaConf ${DEVICE} "MODE BASE 1 ${position}" QUIET
   ${BASEDIR}/NmeaConf ${DEVICE} "MODE BASE 1 ${position}" QUIET >/dev/null
   CHECKPOS=Y
   SAVEPOS=Y
fi

#echo CHECKPOS=${CHECKPOS} SAVEPOS=${SAVEPOS}
if [[ ${CHECKPOS} == Y ]]
then
   #echo ${BASEDIR}/NmeaConf ${DEVICE} MODE QUIET
   UNICORE_ANSWER=`${BASEDIR}/NmeaConf ${DEVICE} MODE QUIET`
   #echo UNICORE_ANSWER=${UNICORE_ANSWER}
   POSITION_INCORRECT=`echo ${UNICORE_ANSWER} | grep -c "not correct"`
   #echo POSITION_INCORRECT=${POSITION_INCORRECT}
   if [[ ${POSITION_INCORRECT} == "0" ]]
   then
      recv_position=${position}
      BADPOS=N
   else
      BADPOS=Y
      TIMEPOS=Y
   fi
   SAVECONF=Y
fi

if [[ "${BADPOS}" != "" ]]
then
   if [[ -f ${BADPOSFILE} ]]
   then
      BADNOW=Y
   else
      BADNOW=N
   fi
   #echo BADPOS=${BADPOS} BADNOW=${BADNOW} BADPOSFILE=${BADPOSFILE}
   if [[ ${BADPOS} != ${BADNOW} ]]
   then
      if [[ ${BADPOS} == Y ]]
      then
         #echo cp /dev/null ${BADPOSFILE}
         cp /dev/null ${BADPOSFILE}
      else
         #echo rm -f ${BADPOSFILE}
         rm -f ${BADPOSFILE}
      fi
   fi
   #echo ls -la ${BADPOSFILE}
   #ls -la ${BADPOSFILE} >>${DEBUGLOG} 2>&1
fi

if [[ ${TIMEPOS} == Y ]]
then
   #echo ${BASEDIR}/NmeaConf ${DEVICE} "MODE BASE 1 TIME 60 1" QUIET
   ${BASEDIR}/NmeaConf ${DEVICE} "MODE BASE 1 TIME 60 1" QUIET
   recv_position="BAD"
   SAVEPOS=Y
fi

if [[ ${SAVEPOS} == Y ]]
then
   #echo ${BASEDIR}/NmeaConf ${DEVICE} saveconfig QUIET
   ${BASEDIR}/NmeaConf ${DEVICE} saveconfig QUIET
fi

if [[ ${SAVECONF} == Y ]]
then
   #echo SAVE OLDCONF=${OLDCONF} recv_port=${recv_port} recv_speed=${recv_speed} recv_position=${recv_position}
   echo recv_port=${recv_port}>${OLDCONF}
   echo recv_speed=${recv_speed}>>${OLDCONF}
   echo recv_position=\"${recv_position}\">>${OLDCONF}
fi

#echo ${BASEDIR}/NmeaConf ${DEVICE} MODE QUIET
${BASEDIR}/NmeaConf ${DEVICE} MODE QUIET
