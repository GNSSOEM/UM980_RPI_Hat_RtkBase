#!/bin/bash
RTKBASE_USER=rtkbase
RTKBASE_PATH=/usr/local/${RTKBASE_USER}
RTKBASE_GIT=${RTKBASE_PATH}/rtkbase/
BASEDIR=`dirname $(readlink -f "$0")`
#echo BASEDIR=${BASEDIR}
RECVPORT=/dev/ttyS0
RTKBASE_INSTALL=rtkbase_install.sh
RUN_CAST=run_cast.sh
SET_BASE_POS=UnicoreSetBasePos.sh
UNICORE_SETTIGNS=UnicoreSettings.sh
NMEACONF=NmeaConf 

configure_ttyS0(){
  CMDLINE=$1/cmdline.txt
  BOOTCONFIG=$1/config.txt
  #echo \$1=${1} CMDLINE=${CMDLINE} BOOTCONFIG=${BOOTCONFIG}

  if [[ -f ${CMDLINE} ]]
  then
     HAVE_CONSOLE_LOGIN=`grep "console=serial0" ${CMDLINE}`
     #echo HAVE_CONSOLE_LOGIN=${HAVE_CONSOLE_LOGIN}

     if [[ ${HAVE_CONSOLE_LOGIN} != "" ]]
     then 
        sed -i s/console=serial[0-9],[0-9]*\ //  "${CMDLINE}"
        #cat ${CMDLINE}
        #echo
        echo Cnahged ${CMDLINE}
        NEEDREBOOT=Y
     fi
  fi

  if [[ -f ${BOOTCONFIG} ]]
  then
     HAVE_UART=`grep "enable_uart=" ${BOOTCONFIG}`
     #echo HAVE_UART=${HAVE_UART}

     if [[ ${HAVE_UART} == "" ]]
     then 
        echo [all] >> ${BOOTCONFIG}
        echo >> ${BOOTCONFIG}
        echo enable_uart=1 >> ${BOOTCONFIG}
        echo uart added to ${BOOTCONFIG}
        NEEDREBOOT=Y
     fi

     ENABLED_UART=`grep "enable_uart=1" ${BOOTCONFIG}`
     #echo ENABLED_UART=${ENABLED_UART}

     if [[ ${ENABLED_UART} == "" ]]
     then 
        sed -i s/^enable_uart=.*/enable_uart=1/  "${BOOTCONFIG}"
        echo Uart enabled at ${BOOTCONFIG}
        NEEDREBOOT=Y
     fi
  fi
}

WHOAMI=`whoami`
if [[ ${WHOAMI} != "root" ]]
then 
   #echo use sudo
   sudo ${0}
   #echo exit after sudo
   exit
fi
#echo i am ${WHOAMI}$

echo '################################'
echo 'CHECK BOOT CONFIGURATION'
echo '################################'

configure_ttyS0 /boot
configure_ttyS0 /boot/firmware

#echo NEEDREBOOT=${NEEDREBOOT}
if [[ ${NEEDREBOOT} == "Y" ]]
then 
   echo Please try again ${0} after reboot
   reboot now
   exit
fi

if [[ ! -c "${RECVPORT}" ]]
then 
   echo port ${RECVPORT} not found. Setup port and try again
   exit
fi

if [[ ! -f "/usr/sbin/ser2net" ]]
then 
   apt-get install -y ser2net
fi

SER2NET_CONF=/etc/ser2net.conf
SER2NET_DEV=${RECVPORT}:115200
if [[ -f "${SER2NET_CONF}" ]]
then 
   SER2NET_HAVEDEV=`grep "${SER2NET_DEV}" ${SER2NET_CONF}`
fi
#echo SER2NET_HAVEDEV=${SER2NET_HAVEDEV}

if [[ ${SER2NET_HAVEDEV} == "" ]]
then 
   echo 5017:raw:0:${SER2NET_DEV} >>${SER2NET_CONF}
   #echo 5017:raw:0:${SER2NET_DEV}
else
   sed -i s@^.*${SER2NET_DEV}@5017:raw:0:${SER2NET_DEV}@ ${SER2NET_CONF}
   #echo sed -i s@^.*${SER2NET_DEV}@5017:raw:0:${SER2NET_DEV}@ ${SER2NET_CONF}
fi

systemctl restart ser2net

if [[ ! -f "/usr/bin/avahi-resolve" ]]
then
   apt-get install -y avahi-utils
fi

avahi_active=$(sudo systemctl is-active avahi-daemon)
#echo avahi_active=$avahi_active
if [[ $avahi_active != 'active' ]]
then
   apt-get install -y avahi-daemon
fi

