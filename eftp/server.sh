#!/bin/bash
CLIENT="localhost"
TIMEOUT="1"

echo "Servidor de EFTP"

echo "(0) Listen"

DATA=`nc -l -p 3333 -w $TIMEOUT`

echo $DATA

PREFIX=`echo $DATA | cut -d " " -f 1`
VERSION=`echo $DATA | cut -d " " -f 2`

echo "(3) Test & Send"

if [ "$PREFIX $VERSION" != "EFTP 1.0" ] 
then
	echo "ERROR 1: BAD HEADER"
	sleep 1
	echo "KO_HEADER" | nc $CLIENT 3333
	exit 1
fi 

CLIENT=`echo $DATA | cut -d " " -f 3`

echo "OK_HEADER"
sleep 1
echo "OK_HEADER" | nc $CLIENT 3333


echo "(4) Listen"

DATA=`nc -l -p 3333 -w $TIMEOUT`
echo $DATA

echo "(7) Test & Send"

PREFIX=`echo $DATA | cut -d " " -f 1`

if [ "$DATA" != "BOOOM" ]

then
    echo "ERROR 2: HANDSHAKE_ERROR"
	sleep 1
	echo "KO_HANDSHAKE" | nc $CLIENT 3333
	exit 2
fi
echo "OK_HANDSHAKE"
sleep 1
echo "OK_HANDSHAKE" | nc $CLIENT 3333

echo "(7a) Listen_Num_Files"
DATA=`nc -l -p 3333 -w $TIMEOUT`
echo $DATA

echo "(7b) SEND OK/KO_NUM_FILES"
PREFIX=`echo $DATA | cut -d " " -f 1`
if [ "$PREFIX" != "NUM_FILES" ]
then
 	echo "ERROR 3a: Wrong NUM_FILES PREFIX"
    echo "KO_FILE_NUM" | nc $CLIENT 3333
	exit 3
fi

echo "OK_FILE_NUM" | nc $CLIENT 3333

FILE_NUM=`echo $DATA | cut -d " " -f 2`

for N in `seq $FILE_NUM`
do
	echo "Archivo número $N"


echo "(8b) Listen"

DATA=`nc -l -p 3333 -w $TIMEOUT`
echo $DATA


echo "(12) Test & Store & Send "

PREFIX=`echo "$DATA" | cut -d " " -f 1`

if [ "$PREFIX" != "FILE_NAME" ]
then
	echo "Error 3: Bad_File_Name_Prefix"
	sleep 1
	echo "KO_FILE_NAME" | nc $CLIENT 3333
	exit 3
fi

FILE_NAME=`echo $DATA | cut -d " " -f 2`
FILE_MD5=`echo $DATA | cut -d " " -f 3`

FILE_MD5_LOCAL=`echo "$FILE_NAME" | md5sum | cut -d " " -f 1`
FILENAME=`echo "$DATA" | cut -d " " -f 2`

if [ "$FILE_MD5" != "$FILE_MD5_LOCAL" ]
then
	echo "ERROR 4: BAD FILE NAME MD5"
	sleep 1
	echo "KO_FILE_NAME" | nc $CLIENT 3333
	exit 4
fi
echo "OK_FILE_NAME" | nc $CLIENT 3333

echo "(13) Listen"

nc -l -p 3333 -w $TIMEOUT > inbox/$FILE_NAME

DATA=`cat inbox/$FILENAME`

echo "(16) Store & Send"

if [ "$DATA" == "" ]
then
	echo "Error 5: Empty Data"
	sleep 1
	echo "KO_CHAOCHAOCHAO" | nc $CLIENT 3333
	exit 5
fi

sleep 1
echo "OK_DATA" | nc $CLIENT 3333

echo "(17) Listen"
DATA=`nc -l -p 3333 -w $TIMEOUT`

echo "(20) Test & Send"

echo $DATA

PREFIX=`echo $DATA | cut -d " " -f 1`

if [ "$PREFIX" != "FILE_MD5" ]
then
	echo "Error 6: Bad File MD5 Prefix"
	echo "KO_FILE_MD5" | nc $CLIENT 3333
	exit 6
fi


FILE_MD5=`echo $DATA | cut -d " " -f 2`
FILE_MD5_LOCAL=`cat inbox/$FILENAME | md5sum | cut -d " " -f 1`

if [ "$FILE_MD5" != "$FILE_MD5_LOCAL" ]
then
	echo "Error 7: Bad File MD5"
	echo "KO_FILE_MD5" | nc $CLIENT 3333
	exit 7
fi

echo "OK_FILE_MD5" | nc $CLIENT 3333

done


echo "FIN"
exit 0

