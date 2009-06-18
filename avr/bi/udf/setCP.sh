libdir="/home/josh/apps/pentaho-ee/server/biserver-ee/tomcat/webapps/pentaho/WEB-INF/lib"

for i in $libdir/*.jar; do
    CLASSPATH=$CLASSPATH:$i
done

export CLASSPATH
