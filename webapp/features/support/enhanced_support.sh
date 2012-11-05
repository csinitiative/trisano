#!/bin/sh

SHOW_FIREFOX=$0

features/support/enhanced_support_stop.sh

Xvfb :99 \-ac > log/xvfb.log 2>&1 &

if [ "$SHOW_FIREFOX" = "true" ]
then
selenium > log/selenium_java.log 2>&1 &
else
DISPLAY=:99 selenium > log/selenium_java.log 2>&1 &
fi

script/server -e feature -p 8080 -P /trisano > log/selenium_server.log 2>&1 &
