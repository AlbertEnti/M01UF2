#!/bin/bash

IP=`ip address | grep inet | head -n 3 | tail -n 1 | cut -d " " -f 6 | cut -d "/" -f 1`
SERVER="localhost"
PORT="$PORT"

echo $IP

echo "(1) Send"

echo "Cliente de EFTP"

echo "EFTP 1.0" | nc $SERVER $PORT

echo "(2) Listen"

DATA= `nc -l -p $PORT -w 0`

echo $DATA

echo "(5) Test & Send"

if [ "$DATA" != "OK_HEADER" ]
then
	echo "ERROR 1: BAD_HEADER"
	exit 1
fi

echo "BOOOM"
sleep 1
echo "BOOOM" | nc $SERVER $PORT

echo "(6) Listen"

DATA=`nc -l -p $PORT -w 0`

echo $DATA


