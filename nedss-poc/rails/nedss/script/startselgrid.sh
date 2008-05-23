#!/bin/bash
export PATH=/usr/lib/firefox:$PATH

Xvfb :99 -ac &
export DISPLAY=:99

# Uses MRI as JRuby doesn't spawn processes
ruby -S rake -f $SELENIUM_GRID_HOME/Rakefile hub:start & 
sleep 5
ruby -S rake -f $SELENIUM_GRID_HOME/Rakefile rc:start_all PORTS=5000-5009 ENVIRONMENT="*firefox" & 
