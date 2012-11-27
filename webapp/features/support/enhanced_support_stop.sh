#!/bin/sh

echo "Killing web server, selenium, Xvfb, Firefox"
PIDS=`ps aux | grep -i "-e feature -p 8080 -P /trisano\|sel\|Xvfb\|firefox-36/firefox-bin" | grep -v grep | awk '{print $2}'`
echo $PIDS
kill $PIDS