STANDART_HOST=raspberrypi
#STANDART_HOST=rtkbase
RTKBASE_HOST=${RTKBASE_USER}
#RTKBASE_HOST=raspberrypi
CHANGE_HOST=N

NOW_HOST=`hostname`
#echo NOW_HOST=$NOW_HOST
if [[ $NOW_HOST = $STANDART_HOST ]]
then
   CHANGE_HOST=Y
fi

HOSTNAME=/etc/hostname
NOW_HOSTNAME=`cat $HOSTNAME`
#echo NOW_HOSTNAME=$NOW_HOSTNAME
if [[ $NOW_HOSTNAME = $STANDART_HOST ]]
then
   CHANGE_HOST=Y
fi

HOSTS=/etc/hosts
NOW_HOSTS=`grep "127.0.1.1" $HOSTS | awk -F ' ' '{print $2}'`
#echo NOW_HOSTS=$NOW_HOSTS
if [[ $NOW_HOSTS = $STANDART_HOST ]]
then
   CHANGE_HOST=Y
fi

if [[ $CHANGE_HOST = Y ]]
then
   hostname $RTKBASE_HOST
   echo $RTKBASE_HOST >$HOSTNAME
   sed -i s/127\.0\.1\.1.*/127\.0\.1\.1\ $RTKBASE_HOST/ "$HOSTS"
   systemctl restart avahi-daemon
fi

echo '################################'
echo 'UNPACK FILES'
echo '################################'

# Find __ARCHIVE__ marker, read archive content and decompress it
ARCHIVE=$(awk '/^__ARCHIVE__/ {print NR + 1; exit 0; }' "${0}")
# Check if there is some content after __ARCHIVE__ marker (more than 100 lines)
[[ $(sed -n '/__ARCHIVE__/,$p' "${0}" | wc -l) -lt 100 ]] && echo "UM980_RPI_Hat_RtkBase isn't bundled inside install.sh" && exit 1  
tail -n+${ARCHIVE} "${0}" | tar xpJv

echo '################################'
echo 'CONFIGURE RECEIVER'
echo '################################'

#store service status before upgrade
rtkbase_web_active==$(sudo systemctl is-active rtkbase_web.service)
str2str_active=$(sudo systemctl is-active str2str_tcp)
str2str_ntrip_A_active=$(sudo systemctl is-active str2str_ntrip_A)
str2str_ntrip_B_active=$(sudo systemctl is-active str2str_ntrip_B)
str2str_local_caster=$(sudo systemctl is-active str2str_local_ntrip_caster)
str2str_rtcm=$(sudo systemctl is-active str2str_rtcm_svr)
str2str_serial=$(sudo systemctl is-active str2str_rtcm_serial)
str2str_file=$(sudo systemctl is-active str2str_file)

# stop previously running services
[ $rtkbase_web_active = 'active' ] && sudo systemctl stop rtkbase_web.service
[ $str2str_active = 'active' ] && sudo systemctl stop str2str_tcp
[ $str2str_ntrip_A_active = 'active' ] && sudo systemctl stop str2str_ntrip_A
[ $str2str_ntrip_B_active = 'active' ] && sudo systemctl stop str2str_ntrip_B
[ $str2str_local_caster = 'active' ] && sudo systemctl stop str2str_local_ntrip_caster
[ $str2str_rtcm = 'active' ] && sudo systemctl stop str2str_rtcm_svr
[ $str2str_serial = 'active' ] && sudo systemctl stop str2str_rtcm_serial
[ $str2str_file = 'active' ] && sudo systemctl stop str2str_file

chmod +x ${BASEDIR}/${NMEACONF}

RECVVER=`${BASEDIR}/${NMEACONF} ${RECVPORT} VERSION QUIET`
#echo RECVVER=${RECVVER}
RECVNAME=`echo ${RECVVER} | awk -F ',' '{print $10}' | awk -F ';' '{print $2}'`
#echo RECVNAME=${RECVNAME}

if [[ ${RECVNAME} == "" ]]
then 
   echo Receiver on ${RECVPORT} not found. Setup receiver and try again
   exit
else
   echo Receiver ${RECVNAME} found on ${RECVPORT}
fi

RECVCONF=${BASEDIR}/${RECVNAME}_RTCM3_OUT.txt

if [[ ! -f "${RECVCONF}" ]]
then 
   echo Confiuration file for ${RECVNAME} \(${RECVCONF}\) NOT FOUND.
   exit
fi

${BASEDIR}/${NMEACONF} ${RECVPORT} ${RECVCONF} QUIET

echo '################################'
echo 'ADD RTKBASE USER'
echo '################################'

if [[ ! -d "${RTKBASE_PATH}" ]]
then 
   #echo mkdir ${RTKBASE_PATH}
   mkdir ${RTKBASE_PATH}
