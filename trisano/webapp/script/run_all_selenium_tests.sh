#!/bin/bash

# Set TRISANO_URL to the url you want to test (e.g., http://localhost:8080)
#
# Run selenium RC prior to this script
#
# suggested that you run it the following way so that you can correlate tests to results:
# sh -v run_selenium_tests.sh 

echo "Running Selenium UAT Tests"
cd ../webapp/spec/uat

spec_dir_contents=$(find . -name "*selspec*.rb" -type f)
#echo $spec_dir_contents

for d in $spec_dir_contents
do
    echo "Running $d"
    spec $d
done

echo "Tests Completed"

