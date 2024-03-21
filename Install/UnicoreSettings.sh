#!/bin/bash

WHOAMI=`whoami`
if [[ ${WHOAMI} != "root" ]]
then
   #echo sudo ${0} ${1}
   sudo ${0} ${1}
   #echo exit after sudo
   exit
fi

rtkbase_path=$(pwd)/rtkbase
settings="${rtkbase_path}"/settings.conf
rtcm_msg="1005(10),1033(10),1077,1087,1097,1107,1117,1127"
rtcm_msg_full="1005,1033,1019,1020,1042,1044,1045,1046,1077,1087,1097,1107,1117,1127"

recvname=${1}
if [[ ${recvname} == "" ]]
then
   recvfullname=Unicore
else
   recvfullname=Unicore_${recvname}
fi
#echo recvfullname=${recvfullname}

#store service status before upgrade
rtkbase_web_active=$(systemctl is-active rtkbase_web.service)
str2str_active=$(systemctl is-active str2str_tcp)
#echo rtkbase_web_active=${rtkbase_web_active} str2str_active=${str2str_active}

# stop previously running services
#[ "${rtkbase_web_active}" = "active" ] && echo rtkbase_web.service Active
[ "${rtkbase_web_active}" = "active" ] && systemctl stop rtkbase_web.service
[ "${str2str_active}" = "active" ] && systemctl stop str2str_tcp

sed -i s/^position=.*/position=\'0\.00\ 0\.00\ 0\.00\'/ "${settings}"
sed -i s/^com_port=.*/com_port=\'ttyS0\'/ "${settings}"
sed -i s/^com_port_settings=.*/com_port_settings=\'115200:8:n:1\'/ "${settings}"
sed -i s/^receiver=.*/receiver=\'${recvfullname}\'/ "${settings}"
sed -i s/^receiver_format=.*/receiver_format=\'rtcm3\'/ "${settings}"
sed -i s/^antenna_info=.*/antenna_info=\'ELT0123\'/ "${settings}"

sed -i s/^svr_addr_a=.*/svr_addr_a=\'servers.onocoy.com\'/ "${settings}"
sed -i s/^svr_addr_b=.*/svr_addr_b=\'ntrip.rtkdirect.com\'/ "${settings}"
sed -i s/^svr_port_b=.*/svr_port_b=\'\'/ "${settings}"
sed -i s/^svr_pwd_b=.*/svr_pwd_b=\'TCP\'/ "${settings}"
sed -i s/^mnt_name_b=.*/mnt_name_b=\'TCP\'/ "${settings}"

sed -i s/^rtcm_msg_a=.*/rtcm_msg_a=\'${rtcm_msg}\'/ "${settings}"
sed -i s/^rtcm_msg_b=.*/rtcm_msg_b=\'${rtcm_msg}\'/ "${settings}"
sed -i s/^local_ntripc_msg=.*/local_ntripc_msg=\'${rtcm_msg}\'/ "${settings}"
sed -i s/^rtcm_svr_msg=.*/rtcm_svr_msg=\'${rtcm_msg_full}\'/ "${settings}"
sed -i s/^rtcm_serial_msg=.*/rtcm_serial_msg=\'${rtcm_msg_full}\'/ "${settings}"

# start previously running services
#[ "${rtkbase_web_active}" = "active" ] && echo rtkbase_web.service Active
[ "${rtkbase_web_active}" = "active" ] && systemctl start rtkbase_web.service
[ "${str2str_active}" = "active" ] && systemctl start str2str_tcp
