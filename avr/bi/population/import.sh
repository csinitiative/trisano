DATABASE=josh
INPUT_FILE="Bridged-Race Population Estimates (Vintage 2007).txt"

# You shouldn't need to change this
SCRIPT_FILE=population.sql

psql -X -d $DATABASE <<PSQL
DROP TABLE IF EXISTS popinit;
CREATE TABLE popinit (
    age TEXT,
    age_code TEXT,
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
psql -X -d $DATABASE -c "COPY popinit FROM STDIN WITH DELIMITER AS '|';"

psql -Xf $SCRIPT_FILE -d $DATABASE
