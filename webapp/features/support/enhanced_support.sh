#!/bin/sh

SHOW_FIREFOX=$1
USE_DEBUGGER=$2

if [ "$USE_DEBUGGER" = "true" ]
then
features/support/enhanced_support_stop.sh true
else
features/support/enhanced_support_stop.sh 
fi

Xvfb :99 -ac -extension GLX > log/xvfb.log 2>&1 &

if [ "$SHOW_FIREFOX" = "true" ]
then
echo "Loading selenium with display of Firefox"
bundle exec selenium > log/selenium_java.log 2>&1 &
else
echo "Loading selenium hiding Firefox"
DISPLAY=:99 bundle exec selenium > log/selenium_java.log 2>&1 &
fi

if [ "$USE_DEBUGGER" = "true" ]
then
#bundle exec script/server -e feature -p 8080 -P /trisano --debugger &
echo "Please start bundle exec script/server -e feature -p 8080 -P /trisano --debugger in another window"
else
bundle exec script/server -e feature -p 8080 -P /trisano > log/selenium_server.log &
fi
