#!/bin/bash

cmdstr="erl"

while true
do
    read cmd

    case $cmd in

        stop)
            PATH=$(cd `dirname $0`; pwd)
            ${PATH}/rsh_daemon.sh stop
            exit 0
            ;;

        ping)
            echo "pong"
            exit 0
            ;;

        *)
            if [[ $cmd == *"${cmdstr}"* ]]; then
                exec $cmd
            else
                exit 0
            fi
            ;;
    esac
done
