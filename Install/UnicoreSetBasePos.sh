#!/bin/bash
#

BASEDIR=`realpath $(dirname "$0")`
OLDCONF=${BASEDIR}/receiver.conf
BADPOSFILE=${BASEDIR}/GNSS_coordinate_error.flg
#DEBUGLOG="${BASEDIR}/debug.log"
ZEROPOS="0.00 0.00 0.00"
com_port=${1}
com_speed=${2}
position=${3}
receiver=${4}
#echo com_port="${com_port}" com_speed=${com_speed} position="${position}" receiver=${receiver}

lastcode=N
exitcode=0

ExitCodeCheck(){
  lastcode=$1
  #echo lastcode=${lastcode}
  if [[ $lastcode > $exitcode ]]
  then
     exitcode=${lastcode}
     #echo exitcode=${exitcode}
  fi
}

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

if [[ ${com_speed} -lt 115200 ]]
then
   echo com_speed \(${com_speed}\) is low 115200
   exit 3
fi

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
      if [[ "${position}" == "${ZEROPOS}" ]]
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

if [[ ${SETSPEED} == Y ]]
then
   if [[ "${receiver}" == *Unicore* ]]
   then
      if [[ "${com_port}" == ttyS[0-9] ]] || [[ "${com_port}" == ttyAMA[0-9] ]] || [[ "${com_port}" == serial[0-9] ]]
      then
         RECVCOM=COM2
      elif [[ "${com_port}" == ttyUSB[0-9] ]] || [[ "${com_port}" == ttyACM[0-9] ]]
      then
         RECVCOM=COM1
      fi
   elif [[ "${receiver}" == *Bynav* ]]
   then
      RECVCOM=`${BASEDIR}/NmeaConf ${OLDDEV} TEST COM | grep COM`
      if [[ "${RECVCOM}" == "" ]]
      then
          RECVCOM=`${BASEDIR}/NmeaConf ${DEVICE} TEST COM | grep COM`
          if [[ "${RECVCOM}" != "" ]]
          then
             echo Receiver already on ${com_speed}
             #echo ${BASEDIR}/NmeaConf ${DEVICE} saveconfig QUIET
             ${BASEDIR}/NmeaConf ${DEVICE} saveconfig QUIET
             ExitCodeCheck $?
             recv_speed=${com_speed}
             SAVECONF=Y
             SETSPEED=N
          fi
      fi
   fi

   #echo RECVCOM=${RECVCOM}
   if [[ "${RECVCOM}" == "" ]]
   then
      echo Unknown receiver port for change speed
      exit 1
   fi
fi

if [[ ${SETSPEED} == Y ]]
then
   for i in `seq 1 5`
   do
      if [[ "${receiver}" == *Unicore* ]]
      then
         #echo ${BASEDIR}/NmeaConf ${OLDDEV} \"CONFIG ${RECVCOM} ${com_speed}\" QUIET
         ${BASEDIR}/NmeaConf ${OLDDEV} "CONFIG ${RECVCOM} ${com_speed}" QUIET
         lastcode=$?
      elif [[ "${receiver}" == *Bynav* ]]
      then
         #echo ${BASEDIR}/NmeaConf ${OLDDEV} \"SERIALCONFIG ${RECVCOM} ${com_speed}\" QUIET
         ${BASEDIR}/NmeaConf ${OLDDEV} "SERIALCONFIG ${RECVCOM} ${com_speed}" QUIET
         lastcode=$?
      fi
      #echo lastcode=${lastcode}
      if [[ ${lastcode} == 0 ]] || [[ ${lastcode} == 3 ]]
      then
          #echo ${BASEDIR}/NmeaConf ${DEVICE} saveconfig QUIET
          ${BASEDIR}/NmeaConf ${DEVICE} saveconfig QUIET
          lastcode=$?
          if [[ ${lastcode} == 0 ]]
          then
             echo Speed changed on $i iteration
             SPEEDCHANGED=Y
             recv_speed=${com_speed}
             SAVECONF=Y
             break
          fi
      else
         ExitCodeCheck ${lastcode}
         echo speed changed incorrectly, not saved
         exit 1
      fi
   done

   if [[ ${SPEEDCHANGED} != "Y" ]]
   then
      echo receiver not answer after changing speed
      exit 2
   fi
fi

