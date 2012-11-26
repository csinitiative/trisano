#!/bin/sh

USE_DEBUGGER=$1

if [ "$USE_DEBUGGER" = "true" ]
then
PIDS=`ps aux | grep -i "sel\|Xvfb" | grep -v grep | awk '{print $2}'`
else
PIDS=`ps aux | grep -i "-e feature -p 8080 -P\|sel\|Xvfb" | grep -v grep | awk '{print $2}'`
fi


echo $PIDS
kill $PIDS
