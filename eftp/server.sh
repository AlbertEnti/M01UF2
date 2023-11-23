#!/bin/bash

CLIENT="localhost"
PORT= "3333"

echo $IP

echo "Servidor de EFTP"

echo "(0) Listen"

DATA=`nc -l -p $PORT -w 0`

echo $DATA

echo "(3) Test & Send"

if [ "$DATA" != "EFTP 1.0" ] 
then
	echo "ERROR 1: BAD HEADER"
	sleep 1
	echo "KO_HEADER" | nc $CLIENT $PORT
	exit 1
fi 

echo "OK_HEADER"
sleep 1
echo "OK_HEADER" | nc $CLIENT $PORT


echo "(4) Listen"

DATA=`nc -l -p $PORT -w 0`

echo "(7) Test & Send"

if [ "$DATA" != "BOOOM" ]

then 
	echo "ERROR 2: HANDSHAKE_ERROR"
	sleep 1
	echo "KO_HANDSHAKE" | nc $CLIENT $PORT
	exit 2
fi

echo "OK_HANDSHAKE"
sleep 1
echo "OK_HANDSHAKE" | nc $CLIENT $PORT

echo "(8) Listen"

DATA=`nc -l -p $PORT -w 0`


echo "(12) Test & Store & Send "

PREFIX= `echo $DATA | cut -d " " -f 1 `

if [ "$PREFIX" == "FILE_NAME" ]

then
	echo "Error 3: Bad_File_Name_Prefix"
	sleep 1
	echo "KO_FILE_NAME" | nc $CLIENT 3333
	exit 3
fi


FILENAME= `echo $DATA | cut -d " " -f 2`

echo "OK_COLEGA" | nc $CLIENT 3333

echo "(13) Listen"

FILENAME= `echo $DATA | cut -d " " -f 2`
DATA=`nc -l -p $PORT -w 0`

echo "(16) Store & Send"

if [ "$DATA" == "" ]
then
	echo "Error 4: Vaya locura de error jefe"
	sleep 1
	echo "KO_CHAOCHAOCHAO" | nc $CLIENT 3333
	exit 4
fi

echo $DATA > inbox/$FILE_NAME

exit 0

