#!/bin/bash

# Set TOMCAT_HOME environment variable to override default of/opt/tomcat/apache-tomcat-6.0.14

. setenv.sh

echo "Warning: Ensure that you run ./package_app.sh prior to running this script"
echo "Warning: Only currently supports local Tomcat instance"
jruby -S rake -f ../webapp/Rakefile trisano:deploy:redeploytomcat_no_smoke
