#!/bin/bash

echo 'creating nedss war'
jruby -S rake war:standalone:create

echo 'deploying to tomcat'
cp nedss.war /home/mike/opt/apache-tomcat-6.0.14/webapps/
