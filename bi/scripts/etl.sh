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


# Example ETL script
# Destination database must already exist

SOURCE_DB_HOST=localhost
SOURCE_DB_PORT=5432
SOURCE_DB_NAME=trisano_development
SOURCE_DB_USER=trisano_su
# NB!: Passwords must be handled automatically, i.e. with a .pgpass file
# cf. http://www.postgresql.org/docs/current/static/libpq-pgpass.html

DEST_DB_HOST=localhost
DEST_DB_PORT=5432
DEST_DB_NAME=trisano_warehouse
DEST_DB_USER=trisano_su

PGSQL_PATH=/usr/bin

# Set to 1 to avoid problems from bad assumptions
SAFE_MODE=0

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
# See the individual ETL SQL scripts for further details

## END OF README

ETL_SCRIPT=dw.sql

echo "Preparing for ETL process"
$PGSQL_PATH/psql -X -h $DEST_DB_HOST -p $DEST_DB_PORT -U $DEST_DB_USER -d $DEST_DB_NAME -c "SELECT trisano.prepare_etl()"

if [ $? != 0 ] ; then
    echo "Problem preparing for ETL"
    exit 1
fi

echo "Dumping database $SOURCE_DB_HOST:$SOURCE_DB_PORT/$SOURCE_DB_NAME to $DEST_DB_HOST:$DEST_DB_PORT/$DEST_DB_NAME"
$PGSQL_PATH/pg_dump -h $SOURCE_DB_HOST -p $SOURCE_DB_PORT -U $SOURCE_DB_USER -n public $SOURCE_DB_NAME | \
    $PGSQL_PATH/psql -X -h $DEST_DB_HOST -p $DEST_DB_PORT -U $DEST_DB_USER $DEST_DB_NAME 

if [ $? != 0 ] ; then
    echo "Problem dumping database into warehouse staging area"
    exit 1
fi

echo "Performing ETL data manipulation"
# TODO: make this error out of dw.sql has problems
$PGSQL_PATH/psql -X -h $DEST_DB_HOST -p $DEST_DB_PORT -U $DEST_DB_USER -f $ETL_SCRIPT $DEST_DB_NAME

if [ $? != 0 ] ; then
    echo "Problem performing post-dump ETL"
    exit 1
fi

echo "Swapping schemas"
$PGSQL_PATH/psql -X -h $DEST_DB_HOST -p $DEST_DB_PORT -U $DEST_DB_USER -d $DEST_DB_NAME -c "SELECT trisano.swap_schemas()"
