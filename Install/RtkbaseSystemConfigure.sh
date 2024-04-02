#!/bin/bash
#

#NEWCONF=system.txt
NEWCONF=/boot/firmware/system.txt
exitcode=0

ExitCodeCheck(){
  lastcode=$1
  if [[ $lastcode > $exitcode ]]
  then
     exitcode=${lastcode}
     #echo exitcode=${exitcode}
  fi
}

WHOAMI=`whoami`
if [[ ${WHOAMI} != "root" ]]
then
   #echo use sudo
   sudo ${0} ${1}
   ExitCodeCheck $?
   if [[ "${exitcode}" != 0 ]]
   then
      echo exit with code ${exitcode}
   fi
   exit ${exitcode}
fi

if [[ -f ${NEWCONF} ]]
then
   DATE=`date`
   echo start at ${DATE}
   #echo sed -i s/"\r"// "${NEWCONF}"
   sed -i s/"\r"// "${NEWCONF}"
   ExitCodeCheck $?
   #echo "source <( grep '=' ${NEWCONF} )"
   source <( grep '=' ${NEWCONF} )
   ExitCodeCheck $?
else
   ExitCodeCheck 0
   exit 0
fi

if [[ -n "${COUNTRY}" ]]
then
   #echo sudo raspi-config nonint do_wifi_country "${COUNTRY}"
   sudo raspi-config nonint do_wifi_country "${COUNTRY}"
   ExitCodeCheck $?
   echo Wifi country set to ${COUNTRY} -- code ${exitcode}
   WORK=Y
fi

if [[ -n "${SSID}" ]]
then
   if [[ -z "${HIDDEN}" ]]
   then
      HIDnum=0
      HIDkey=
   else
      HIDnum=1
      HIDkey=-h
   fi
   #echo SSID=${SSID} KEY=${KEY} HIDDEN=${HIDDEN} HIDnum=${HIDnum} HIDkey=${HIDkey}

   if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]
   then
      #echo /usr/lib/raspberrypi-sys-mods/imager_custom set_wlan ${HIDkey} "${SSID}" "${KEY}"
      /usr/lib/raspberrypi-sys-mods/imager_custom set_wlan ${HIDkey} "${SSID}" "${KEY}"
      ExitCodeCheck $?
      #echo systemctl restart NetworkManager
      systemctl restart NetworkManager
      ExitCodeCheck $?
   else
      #https://www.raspberrypi.com/documentation/computers/configuration.html
      #echo sudo raspi-config nonint do_wifi_ssid_passphrase "${SSID}" "${KEY}" ${HIDnum}
      sudo raspi-config nonint do_wifi_ssid_passphrase "${SSID}" "${KEY}" ${HIDnum}
      ExitCodeCheck $?
   fi
   echo Wifi SSID set to ${SSID} -- code ${exitcode}
   WORK=Y
fi

if [[ -n "${LOGIN}" ]]
then
   USER_HOME=/home/"${LOGIN}"
   #echo sed 's/:.*//' /etc/passwd \| grep ${LOGIN}
   FOUND=`sed 's/:.*//' /etc/passwd | grep "${LOGIN}"`
   #echo LOGIN=${LOGIN} PWD=${PWD} USER_HOME=${USER_HOME} FOUND=${FOUND}
   #echo SSH=${SSH}
   if [[ -z "${FOUND}" ]]
   then
      if [[ -n "${PWD}" ]]
      then
         # https://ru.stackoverflow.com/questions/1022068/ћожно-ли-создавать-пользовател€-одновременно-с-вводом-парол€-из-переменной
         #echo CRYPTO=\`openssl passwd -1 -salt xyz "${PWD}"\`
         CRYPTO=`openssl passwd -1 -salt xyz "${PWD}"`
         #echo CRYPTO=${CRYPTO}
         ExitCodeCheck $?
         #echo useradd --comment "Added by system" --create-home --password "${CRYPTO}" "${LOGIN}"
         useradd --comment "Added by RtkBaseSystemConfigure" --create-home --password "${CRYPTO}" "${LOGIN}"
         ExitCodeCheck $?
         echo Added user ${LOGIN} with password -- code ${exitcode}
      else
         #echo useradd --comment "Added by system" --create-home --disabled-password "${LOGIN}"
         useradd --comment "Added by RtkBaseSystemConfigure" --create-home "${LOGIN}"
         ExitCodeCheck $?
         echo Added user ${LOGIN} without password -- code ${exitcode}
      fi
      #echo ""${LOGIN}" ALL=NOPASSWD: ALL" \> /etc/sudoers.d/"${LOGIN}"
      echo ""${LOGIN}" ALL=NOPASSWD: ALL" > /etc/sudoers.d/"${LOGIN}"
   else
      if [[ -n "${PWD}" ]]
      then
         echo User ${LOGIN} already present
      fi
   fi
   if [[ -n "${SSH}" ]]
   then
      SSH_HOME="${USER_HOME}"/.ssh
      if [[ ! -d "${SSH_HOME}" ]]
      then
          #echo install -o "${LOGIN}" -g "${LOGIN}" -m 700 -d "${SSH_HOME}"
          install -o "${LOGIN}" -g "${LOGIN}" -m 700 -d "${SSH_HOME}"
          ExitCodeCheck $?
      fi
      AUTHORISED_KEYS_FILE="${SSH_HOME}"/authorized_keys
      if [[ -f "${AUTHORISED_KEYS_FILE}" ]]
      then
         #echo grep "${SSH}" "${AUTHORISED_KEYS_FILE}"
         DOUBLE=`grep "${SSH}" "${AUTHORISED_KEYS_FILE}"`
         ExitCodeCheck $?
      fi
      if [[ -z "${DOUBLE}" ]]
      then
         #echo echo "${SSH}" '>>' "${AUTHORISED_KEYS_FILE}"
         echo "${SSH}" >> "${AUTHORISED_KEYS_FILE}"
         ExitCodeCheck $?
         if [[ -f "${AUTHORISED_KEYS_FILE}" ]]
         then
           #echo chmod 600 "${AUTHORISED_KEYS_FILE}"
           chmod 600 "${AUTHORISED_KEYS_FILE}"
           ExitCodeCheck $?
           #echo chown "${LOGIN}:${LOGIN}" "${AUTHORISED_KEYS_FILE}"
           chown "${LOGIN}:${LOGIN}" "${AUTHORISED_KEYS_FILE}"
           ExitCodeCheck $?
         fi
         echo Added ssh public key for ${LOGIN} -- code ${exitcode}
      else
         echo This ssh public key for ${LOGIN} already present
      fi
   fi
   #echo sudo raspi-config nonint do_ssh 0
   sudo raspi-config nonint do_ssh 0
   ExitCodeCheck $?
   WORK=Y
fi

if [[ -z "${WORK}" ]]
then
  echo No any work
  ExitCodeCheck 1
fi

rm -f ${NEWCONF}
ExitCodeCheck $?

#echo exit ${exitcode}
exit ${exitcode}

