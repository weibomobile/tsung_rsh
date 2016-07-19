#!/bin/bash

cmdstr="erl"

while true
do
    read cmd

    case $cmd in
        ping)
            echo "pong"
            exit 0
            ;;

        *)
            if [[ $cmd == *"${cmdstr}"* ]]; then
                exec $cmd
            fi
            exit 0
            ;;
    esac
done
