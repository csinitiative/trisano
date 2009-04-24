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
cp $BI_SERVER_HOME/pentaho-solutions/system/applicationContext-acegi-security.xml $BI_SERVER_HOME/pentaho-solutions/system/applicationContext-acegi-security.xml.org
cp $BI_SERVER_HOME/pentaho-solutions/system/pentaho-spring-beans.xml $BI_SERVER_HOME/pentaho-solutions/system/pentaho-spring-beans.xml.org
cp $BI_SERVER_HOME/pentaho-solutions/system/pentaho.xml $BI_SERVER_HOME/pentaho-solutions/system/pentaho.xml.org
cp $TRISANO_SOURCE_HOME/bi/server_config_files/* $BI_SERVER_HOME/pentaho-solutions/system/

# Step 2: Copy custom jar files
echo "Copying Trisano custom java extensions to BI Server"
cp $TRISANO_SOURCE_HOME/bi/extensions/trisano/dist/* $BI_SERVER_HOME/tomcat/webapps/pentaho/WEB-INF/lib
