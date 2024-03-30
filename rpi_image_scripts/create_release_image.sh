#!/bin/sh

set -e

SOURCE_IMAGE=2023-10-10-raspios-bookworm-arm64-lite.img.xz
DESTINATION_IMAGE=2023-10-10-raspios-bookworm-arm64-lite-eltehs-rtkbase-004.img
LOOPDEV=/dev/loop0
RESIZETOSIZE=3561MB
APPENDSIZEMB=800

./unpack.sh "${SOURCE_IMAGE}" "${DESTINATION_IMAGE}"

dd if=/dev/zero bs=1M count=${APPENDSIZEMB} >> "${DESTINATION_IMAGE}"

unshare -m -i ./mount_and_run_scripts.sh \
   `realpath -m ./raspbian64` \
   "${LOOPDEV}" \
   "${DESTINATION_IMAGE}" \
   "${RESIZETOSIZE}" \
   COPY install.sh \
   RUN \
      target_scripts/update_upgrade.sh \
      target_scripts/install_avahi.sh \
      target_scripts/rtkbase_install.sh

xz -z "${DESTINATION_IMAGE}"
echo "Resulting image: ${DESTINATION_IMAGE}.xz"
