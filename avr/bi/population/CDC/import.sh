#!/bin/bash

# CDC Population data import script

usage()
{
    cat <<HELP
USAGE:
   bash import.sh <database> <schema> <input file> <year> <dw_user>

DESCRIPTION:
    database    The database the data should be loaded into
    schema      The pre-existing schema the data should be loaded into
    input file  The CDC population data file
    year        The year of the population data
    dw_user     The database user used by Pentaho

With the exception of the database, this script connects to PostgreSQL using
psql's defaults. Use the PGHOST, PGPORT, and PGUSER environment variables to
override this behavior. Note that the script will remove the schema if it
exists, and fully replace it.

HELP
    exit 1
}

if [[ $# != 5 ]] ; then
    usage
fi

DATABASE=$1
SCHEMA=$2
INPUT_FILE=$3
YEAR=$4
DWUSER=$5

if [[ "x${DATABASE}x" == "xx"   ||\
      "x${SCHEMA}x" == "xx"     ||\
      "x${INPUT_FILE}x" == "xx" ||\
      "x${YEAR}x" == "xx"       ||\
      "x${DWUSER}x" == "xx"     ]]; then
    usage
fi

# This should probably not be changed
SCRIPTS="population_utah.sql population.sql"

psql -X -d $DATABASE <<PSQL
DROP SCHEMA IF EXISTS $SCHEMA CASCADE;
CREATE SCHEMA $SCHEMA;
SET SEARCH_PATH = $SCHEMA;
DROP TABLE IF EXISTS popinit;
CREATE TABLE popinit (
    age TEXT,
    age_code TEXT,
    ethnicity TEXT,
    ethnicity_code TEXT,
    county TEXT,
    county_code TEXT,
    gender TEXT,
    gender_code TEXT,
    race TEXT,
    race_code TEXT,
    population INTEGER
);
PSQL

perl -n -e "if (/^\t/) { s/^\t// ; s/\"//g; s/\t/|/g; print; }" "$INPUT_FILE" | \
psql -X -d $DATABASE -c "COPY $SCHEMA.popinit FROM STDIN WITH DELIMITER AS '|';"

for i in $SCRIPTS; do
    echo "Running script $i"
    psql \
        -v TRISANO_POP_DWUSER=$DWUSER -v TRISANO_POP_SCHEMA=$SCHEMA -v TRISANO_POP_YEAR=$YEAR \
        -Xf $i -d $DATABASE
done;
