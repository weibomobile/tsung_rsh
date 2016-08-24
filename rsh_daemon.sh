#!/bin/bash
# the script using for start/stop remote shell daemon server to replace the ssh server
PORT=19999
FILTER=~/tmp/_tmp_rsh_filter.sh
# the tsung master's hostname or ip
TSUNG_MASTER=tsung_master
SPECIAL_PATH=""
SEC_KEY=""
CMD_PREFIX="erl"
REGISTER_URL=""
PROG=`basename $0`

prepare() {
    mkdir -p ~/tmp/
    cat << EOF > $FILTER
#!/bin/bash

ERL_PREFIX="$CMD_PREFIX"

while true
do
    read CMD
    case \$CMD in
        ping)
            echo "pong"
            exit 0
            ;;
        *)
            if [[ "${SEC_KEY}" != "" ]]; then
                if [[ \$CMD == "$SEC_KEY"* ]]; then
                    Index=${#SEC_KEY}
                    RealCmd=\${CMD:\$Index}
                else
                    echo "Invalid Access"
                    exit 0
                fi
            else
                RealCmd=\${CMD}
            fi

            if [[ \$RealCmd == *"\${ERL_PREFIX}"* ]]; then
                exec $SPECIAL_PATH\${RealCmd}
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

        if [[ "$TSUNG_MASTER" != "" ]]; then
            ncat -4 -k -l $PORT -e $FILTER --allow $TSUNG_MASTER &
        else
            ncat -4 -k -l $PORT -e $FILTER &
        fi
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

callback() {
    if [ -x "$(command -v curl)" ] && [[ "$REGISTER_URL" != "" ]]; then
        echo "$PROG starting call register_url : $REGISTER_URL ..."
        curl "$REGISTER_URL"
    else
        echo "no exists ncat command, please install it ..."
    fi
}

usage() {
    echo "Usage: $PROG <options> start|stop|status|restart|callback"
    echo "Options:"
    echo "    -a <hostname/ip>      allow only given hosts to connect to the server (default is tsung_master)"
    echo "    -p <port>             use the special port for listen (default is 19999)"
    echo "    -s <the_erl_path>     use the special erlang's erts bin path for running erlang (default is blank)"
    echo "    -k <the_sec_key>      use the special for access right (default is blank)"
    echo "    -c <the_cmd_prefix>   assign the special command (default is erl)"
    echo "    -r <the_callback_url> call the url (default is blank)"
    echo "    -h                    display this help and exit"
    exit
}

while getopts "a:p:s:k:c:u:h" Option
do
    case $Option in
        a) TSUNG_MASTER=$OPTARG;;
        p) PORT=$OPTARG;;
        s) TMP_ERL=$OPTARG
            if [ "$OPTARG" != "" ]; then
                if [[ "$OPTARG" == *"/" ]]; then
                    SPECIAL_PATH=$OPTARG
                else
                    SPECIAL_PATH=$OPTARG"/"
                fi
            fi
            ;;
        k) SEC_KEY=$OPTARG;;
        c) CMD_PREFIX=$OPTARG;;
        u) REGISTER_URL=$OPTARG;;
        h) usage;;
        *) usage;;
    esac
done
shift $(($OPTIND - 1))

case $1 in
        start)
            prepare
            start
            callback
            ;;
        stop)
            stop
            callback
            ;;
        status)
            status
            ;;
        restart)
            stop
            start
            callback
            ;;
        callback)
            callback
            ;;
        *)
            usage
            ;;
esac
