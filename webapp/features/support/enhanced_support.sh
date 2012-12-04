#!/bin/sh

SHOW_FIREFOX=$1
USE_DEBUGGER=$2

features/support/enhanced_support_stop.sh 

Xvfb :99 -ac -extension GLX > log/xvfb.log 2>&1 &

if [ "$SHOW_FIREFOX" = "true" ]
then
echo "Loading selenium on 4444, showing Firefox"
bundle exec selenium -port 4444 -firefoxProfileTemplate './features/support/firefox-36-profile' > log/selenium_java.log 2>&1 &
else
echo "Loading selenium on 4444, hiding Firefox"
DISPLAY=:99 bundle exec selenium -port 4444 > log/selenium_java.log 2>&1 &
fi

if [ "$USE_DEBUGGER" = "true" ]
then
  echo "Loading web server on 8080 with debugger"
  bundle exec script/server -e feature -p 8080 -P /trisano --debugger -d 
else
  echo "Loading web server on 8080 without debugger"
  bundle exec script/server -e feature -p 8080 -P /trisano -d
fi
