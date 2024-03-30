#!/bin/sh

SOURCE_IMAGE="${1}"
#SOURCE_IMAGE=2023-10-10-raspios-bookworm-arm64-lite-estimo-lv5-base.img

DESTINATION_IMAGE="${2}"
#DESTINATION_IMAGE=2023-10-10-raspios-bookworm-arm64-lite-estimo-lv5-006.img

if (echo "${SOURCE_IMAGE}" | grep -Eq '\.xz$')
then
  unxz -d -k --to-stdout "${SOURCE_IMAGE}" > "${DESTINATION_IMAGE}"
else
  cp "${SOURCE_IMAGE}" "${DESTINATION_IMAGE}"
fi