fi

HAVEUSER=`cat /etc/passwd | grep ${RTKBASE_USER}`
#echo HAVEUSER=${HAVEUSER}
if [[ ${HAVEUSER} == "" ]]
then 
   #echo adduser --comment "RTKBase user" --disabled-password --home ${RTKBASE_PATH} ${RTKBASE_USER}
   adduser --comment "RTKBase user" --disabled-password --home ${RTKBASE_PATH} ${RTKBASE_USER}
fi

RTKBASE_SUDOER=/etc/sudoers.d/${RTKBASE_USER}
#echo RTKBASE_SUDOER=${RTKBASE_SUDOER}
if [[ ! -f "${RTKBASE_SUDOER}" ]]
then 
   #echo echo "rtkbase ALL=NOPASSWD: ALL" \> ${RTKBASE_SUDOER}
   echo "rtkbase ALL=NOPASSWD: ALL" > ${RTKBASE_SUDOER}
fi

echo '################################'
echo 'COPY RTBASE INSTALL FILE'
echo '################################'

#echo ${RTKBASE_PATH}
cd ${RTKBASE_PATH}

CACHE_PIP=${RTKBASE_PATH}/.cache/pip
#echo CACHE_PIP=${CACHE_PIP}
if [[ ! -d ${CACHE_PIP} ]]
then
   #echo mkdir -p ${CACHE_PIP}
   mkdir -p ${CACHE_PIP}
fi
#echo chown ${RTKBASE_USER}:${RTKBASE_USER} ${CACHE_PIP}
chown ${RTKBASE_USER}:${RTKBASE_USER} ${CACHE_PIP}

#echo cp ${BASEDIR}/${RTKBASE_INSTALL} ${RTKBASE_PATH}/
mv ${BASEDIR}/${RTKBASE_INSTALL} ${RTKBASE_PATH}/
#echo chmod +x ${RTKBASE_PATH}/${RTKBASE_INSTALL}
chmod +x ${RTKBASE_PATH}/${RTKBASE_INSTALL}
#echo ${RTKBASE_PATH}/${RTKBASE_INSTALL} -u ${RTKBASE_USER} -j -d -r -t -g
${RTKBASE_PATH}/${RTKBASE_INSTALL} -u ${RTKBASE_USER} -j -d -r -t -g

echo '################################'
echo 'CONFIGURE FOR UNICORE'
echo '################################'

#echo cp ${BASEDIR}/${RUN_CAST} ${RTKBASE_GIT}
mv ${BASEDIR}/${RUN_CAST} ${RTKBASE_GIT}
#echo cp ${BASEDIR}/${SET_BASE_POS} ${RTKBASE_GIT}
mv ${BASEDIR}/${SET_BASE_POS} ${RTKBASE_GIT}
#echo chmod +x ${RTKBASE_PATH}/${SET_BASE_POS}
chmod +x ${RTKBASE_GIT}${SET_BASE_POS}
#echo cp ${BASEDIR}/${NMEACONF} ${RTKBASE_GIT}
mv ${BASEDIR}/${NMEACONF} ${RTKBASE_GIT}

#echo cp ${BASEDIR}/${UNICORE_SETTIGNS} ${RTKBASE_PATH}/
mv ${BASEDIR}/${UNICORE_SETTIGNS} ${RTKBASE_PATH}/
#echo chmod +x ${RTKBASE_PATH}/${UNICORE_SETTIGNS}
chmod +x ${RTKBASE_PATH}/${UNICORE_SETTIGNS}
#echo ${RTKBASE_PATH}/${UNICORE_SETTIGNS}
${RTKBASE_PATH}/${UNICORE_SETTIGNS} ${RECVNAME}

SERVER_PY=${RTKBASE_GIT}web_app/server.py 
#echo SERVER_PY=${SERVER_PY}
sed -i s/^rtkcv_standby_delay\ *=.*/rtkcv_standby_delay\ =\ 129600/ ${SERVER_PY}

#echo rm -f ${RTKBASE_PATH}/${UNICORE_SETTIGNS}
rm -f ${RTKBASE_PATH}/${UNICORE_SETTIGNS}
#echo ./${RTKBASE_INSTALL} -u ${RTKBASE_USER} -s
${RTKBASE_PATH}/${RTKBASE_INSTALL} -u ${RTKBASE_USER} -s

echo '################################'
echo 'DELETE GARBAGE'
echo '################################'

#echo cd ${BASEDIR}
cd ${BASEDIR}
rm -f UM980_RTCM3_OUT.txt UM982_RTCM3_OUT.txt install.sh 
exit

__ARCHIVE__
