#!/bin/bash

# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013
# The Collaborative Software Foundation
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

if [ $# -ne 2 ] ; then
    echo
    echo "USAGE: $0 path_to_all_bi_products path_to_trisano_source_code"
    echo
    echo "Create a single directory into which you have downloaded all the relevant Pentaho"
    echo "Community bits: BI Server and Report Designer.  Provide that directory name as the"
    echo " first argument.  The second argument is the path to your local TriSano working copy."
    echo
    exit
fi

BI_BITS_HOME=${1%/}
TRISANO_SOURCE_HOME=${2%/}

# Is there a better way to deal with relative paths
CURRENT=$PWD
cd $TRISANO_SOURCE_HOME
TRISANO_SOURCE_HOME=$PWD
cd $CURRENT
cd $BI_BITS_HOME
BI_BITS_HOME=$PWD

if [[ ! -d $BI_BITS_HOME ]]; then
    echo "$BI_BITS_HOME is not a directory"
    exit
fi

if [[ ! -d $TRISANO_SOURCE_HOME/avr/bi ]]; then
    echo "$TRISANO_SOURCE_HOME is not the root directory of the TriSano source tree"
    exit
fi

# VERIFY THESE NAMES BEFORE RUNNING SCRIPT
BI_SERVER_ZIP=biserver-ce-3.6.0-stable.tar.gz
REPORT_DESIGNER_ZIP=prd-ce-3.6.1-stable.zip

BI_SERVER_NAME=biserver-ce
ADMIN_CONSOLE_NAME=administration-console
REPORT_DESIGNER_NAME=report-designer
BI_SERVER_HOME=$BI_BITS_HOME/$BI_SERVER_NAME
REPORT_DESIGNER_HOME=$BI_BITS_HOME/$REPORT_DESIGNER_NAME
ADMIN_CONSOLE_HOME=$BI_BITS_HOME/$ADMIN_CONSOLE_NAME
BI_TARBALL=trisano-ce-bi.tar.gz
DW_TARBALL=trisano-dw.tar.gz

if [[ ! -e $BI_SERVER_ZIP ]]; then
    echo "Could not locate BI Server archive: $BI_BITS_HOME/$BI_SERVER_ZIP"
    exit
fi

if [[ ! -e $REPORT_DESIGNER_ZIP ]]; then
    echo "Could not locate Report Designer archive: $BI_BITS_HOME/$REPORT_DESIGNER_ZIP"
    exit
fi

# Explode the BI server
echo
echo " * Exploding the BI Server archive (please wait...)"
if [[ -d $BISERVER_HOME ]]; then
    rm -rf $BISERVER_HOME
fi
tar zxf $BI_SERVER_ZIP
echo " * Exploding the Report Designer archive (please wait...)"
if [[ -d $BI_BITS_HOME/report-designer ]]; then
    rm -rf $BI_BITS_HOME/report-designer
fi
unzip -qq $REPORT_DESIGNER_ZIP

# Copy SiteMinder XML config files
echo " * Configuring BI Server to use SiteMinder"

# Backup originals
applicationContext-spring-security-hibernate.properties
if [[ -f $BI_SERVER_HOME/pentaho-solutions/system/applicationContext-spring-security-hibernate.properties ]]; then
    cp $BI_SERVER_HOME/pentaho-solutions/system/applicationContext-spring-security-hibernate.properties $BI_SERVER_HOME/pentaho-solutions/system/applicationContext-spring-security-hibernate.properties.org
fi
#if [[ -f $BI_SERVER_HOME/pentaho-solutions/system/pentaho-spring-beans.xml ]]; then
#    cp $BI_SERVER_HOME/pentaho-solutions/system/pentaho-spring-beans.xml $BI_SERVER_HOME/pentaho-solutions/system/pentaho-spring-beans.xml.org
#fi
if [[ -f $BI_SERVER_HOME/pentaho-solutions/system/mondrian/mondrian.properties ]]; then
    cp $BI_SERVER_HOME/pentaho-solutions/system/mondrian/mondrian.properties $BI_SERVER_HOME/pentaho-solutions/system/mondrian/mondrian.properties.org
fi
if [[ -f $BI_SERVER_HOME/pentaho-solutions/system/pentaho.xml ]]; then
    cp $BI_SERVER_HOME/pentaho-solutions/system/pentaho.xml $BI_SERVER_HOME/pentaho-solutions/system/pentaho.xml.org
fi

# Copy in new ones
#cp $TRISANO_SOURCE_HOME/avr/bi/bi_server_replacement_files/applicationContext-acegi-security-siteminder.xml $BI_SERVER_HOME/pentaho-solutions/system/
#cp $TRISANO_SOURCE_HOME/avr/bi/bi_server_replacement_files/pentaho-spring-beans.xml $BI_SERVER_HOME/pentaho-solutions/system/
cp $TRISANO_SOURCE_HOME/avr/bi/bi_server_replacement_files/applicationContext-spring-security-hibernate.properties $BI_SERVER_HOME/pentaho-solutions/system/
cp $TRISANO_SOURCE_HOME/avr/bi/bi_server_replacement_files/pentaho.xml $BI_SERVER_HOME/pentaho-solutions/system/
cp $TRISANO_SOURCE_HOME/avr/bi/bi_server_replacement_files/mondrian.properties $BI_SERVER_HOME/pentaho-solutions/system/mondrian/
cp $TRISANO_SOURCE_HOME/avr/bi/bi_server_replacement_files/publisher_config.xml $BI_SERVER_HOME/pentaho-solutions/system/

# Step 2: Copy custom jar files
echo " * Copying Trisano custom java extensions to BI Server"
cp $TRISANO_SOURCE_HOME/avr/bi/extensions/trisano/dist/* $BI_SERVER_HOME/tomcat/webapps/pentaho/WEB-INF/lib
cp $TRISANO_SOURCE_HOME/avr/bi/extensions/trisano/dist/* $ADMIN_CONSOLE_HOME/lib

# Configure BI for Postgres
echo " * Configuring BI Server to use PostgreSQL"
# Backup originals
cp $BI_SERVER_HOME/start-pentaho.sh $BI_SERVER_HOME/start-pentaho.sh.org
cp $BI_SERVER_HOME/stop-pentaho.sh $BI_SERVER_HOME/stop-pentaho.sh.org
cp $BI_SERVER_HOME/pentaho-solutions/system/quartz/quartz.properties  $BI_SERVER_HOME/pentaho-solutions/system/quartz/quartz.properties.org 
cp $BI_SERVER_HOME/pentaho-solutions/system/hibernate/hibernate-settings.xml $BI_SERVER_HOME/pentaho-solutions/system/hibernate/hibernate-settings.xml.org
cp $BI_SERVER_HOME/tomcat/webapps/pentaho/META-INF/context.xml $BI_SERVER_HOME/tomcat/webapps/pentaho/META-INF/context.xml.org

# Copy in new ones
cp $TRISANO_SOURCE_HOME/avr/bi/bi_server_replacement_files/start-pentaho.sh $BI_SERVER_HOME
cp $TRISANO_SOURCE_HOME/avr/bi/bi_server_replacement_files/stop-pentaho.sh $BI_SERVER_HOME
cp $TRISANO_SOURCE_HOME/avr/bi/bi_server_replacement_files/quartz.properties $BI_SERVER_HOME/pentaho-solutions/system/quartz/
cp $TRISANO_SOURCE_HOME/avr/bi/bi_server_replacement_files/hibernate-settings.xml $BI_SERVER_HOME/pentaho-solutions/system/hibernate
cp $TRISANO_SOURCE_HOME/avr/bi/bi_server_replacement_files/hibernate-c3p0-postgres.cfg.xml $BI_SERVER_HOME/pentaho-solutions/system/hibernate
cp $TRISANO_SOURCE_HOME/avr/bi/bi_server_replacement_files/context.xml $BI_SERVER_HOME/tomcat/webapps/pentaho/META-INF
cp $TRISANO_SOURCE_HOME/avr/bi/bi_server_replacement_files/c3p0-0.9.1.2.jar $BI_SERVER_HOME/tomcat/webapps/pentaho/WEB-INF/lib
cp $TRISANO_SOURCE_HOME/avr/bi/bi_server_replacement_files/c3p0-0.9.1.2.jar $ADMIN_CONSOLE_HOME/lib
cp $BI_SERVER_HOME/tomcat/common/lib/postgresql-8.2-504.jdbc3.jar $REPORT_DESIGNER_HOME/lib/jdbc

# Customize admin console
# Add Postgres JDBC driver to admin-console
echo " * Configuring Admin Console to use PostgreSQL"
cp $BI_SERVER_HOME/tomcat/common/lib/postgresql-8.2-504.jdbc3.jar $ADMIN_CONSOLE_HOME/jdbc/

# Configure repositories
echo " * Building TriSano solution repository"
mkdir -p $BI_SERVER_HOME/pentaho-solutions/TriSano/jdbc
mkdir $BI_SERVER_HOME/lib
cp $BI_SERVER_HOME/pentaho-solutions/system/olap/datasources.xml $BI_SERVER_HOME/pentaho-solutions/system/olap/datasources.xml.org
cp $TRISANO_SOURCE_HOME/avr/bi/bi_server_replacement_files/datasources.xml $BI_SERVER_HOME/pentaho-solutions/system/olap
cp $TRISANO_SOURCE_HOME/avr/bi/schema/TriSano.OLAP.xml $BI_SERVER_HOME/pentaho-solutions/TriSano
cp $TRISANO_SOURCE_HOME/avr/bi/schema/metadata.xmi $BI_SERVER_HOME/pentaho-solutions/TriSano
cp $TRISANO_SOURCE_HOME/avr/bi/schema/index.properties $BI_SERVER_HOME/pentaho-solutions/TriSano
cp $TRISANO_SOURCE_HOME/avr/bi/schema/index.xml $BI_SERVER_HOME/pentaho-solutions/TriSano
cp $TRISANO_SOURCE_HOME/avr/bi/scripts/build_metadata/build_metadata.rb $BI_SERVER_HOME/pentaho-solutions/TriSano
cp --preserve=mode $TRISANO_SOURCE_HOME/avr/bi/scripts/build_metadata/build_metadata.sh $BI_SERVER_HOME/pentaho-solutions/TriSano
cp $TRISANO_SOURCE_HOME/avr/jdbc/repository.properties $BI_SERVER_HOME/pentaho-solutions/TriSano/jdbc
cp $TRISANO_SOURCE_HOME/avr/bi/extensions/trisano/dist/jruby-complete-1.5.2.jar $BI_SERVER_HOME/lib
cp $TRISANO_SOURCE_HOME/avr/pentaho-metadata-3.2.2.1.jar $BI_SERVER_HOME/tomcat/webapps/pentaho/WEB-INF/lib/pentaho-metadata-2.2.0.jar
cp $TRISANO_SOURCE_HOME/avr/bi/extensions/trisano/dist/trisano.jar $BI_SERVER_HOME/tomcat/webapps/pentaho/WEB-INF/lib/
cp $TRISANO_SOURCE_HOME/avr/bi/extensions/trisano/dist/jruby-complete-1.5.2.jar $BI_SERVER_HOME/pentaho-solutions/TriSano

# Removing sample repositories
rm -fr $BI_SERVER_HOME/pentaho-solutions/steel-wheels
rm -fr $BI_SERVER_HOME/pentaho-solutions/bi-developers

# Bundle warehouse create scripts
echo " * Bundling warehouse initialization and ETL scripts."
WAREHOUSE_DIR=warehouse
mkdir $WAREHOUSE_DIR
cp $TRISANO_SOURCE_HOME/avr/bi/scripts/etl.sh $WAREHOUSE_DIR
cp $TRISANO_SOURCE_HOME/avr/bi/scripts/warehouse_init.sql $WAREHOUSE_DIR
cp $TRISANO_SOURCE_HOME/avr/bi/scripts/dw.sql $WAREHOUSE_DIR
cp $TRISANO_SOURCE_HOME/avr/bi/scripts/dw.png $WAREHOUSE_DIR
cp $TRISANO_SOURCE_HOME/avr/bi/scripts/build_metadata/build_metadata_schema.sql $WAREHOUSE_DIR

# Bundle sample reports
echo " * Bundling sample reports"
REPORT_DIR=sample_reports
mkdir $REPORT_DIR
cp $TRISANO_SOURCE_HOME/avr/bi/reports/*.report $REPORT_DIR

# Create TriSano tarballs
echo " * Creating distribution packages (please wait...)"
zip -qq -u $REPORT_DESIGNER_ZIP $REPORT_DESIGNER_NAME/lib/jdbc/postgresql-8.2-504.jdbc3.jar
tar cfz $BI_TARBALL $BI_SERVER_NAME $ADMIN_CONSOLE_NAME $REPORT_DESIGNER_ZIP $REPORT_DIR
tar cfz $DW_TARBALL $WAREHOUSE_DIR

# Clean up
rm -fr $BI_SERVER_NAME $REPORT_DESIGNER_NAME $ADMIN_CONSOLE_NAME $WAREHOUSE_DIR $REPORT_DIR

echo
echo "$BI_TARBALL and $DW_TARBALL are ready for shipping in $BI_BITS_HOME"
echo
echo