CHECKPOS=N
SAVEPOS=N
if [[ ${SETPOS} == Y ]]
then
   if [[ "${receiver}" == *Unicore* ]]
   then
      for i in `seq 1 30`
      do
         #echo UNICORE_MODE=\`${BASEDIR}/NmeaConf ${DEVICE} MODE\`
         UNICORE_MODE=`${BASEDIR}/NmeaConf ${DEVICE} MODE`
         ExitCodeCheck $?
         IS_FINE=`echo ${UNICORE_MODE} | grep -c "1005"`
         #echo UNICORE_MODE=${UNICORE_MODE}
         #echo IS_FINE=${IS_FINE}
         if [[ ${IS_FINE} != "0" ]]
         then
            echo 1005 found on $i iteration
            break
         fi
         sleep 1
      done
      #echo ${BASEDIR}/NmeaConf ${DEVICE} \"MODE BASE 1 ${position}\" QUIET
      ${BASEDIR}/NmeaConf ${DEVICE} "MODE BASE 1 ${position}" QUIET
      ExitCodeCheck $?
      if [[ $lastcode == 0 ]]
      then
         CHECKPOS=Y
         SAVEPOS=Y
      fi
   elif [[ "${receiver}" == *Bynav* ]]
   then
      #echo ${BASEDIR}/NmeaConf ${DEVICE} \"FIX POSITION ${position}\" QUIET
      ${BASEDIR}/NmeaConf ${DEVICE} "FIX POSITION ${position}" QUIET
      ExitCodeCheck $?
      if [[ $lastcode == 0 ]]
      then
         recv_position="${position}"
         #echo recv_position=${recv_position}
         SAVECONF=Y
         SAVEPOS=Y
      fi
   fi
fi

#echo CHECKPOS=${CHECKPOS} SAVEPOS=${SAVEPOS}
if [[ ${CHECKPOS} == Y ]]
then
   #echo ${BASEDIR}/NmeaConf ${DEVICE} MODE QUIET
   UNICORE_ANSWER=`${BASEDIR}/NmeaConf ${DEVICE} CONFIG QUIET`
   ExitCodeCheck $?
   #echo UNICORE_ANSWER=${UNICORE_ANSWER}
   POSITION_INCORRECT=`echo ${UNICORE_ANSWER} | grep -c "not correct"`
   #echo POSITION_INCORRECT=${POSITION_INCORRECT}
   if [[ ${POSITION_INCORRECT} == "0" ]]
   then
      recv_position="${position}"
      #echo recv_position=${recv_position}
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
   if [[ "${receiver}" == *Unicore* ]]
   then
      #echo ${BASEDIR}/NmeaConf ${DEVICE} \"MODE BASE 1 TIME 60 1\" QUIET
      ${BASEDIR}/NmeaConf ${DEVICE} "MODE BASE 1 TIME 60 1" QUIET
      ExitCodeCheck $?
   elif [[ "${receiver}" == *Bynav* ]]
   then
      #echo ${BASEDIR}/NmeaConf ${DEVICE} \"FIX NONE\" QUIET
      ${BASEDIR}/NmeaConf ${DEVICE} "FIX NONE" QUIET
      ExitCodeCheck $?
   fi
   recv_position="${ZEROPOS}"
   #echo recv_position=${recv_position}
   SAVEPOS=Y
   SAVECONF=Y
fi

if [[ ${SAVEPOS} == Y ]]
then
   #echo ${BASEDIR}/NmeaConf ${DEVICE} saveconfig QUIET
   ${BASEDIR}/NmeaConf ${DEVICE} saveconfig QUIET
   ExitCodeCheck $?
   if [[ "${receiver}" == *Bynav* ]]
   then
      #echo ${BASEDIR}/NmeaConf ${DEVICE} REBOOT QUIET
      ${BASEDIR}/NmeaConf ${DEVICE} REBOOT QUIET
      ExitCodeCheck $?
   fi
fi

if [[ ${SAVECONF} == Y ]]
then
   #echo SAVE OLDCONF=${OLDCONF} recv_port=${recv_port} recv_speed=${recv_speed} recv_position=${recv_position}
   echo recv_port=${recv_port}>${OLDCONF}
   echo recv_speed=${recv_speed}>>${OLDCONF}
   echo recv_position=\"${recv_position}\">>${OLDCONF}
fi

if [[ ${lastcode} == N ]]
then
   if [[ "${receiver}" == *Unicore* ]]
   then
      #echo ${BASEDIR}/NmeaConf ${DEVICE} MODE QUIET
      ${BASEDIR}/NmeaConf ${DEVICE} MODE QUIET
      ExitCodeCheck $?
   elif [[ "${receiver}" == *Bynav* ]]
   then
      #echo ${BASEDIR}/NmeaConf ${DEVICE} \"LOG REFSTATION\" QUIET
      ${BASEDIR}/NmeaConf ${DEVICE} "LOG REFSTATION" QUIET
      ExitCodeCheck $?
   fi
fi

#echo exit $0 with code ${exitcode} "("lastcode=${lastcode}")"
exit ${exitcode}
