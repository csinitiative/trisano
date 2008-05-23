#!/bin/bash
export PATH=/usr/lib/firefox:$PATH

killall Xvfb

# Uses MRI as JRuby doesn't spawn processes
ruby -S rake -f $SELENIUM_GRID_HOME/Rakefile hub:stop & 
ruby -S rake -f $SELENIUM_GRID_HOME/Rakefile rc:stop_all PORTS=5000-5009 & 
