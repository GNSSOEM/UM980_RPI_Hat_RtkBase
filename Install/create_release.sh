#!/bin/bash
#Tar command to create a release, excluding unuseful folders and files.

ARCHIVE_NAME='ELT_RTKBase.tar.xz'
BUNDLE_NAME='../install.sh'
TAR_ARG='-cJf'

tar --exclude-vcs \
    $TAR_ARG $ARCHIVE_NAME \
    NmeaConf UM980_RTCM3_OUT.txt UM982_RTCM3_OUT.txt \
    run_cast_sh.patch UnicoreSetBasePos.sh UnicoreSettings.sh \
    uninstall.sh rtkbase_install.sh UnicoreConfigure.sh \
    RtkbaseSystemConfigure.sh RtkbaseSystemConfigure.service \
    RtkbaseSystemConfigureProxy.sh server_py.patch \
    status_js.patch tune_power.sh config.txt rtklib/* \
    version.txt settings_js.patch base_html.patch \
    Bynav_RTCM3_OUT.txt Septentrio_TEST.txt \
    Septentrio_RTCM3_OUT.txt settings_html.patch \
    ppp_conf.patch config.original tailscale_get_href.sh \
    system_upgrade.sh exec_update.sh
 
cat install_script.sh $ARCHIVE_NAME > $BUNDLE_NAME
chmod +x $BUNDLE_NAME
rm -f $ARCHIVE_NAME
echo '========================================================'
echo 'Bundled script ' $BUNDLE_NAME ' created inside' $(pwd)
echo '========================================================'
