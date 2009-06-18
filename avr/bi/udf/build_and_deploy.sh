#!/bin/bash


. ./setCP.sh

rm trisano.jar
/home/josh/apps/pentaho-ee/java/bin/javac org/trisano/*.java || exit
jar -cv org > trisano.jar
rm ~/apps/pentaho-ee/server/biserver-ee/tomcat/webapps/pentaho/WEB-INF/lib/trisano.jar
cp trisano.jar ~/apps/pentaho-ee/server/biserver-ee/tomcat/webapps/pentaho/WEB-INF/lib/
pushd ~/apps/pentaho-ee/server/biserver-ee
sh stop-pentaho.sh
sleep 3
sh start-pentaho.sh
tail -f tomcat/logs/* logs/udf.log
