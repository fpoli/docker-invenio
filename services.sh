#!/bin/bash

start_services() {
	echo "[*] Starting the databases"
	service mysql start
	service redis-server start
	sleep 3
}

stop_services() {
	echo "[*] Gracefully stopping the databases"
	service redis-server stop
	service mysql stop
}

case "$1" in
	start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    *)
        echo "Usage: $0 {start|stop}" >&2
        exit 3
        ;;
esac

exit 0
