#!/bin/bash

IP=`ip address | grep inet | head -n 3 | tail -n 1 | cut -d " " -f 6 | cut -d "/" -f 1`
SERVER="localhost"
TIMEOUT="1"

echo $IP

echo "(1) Send"

echo "Cliente de EFTP"
echo "EFTP 1.0" | nc $SERVER 3333

echo "(2) Listen"
DATA=`nc -l -p 3333 -w $TIMEOUT`
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

DATA=`nc -l -p 3333 -w $TIMEOUT`
echo $DATA

echo "(9) Test"

if [ "$DATA" != "OK_HANDSHAKE" ]
then 
	echo "Error 2: BAD_HANDSHAKE"
	exit 2
fi

echo "(10) Send"

sleep 1

FILE_NAME="fary1.txt"

FILE_MD5=`echo $FILE_NAME | md5sum | cut -d " " -f 1`

echo "FILE_NAME $FILE_NAME $FILE_MD5" | nc $SERVER 3333

echo "(11) Listen"
DATA=`nc -l -p 3333 -w $TIMEOUT`

echo "(14) Test & Send"

if [ "$DATA" != "OK_FILE_NAME" ]
then
	echo "Error 3:BAD_COLEGA"
	echo "BAD_COLEGA" | nc $SERVER 3333
	exit 3
fi
sleep 1
cat imgs/fary1.txt | nc $SERVER 3333

echo "(15) Listen"
DATA=`nc -l -p 3333 -w $TIMEOUT`

if [ "$DATA" != "OK_DATA" ]
then
	echo "Error 4: BAD_DATA"
	exit 4
fi

echo "(18) Send"
FILE_MD5=`cat imgs/$FILE_NAME | md5sum | cut -d " " -f 1`
sleep 1
echo "FILE_MD5 $FILE_MD5" | nc $SERVER 3333

echo "(19) Listen"
DATA=`nc -l -p 3333 -w $TIMEOUT`




echo "FIN"
exit 0


