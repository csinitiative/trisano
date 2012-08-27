#!/bin/sh

# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the 
# terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

# Path to JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-6-sun/jre/

# Path on the file system where the BI server was installed
export BI_SERVER_PATH=/opt/avr/biserver-ee

# Path for plugins
export TRISANO_PLUGIN_DIRECTORY=/opt/avr/etl/plugins/

# JDBC database driver class
export TRISANO_DB_DRIVER="org.postgresql.Driver"

# Credentials for warehouse database
export TRISANO_DB_USER="trisano_user"
export TRISANO_DB_PASSWORD="password"

# JDBC connection information
export TRISANO_DB_HOST='localhost'
export TRISANO_DB_PORT='5432'
export TRISANO_DB_NAME='avr_db'
export TRISANO_JDBC_URL="jdbc:postgresql://${TRISANO_DB_HOST}:${TRISANO_DB_PORT}/${TRISANO_DB_NAME}"

# URL that the BI server can is running on (needed to publish updates)
export BI_SERVER_URL="https://localhost:18080"
export BI_PUBLISH_URL="${BI_SERVER_URL}/pentaho/RepositoryFilePublisher"
export BI_PUBLISH_PASSWORD="publishpasswd"

# User credentials for an admin on the BI server. (also needed for
# publishing)
export BI_USER_NAME=joe
export BI_USER_PASSWORD=password

export PENTAHO_SECURITY_FILE=

# move to the script's dir because we can't change where pentaho looks
# for some things.
cd $BI_SERVER_PATH/pentaho-solutions/TriSano

CLASSPATH=$CLASSPATH:$BI_SERVER_PATH/tomcat/webapps/pentaho/WEB-INF/lib/jruby-complete-1.5.2.jar

for i in $BI_SERVER_PATH/tomcat/lib/*; do
    CLASSPATH=$CLASSPATH:$i
done

$JAVA_HOME/bin/java \
        -cp $CLASSPATH org.jruby.Main \
        $BI_SERVER_PATH/pentaho-solutions/TriSano/build_metadata.rb | grep -v DEBUG
        #-Djavax.net.ssl.trustStore=/opt/avr/biserver-ee/ssl/keystore \
        #-Djavax.net.ssl.trustStorePassword=changeit \
