#!/usr/bin/env bash

set -eux -o pipefail

BATTERY_REMAINING=$(acpi --battery | grep -E -o '[0-9]+%' | tr -d '%')

if [ "${BATTERY_REMAINING}" -le 20 ] ; then
    echo "la batería está agotándose, quedan ${BATTERY_REMAINING}%" | espeak -v es-la
fi
