#!/bin/bash

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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.


# Example ETL script
# Destination database must already exist

SOURCE_DB_HOST=localhost
SOURCE_DB_PORT=5432
SOURCE_DB_NAME=edge
SOURCE_DB_USER=trisano_user
# NB!: Passwords must be handled automatically, i.e. with a .pgpass file
# cf. http://www.postgresql.org/docs/current/static/libpq-pgpass.html

DEST_DB_HOST=localhost
DEST_DB_PORT=5432
DEST_DB_NAME=trisano_warehouse
DEST_DB_USER=trisano_su

TRISANO_PLUGIN_DIRECTORY=""

# Should the ETL process obfuscate private information for events associated
# with diseases marked "sensitive"?
OBFUSCATE_SENSITIVE_DISEASES=true

PSQL_FLAGS="-X -q -t -v ON_ERROR_STOP=on"
PGDUMP_FLAGS="-i -O -x"

# NOTE: The PSQLPATH and PGDUMPPATH environment variables can be used to set
# specific paths for the psql and pg_dump utilities, respectively. If both
# utilities exist in a single directory, just set that directory here.
PGSQL_PATH=/usr/bin

# This allows the plugin directory to be set as an environment variable
# outside etl.sh
echo "Testing plugin directory: $TRISANO_PLUGIN_DIRECTORY"
if [[ -n $TRISANO_PLUGIN_DIRECTORY && -d $TRISANO_PLUGIN_DIRECTORY && -r $TRISANO_PLUGIN_DIRECTORY ]]; then
    echo "Plugin directory: $TRISANO_PLUGIN_DIRECTORY"
else
    echo "Plugin directory $TRISANO_PLUGIN_DIRECTORY not found"
    TRISANO_PLUGIN_DIRECTORY=''
fi
## END OF CONFIG

## README

# This script uses pg_dump to dump the OLTP database (SOURCE_DB_* variables)
# into a warehouse database (DEST_DB_*). It will run one SQL function before it
# begins processing, and another after the dump completes, for doing the actual
# data manipulation required. The process involves the following steps
#
# 1: dump the data to the public schema,
# 2: rename the public schema to "staging"
# 3: create a new public schema
# 4: process the data in the staging schema
# 5: rename the staging schema once again, to warehouse_a or warehouse_b,
#    intelligently avoiding overwriting whichever of those two is currently in use
#    by production
# 6: alter a set of views used by the actual reporting software to use the
#    newly-renamed schema instead of whatever they used before
#
# In other words, the reporting software only uses views to access the data.
# These views point at one schema (say, warehouse_a) while warehouse_b is being
# used for the refresh process. Once warehouse_b is built, the ETL process
# switches all the views to use warehouse_b, and warehouse_a gets used for the
# next refresh.
#
# See the dw.sql script for further details

## END OF README

# Make sure we have psql and pg_dump
find_file () {
    FILENAME=$1
    ENV_VAR=$2

    if [[ ! -x $PGSQL_PATH/$FILENAME ]]; then
        FILE=$ENV_VAR
        if [[ "x$FILE" == "" || ! -x $FILE ]]; then
            FILE=`which $FILENAME`
        fi
        if [[ "x$FILE" == "x" ]]; then
            echo "Can't find executable $FILENAME"
            exit 1
        fi
    else
        FILE=$PGSQL_PATH/$FILENAME
    fi
}

DIE () {
    echo $1
    exit 1
}

find_file psql $PSQLPATH
PSQL=$FILE
find_file pg_dump $PGDUMPPATH
PGDUMP=$FILE

ETL_SCRIPT=dw.sql

CMM=$($PSQL $PSQL_FLAGS -h $DEST_DB_HOST -p $DEST_DB_PORT -U $DEST_DB_USER \
                    -d $DEST_DB_NAME -c "show client_min_messages")

if [[ "X${CMM}X" == "XX" ]]; then
    DIE "There's probably a problem with the settings in your etl.sh file. Check that you can actually connect to PostgreSQL with those settings"
fi

echo "Temporarily quieting PostgreSQL"
$PSQL $PSQL_FLAGS -h $DEST_DB_HOST -p $DEST_DB_PORT -U $DEST_DB_USER \
    -d $DEST_DB_NAME -c "alter role $DEST_DB_USER set client_min_messages = WARNING;" || \
    DIE "Couldn't quiet PostgreSQL"

echo "Preparing for ETL process"
$PSQL $PSQL_FLAGS -h $DEST_DB_HOST -p $DEST_DB_PORT -U $DEST_DB_USER \
    -d $DEST_DB_NAME -c "SELECT trisano.prepare_etl()" || \
    DIE "Couldn't prepare for ETL process"

echo "Dumping database:"
echo "   $SOURCE_DB_HOST:$SOURCE_DB_PORT/$SOURCE_DB_NAME -> $DEST_DB_HOST:$DEST_DB_PORT/$DEST_DB_NAME"
echo "   Dropping bucardo schema in warehouse, if exists"
$PSQL $PSQL_FLAGS -h $DEST_DB_HOST -p $DEST_DB_PORT -U $DEST_DB_USER \
    -d $DEST_DB_NAME -c "DROP SCHEMA IF EXISTS bucardo CASCADE;" || \
    DIE "Couldn't clean Bucardo out warehouse"

# TODO: Only do this if bucardo schema exists in source databse
echo "   Checking for bucardo schema in source"
BUC=$($PSQL $PSQL_FLAGS -A -h $SOURCE_DB_HOST -p $SOURCE_DB_PORT -U $SOURCE_DB_USER \
    -d $SOURCE_DB_NAME -c "SELECT nspname FROM pg_namespace WHERE nspname = 'bucardo';")
