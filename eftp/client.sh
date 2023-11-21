#!/bin/bash

SERVER="localhost"

echo "(1) Send"

echo "Cliente de EFTP"

echo "EFTP 1.0" | nc $SERVER 3333

echo "(2) Listen"

DATA= `nc -l -p 3333 -w 0`

echo $DATA

echo "(5) Test & Send"

if [ "$DATA" != "OK_HEADER" ]
then
	echo "ERROR 1: BAD_HEADER"
	exit 1
fi

echo "BOOOM"
sleep 1
echo "BOOOM" | nc $SERVER 3333

echo "(6) Listen"

DATA=`nc -l -p 3333 -w 0`

echo $DATA


