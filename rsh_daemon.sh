#!/bin/bash
# the script using for start/stop remote shell daemon server to replace the ssh server
PORT=19999
FILTER=~/tmp/_tmp_rsh_filter.sh
# the tsung master's hostname or ip
TSUNG_MASTER=tsung_master

PROG=`basename $0`

prepare() {
    cat << EOF > $FILTER
#!/bin/bash

ERL_PREFIX="erl"

while true
do
    read CMD
    case \$CMD in
        ping)
            echo "pong"
            exit 0
            ;;
        *)
            if [[ \$CMD == *"\${ERL_PREFIX}"* ]]; then
                exec \$CMD
            fi
            exit 0
            ;;
    esac
done
EOF
    chmod a+x $FILTER
}

start() {
    NUM=$(ps -ef|grep ncat | grep ${PORT} | grep -v grep | wc -l)

    if [ $NUM -gt 0 ];then
        echo "$PROG already running ..."
        exit 1
    fi

    if [ -x "$(command -v ncat)" ]; then
        echo "$PROG starting now ..."
        ncat -4 -k -l $PORT -e $FILTER --allow $TSUNG_MASTER &
    else
        echo "no exists ncat command, please install it ..."
    fi
}

stop() {
    NUM=$(ps -ef|grep ncat | grep rsh | grep -v grep | wc -l)

    if [ $NUM -eq 0 ]; then
        echo "$PROG had already stoped ..."
    else
        echo "$PROG is stopping now ..."
        ps -ef|grep ncat | grep rsh | grep -v grep | awk '{print $2}' | xargs kill
    fi
}

status() {
    NUM=$(ps -ef|grep ncat | grep rsh | grep -v grep | wc -l)

    if [ $NUM -eq 0 ]; then
        echo "$PROG had already stoped ..."
    else
        echo "$PROG is running ..."
    fi
}

usage() {
    echo "Usage: $PROG <options> start|stop|status|restart"
    echo "Options:"
    echo "    -a <hostname/ip>  allow only given hosts to connect to the server (default is tsung_master)"
    echo "    -p <port>         use the special port for listen (default is 19999)"
    echo "    -h                display this help and exit"
    exit
}

while getopts "a:p:h" Option
do
    case $Option in
        a) TSUNG_MASTER=$OPTARG;;
        p) PORT=$OPTARG;;
        h) usage;;
        *) usage;;
    esac
done
shift $(($OPTIND - 1))

case $1 in
        start)
            prepare
            start
            ;;
        stop)
            stop
            ;;
        status)
            status
            ;;
        restart)
            stop
            start
            ;;
        *)
            usage
            ;;
esac
