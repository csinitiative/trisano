#!/bin/sh

# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

# Step 1: Copy XML config files
# Step 2: Copy custom jar files
# Step 3: Configure BI for Postgres
# Step 4: Pre-publish OLAP schema
# Step 5: Customize admin console
# Step 6: Tar it all up

if [ $# != 2 ] ; then
    echo "Usage: $0 path_to_bi_server path_to_trisano_source_code"
    exit
fi

BI_SERVER_HOME=$1
TRISANO_SOURCE_HOME=$2

if [ ! -d $BI_SERVER_HOME/pentaho-solutions ]; then
    echo "$BI_SERVER_HOME is not the root directory of the BI Server"
    exit
fi

if [ ! -d $TRISANO_SOURCE_HOME/bi ]; then
    echo "$BI_SERVER_HOME is not the root directory of the TriSano source tree"
    exit
fi

# Step 1: Copy XML config files
echo "Configuring BI Server to use SiteMinder"

# Backup originals
cp $BI_SERVER_HOME/pentaho-solutions/system/applicationContext-acegi-security.xml $BI_SERVER_HOME/pentaho-solutions/system/applicationContext-acegi-security.xml.org
cp $BI_SERVER_HOME/pentaho-solutions/system/pentaho-spring-beans.xml $BI_SERVER_HOME/pentaho-solutions/system/pentaho-spring-beans.xml.org
cp $BI_SERVER_HOME/pentaho-solutions/system/pentaho.xml $BI_SERVER_HOME/pentaho-solutions/system/pentaho.xml.org

# Copy in new ones
cp $TRISANO_SOURCE_HOME/bi/bi_server_replacement_files/applicationContext-acegi-security-siteminder.xml $BI_SERVER_HOME/pentaho-solutions/system/
cp $TRISANO_SOURCE_HOME/bi/bi_server_replacement_files/applicationContext-acegi-security.xml $BI_SERVER_HOME/pentaho-solutions/system/
cp $TRISANO_SOURCE_HOME/bi/bi_server_replacement_files/pentaho-spring-beans.xml $BI_SERVER_HOME/pentaho-solutions/system/
cp $TRISANO_SOURCE_HOME/bi/bi_server_replacement_files/pentaho.xml $BI_SERVER_HOME/pentaho-solutions/system/

# Step 2: Copy custom jar files
echo "Copying Trisano custom java extensions to BI Server"
cp $TRISANO_SOURCE_HOME/bi/extensions/trisano/dist/* $BI_SERVER_HOME/tomcat/webapps/pentaho/WEB-INF/lib

# Step 3: Configure BI for Postgres
echo "Configuring BI Server to use PostgreSQL"
# Backup originals
cp $BI_SERVER_HOME/start-pentaho.sh $BI_SERVER_HOME/start-pentaho.sh.org
cp $BI_SERVER_HOME/stop-pentaho.sh $BI_SERVER_HOME/stop-pentaho.sh.org
cp $BI_SERVER_HOME/pentaho-solutions/system/quartz/quartz.properties  $BI_SERVER_HOME/pentaho-solutions/system/quartz/quartz.properties.org 
cp $BI_SERVER_HOME/pentaho-solutions/system/hibernate/hibernate-settings.xml $BI_SERVER_HOME/pentaho-solutions/system/hibernate/hibernate-settings.xml.org
cp $BI_SERVER_HOME/tomcat/webapps/pentaho/META-INF/context.xml $BI_SERVER_HOME/tomcat/webapps/pentaho/META-INF/context.xml.org

# Copy in new ones
cp $TRISANO_SOURCE_HOME/bi/bi_server_replacement_files/start-pentaho.sh $BI_SERVER_HOME
cp $TRISANO_SOURCE_HOME/bi/bi_server_replacement_files/stop-pentaho.sh $BI_SERVER_HOME
cp $TRISANO_SOURCE_HOME/bi/bi_server_replacement_files/quartz.properties $BI_SERVER_HOME/pentaho-solutions/system/quartz/
cp $TRISANO_SOURCE_HOME/bi/bi_server_replacement_files/hibernate-settings.xml $BI_SERVER_HOME/pentaho-solutions/system/hibernate
cp $TRISANO_SOURCE_HOME/bi/bi_server_replacement_files/context.xml $BI_SERVER_HOME/tomcat/webapps/pentaho/META-INF

# Step 5: Customize admin console
# Add Postgres JDBC driver to admin-console
cp $BI_SERVER_HOME/tomcat/common/lib/postgresql-8.2-504.jdbc3.jar $ADMIN_CONSOLE_HOME/jdbc/