if [ "x$BUC" = "xbucardo" ]; then
    echo "   Copying bucardo schema"
    $PGDUMP $PGDUMP_FLAGS -s -h $SOURCE_DB_HOST -p $SOURCE_DB_PORT -U $SOURCE_DB_USER \
            -n bucardo $SOURCE_DB_NAME | \
        $PSQL $PSQL_FLAGS -h $DEST_DB_HOST -p $DEST_DB_PORT -U $DEST_DB_USER -d $DEST_DB_NAME || \
        DIE "Problem copying Bucardo"
fi

#echo "   Creating functions"
#$PSQL $PSQL_FLAGS -h $DEST_DB_HOST -p $DEST_DB_PORT -U $DEST_DB_USER -d $DEST_DB_NAME -c "CREATE OR REPLACE FUNCTION show_trgm(text) RETURNS text[] LANGUAGE c IMMUTABLE STRICT AS '\$libdir/pg_trgm', 'show_trgm';"
#$PSQL $PSQL_FLAGS -h $DEST_DB_HOST -p $DEST_DB_PORT -U $DEST_DB_USER -d $DEST_DB_NAME -c "ALTER FUNCTION public.show_trgm(text) OWNER TO trisano_user;"

echo "   Dumping main schema"
$PGDUMP -T attachments -T logos -T db_files $PGDUMP_FLAGS -s -h $SOURCE_DB_HOST -p $SOURCE_DB_PORT -U $SOURCE_DB_USER \
    -n public $SOURCE_DB_NAME | \
    $PSQL $PSQL_FLAGS -x -h $DEST_DB_HOST -p $DEST_DB_PORT -U $DEST_DB_USER -d $DEST_DB_NAME || \
    DIE "Problem dumping database schema"
# Drop bucardo again
$PSQL $PSQL_FLAGS -h $DEST_DB_HOST -p $DEST_DB_PORT -U $DEST_DB_USER \
    -d $DEST_DB_NAME -c "DROP SCHEMA IF EXISTS bucardo CASCADE;" || \
    DIE "Problem cleaning Bucardo"

echo "   Doing main dump"
$PGDUMP -T attachments -T logos -T db_files $PGDUMP_FLAGS --disable-triggers -a -h $SOURCE_DB_HOST -p $SOURCE_DB_PORT \
    -U $SOURCE_DB_USER -n public $SOURCE_DB_NAME | \
    $PSQL $PSQL_FLAGS -x -h $DEST_DB_HOST -p $DEST_DB_PORT -U $DEST_DB_USER -d $DEST_DB_NAME || \
    DIE "Problem with main database dump into staging area"

echo "Performing ETL data manipulation"
$PSQL $PSQL_FLAGS -h $DEST_DB_HOST -p $DEST_DB_PORT -U $DEST_DB_USER \
    -v obfuscate=${OBFUSCATE_SENSITIVE_DISEASES} \
    -f $ETL_SCRIPT $DEST_DB_NAME || DIE "Failed to create new data warehouse structures"

echo "Processing plugin ETL"
if [[ -n $TRISANO_PLUGIN_DIRECTORY && -d $TRISANO_PLUGIN_DIRECTORY && -r $TRISANO_PLUGIN_DIRECTORY ]]; then
    echo "Checking for plugins in $TRISANO_PLUGIN_DIRECTORY"
    for plugin in $TRISANO_PLUGIN_DIRECTORY/*; do
        if [ -r $plugin/avr/etl.sql ] ; then
            echo "Found ETL file for $plugin"
            $PSQL $PSQL_FLAGS -h $DEST_DB_HOST \
                -p $DEST_DB_PORT -U $DEST_DB_USER \
                -f $plugin/avr/etl.sql $DEST_DB_NAME || \
                DIE "Error running ETL for plugin $plugin"
        fi
    done
else
    echo "The environment variable TRISANO_PLUGIN_DIRECTORY is set to \"$TRISANO_PLUGIN_DIRECTORY\", which not a readable directory. Skipping plugins."
fi

echo "Swapping schemas"
$PSQL $PSQL_FLAGS -h $DEST_DB_HOST -p $DEST_DB_PORT -U $DEST_DB_USER \
    -d $DEST_DB_NAME -c "SELECT trisano.swap_schemas()" || \
    DIE "Problem swapping staging schema into production use"

echo "Processing post-swap plugin ETL"
if [[ -n $TRISANO_PLUGIN_DIRECTORY && -d $TRISANO_PLUGIN_DIRECTORY && -r $TRISANO_PLUGIN_DIRECTORY ]]; then
    echo "Checking for plugins in $TRISANO_PLUGIN_DIRECTORY"
    for plugin in $TRISANO_PLUGIN_DIRECTORY/*; do
        if [ -r $plugin/avr/post-etl.sql ] ; then
            echo "Found post-ETL file for $plugin"
            $PSQL $PSQL_FLAGS -h $DEST_DB_HOST \
                -p $DEST_DB_PORT -U $DEST_DB_USER \
                -f $plugin/avr/post-etl.sql $DEST_DB_NAME || \
                DIE "Error running post-ETL for plugin $plugin"
        fi
    done
else
    echo "The environment variable TRISANO_PLUGIN_DIRECTORY is set to \"$TRISANO_PLUGIN_DIRECTORY\", which is not a readable directory. Skipping post-swap plugins."
fi

echo "Fixing PostgreSQL verbosity"
$PSQL $PSQL_FLAGS -h $DEST_DB_HOST -p $DEST_DB_PORT -U $DEST_DB_USER \
    -d $DEST_DB_NAME -c "alter role $DEST_DB_USER set client_min_messages = $CMM;" || \
    DIE "Problem resetting PostgreSQL verbosity"
