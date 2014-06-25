#!/bin/bash

COMMAND="$@"
SERVER_PID=""

function quit() {
	if [ -n "$SERVER_PID" ]
	then
		kill -s SIGINT $SERVER_PID
	else
		echo "/!\\ No server running"
	fi
	sudo /home/docker/services.sh stop
	exit
}

if [ -z "$COMMAND" ]
then
	echo "/!\\ No command provided"
	exit
fi

sudo /home/docker/services.sh start

echo "[*] Executing '$COMMAND'"
serve -b 0.0.0.0 &
SERVER_PID=$!

trap "echo -e '\r[*] Received SIGINT, exiting...'; quit" SIGINT
trap "echo -e '\r[*] Received SIGQUIT, exiting...'; quit" SIGQUIT

wait $SERVER_PID
