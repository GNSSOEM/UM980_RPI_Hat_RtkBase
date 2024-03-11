#!/bin/bash
RTKBASE_USER=rtkbase
RTKBASE_PATH=/usr/local/${RTKBASE_USER}

WHOAMI=`whoami`
if [[ ${WHOAMI} != "root" ]]
then
   #echo use sudo
   sudo ${0} ${1}
   #echo exit after sudo
   exit
fi

RTKBASE_UNINSTALL=${RTKBASE_PATH}/rtkbase/tools/uninstall.sh
#echo RTKBASE_UNINSTAL=${RTKBASE_UNINSTALL}
if [[ -f "${RTKBASE_UNINSTALL}" ]]
then 
   ${RTKBASE_UNINSTALL}
fi

HAVEUSER=`cat /etc/passwd | grep ${RTKBASE_USER}`
#echo  HAVEUSER=${HAVEUSER}
if [[ ${HAVEUSER} != "" ]]
then 
  deluser ${RTKBASE_USER}
fi

rm -rf ${RTKBASE_PATH}
rm -f /etc/sudoers.d/${RTKBASE_USER}