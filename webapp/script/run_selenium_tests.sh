#!/bin/bash

# Set TRISANO_URL to the url you want to test (e.g., http://localhost:8080)
#
# Run selenium RC prior to this script
#
# suggested that you run it the following way so that you can correlate tests to results:
# sh -v run_selenium_tests.sh 

echo "Running Selenium UAT Tests"
cd ../webapp/spec/uat

#Use this to pick the set based on time
PREFIX=`date "+%I"`

#Use this to hard code the set
#PREFIX=11
echo Hourly Set Prefix: $PREFIX

spec_dir_contents=$(find . -name "*$PREFIX.rb" -type f)
#echo $spec_dir_contents

for d in $spec_dir_contents
do
    echo "Running $d"
    spec $d
done

echo "Tests Completed"

