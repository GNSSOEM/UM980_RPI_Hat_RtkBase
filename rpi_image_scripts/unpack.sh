#!/bin/sh

SOURCE_IMAGE="${1}"
DESTINATION_IMAGE="${2}"

echo Unpacking "${SOURCE_IMAGE}" to "${DESTINATION_IMAGE}"

if (echo "${SOURCE_IMAGE}" | grep -Eq '\.xz$')
then
  unxz -d -k --to-stdout "${SOURCE_IMAGE}" > "${DESTINATION_IMAGE}"
else
  cp "${SOURCE_IMAGE}" "${DESTINATION_IMAGE}"
fi
