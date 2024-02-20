#!/bin/bash
#Tar command to create a release, excluding unuseful folders and files.

ARCHIVE_NAME='UM980_RPI_Hat_rtkbase.tar.xz'
BUNDLE_NAME='../install.sh'
TAR_ARG='-cJf'

tar --exclude-vcs \
    $TAR_ARG $ARCHIVE_NAME \
    NmeaConf UM980_RTCM3_OUT.txt UM982_RTCM3_OUT.txt \
    run_cast.sh UnicoreSetBasePos.sh UnicoreSettings.sh \
    uninstall.sh rtkbase_install.sh 
 
cat install_script.sh $ARCHIVE_NAME > $BUNDLE_NAME
chmod +x $BUNDLE_NAME
rm -f $ARCHIVE_NAME
echo '========================================================'
echo 'Bundled script ' $BUNDLE_NAME ' created inside' $(pwd)
echo '========================================================'
