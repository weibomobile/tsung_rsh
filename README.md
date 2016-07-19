## INTRO

In many case, the master does not allow we use the SSH tunnel for connection between servers. 

In order to bypass limit, I designed the light weight remote shell suite, which as SSH working with Tsung nodes, and working well.

## How To Use it

### 1. Starting the `rsh_daemon.sh`

#### `rsh_daemon.sh` Usage

```bash
Usage: rsh_daemon.sh <options> start|stop|status|restart
Options:
    -a <hostname/ip>  allow only given hosts to connect to the server (default is tsung_master)
    -p <port>         use the special port for listen (default is 19999)
    -h                display this help and exit
```

NOTE:

- The allowed given hosts should be the Tsung master's hostname/IP, and can solved it
- Do not modified the listening port default value **19999**, unless you wang to change, then don't forget to modified the `rsh_client.sh`'s PORT value

Within the Tsung nodes server, starting it:

```bash
sh rsh_daemon.sh -a tsung_master start
```

#### The `rsh_filter.sh`

The `rsh_filter.sh` just for executing the client's command:

1. Receive `ping`, output `pong`
2. Executing the `erl` command

#### How debug the rsh daemon server ?

First of all, starting the daemon :

```bash
sh rsh_daemon.sh -a 127.0.0.1,tsung_master start
```

Just use the `nc` or `ncat` build-in command as one simulator client:

```bash
nc 127.0.0.1 19999
```

Then type `ping` and entry, you will get `pong` response.

Now, start the remote Erlang Shell:

```bash
ncat 127.0.0.1 19999
```

Type the command :

```bash
erl -sname foo
```
You will get output, and you can have a try now.

```bash
Eshell V7.1  (abort with ^G)
(foo@weibomobile)1>
```

### 2. Starting Tsung with `rsh_client.sh`

```bash
tsung -r /the_path/rsh_client.sh -f tung.xml
```

> `rsh_client.sh` fixed the target host's port is **19999**

## Summary

The project is to replace the SSH for Tsung Clusters, and it get it now :))

