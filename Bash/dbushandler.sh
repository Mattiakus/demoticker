#!/bin/bash

ACCOUNT=$(cat ./Data/Account)
LOGFILE="./Data/log.txt"


signal-cli daemon --dbus | while read line; do
	echo "$line" >> ./Data/instream1
done
