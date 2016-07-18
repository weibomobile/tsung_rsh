#!/bin/sh

PORT=19999

if [ $# -lt 2  ]; then
    echo "Invalid number of parameters"
    exit 1
fi

REMOTEHOST="$1"
COMMAND="$2"

if [ "${COMMAND}" != "erl"  ]; then
    echo "Invalid command ${COMMAND}"
    exit 1
fi

shift 2

echo "${COMMAND} $*" | /usr/bin/nc ${REMOTEHOST} ${PORT}
