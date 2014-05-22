#!/bin/bash

COMMAND="$@"

sudo /home/docker/services.sh start

if [ -n "$COMMAND" ]
then
	echo "[*] Executing '$COMMAND'"
	$COMMAND
else
	echo "/1\\ No command provided"
fi

sudo /home/docker/services.sh stop
