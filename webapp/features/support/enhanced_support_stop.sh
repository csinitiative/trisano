#!/bin/sh

PIDS=`ps aux | grep -i "-e feature -p 8080 -P\|sel\|Xvfb" | grep -v grep | awk '{print $2}'`
echo $PIDS
kill $PIDS
