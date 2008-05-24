#!/bin/bash
export PATH=/usr/lib/firefox:$PATH

if [ "$SELENIUM_GRID_HEADLESS" = "true" ]; then
  echo "[Stopping X virtual frame buffer]"
  killall Xvfb
else
  echo "[NOT stopping X virtual frame buffer]"
fi

# Uses MRI as JRuby doesn't spawn processes
echo "[Stopping Selenium Grid Hub]"
ruby -S rake -f $SELENIUM_GRID_HOME/Rakefile hub:stop & 
sleep 2
echo "[Stopping Selenium Grid RCs - port range: $SELENIUM_GRID_PORTS]"
ruby -S rake -f $SELENIUM_GRID_HOME/Rakefile rc:stop_all PORTS="$SELENIUM_GRID_PORTS" & 
