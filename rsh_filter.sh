#!/bin/bash

ERL_PREFIX="erl"

while true
do
    read CMD

    case $CMD in
        ping)
            echo "pong"
            exit 0
            ;;

        *)
            if [[ $CMD == *"${ERL_PREFIX}"* ]]; then
                exec $CMD
            fi
            exit 0
            ;;
    esac
done
