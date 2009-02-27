Requires httperf to be installed.

Any linux package manager (e.g., yas, yum, apt-get) will have it.

Sample Usage:
./trisano-httperf-script.sh $HOST_NAME $PORT $NUM_CALLS $TEST_FILE $SLEEP_BETWEEN_RUNS

Specific examples:
./trisano-httperf-script.sh test.csi.osuosl.org 80 50 search_for_non_existent_city 5
./trisano-httperf-script.sh test.csi.osuosl.org 80 50 search_after_create_simple_cmr 25
./trisano-httperf-script.sh test.csi.osuosl.org 80 10 click_on_each_page 5
./trisano-httperf-script.sh test.csi.osuosl.org 80 50 create_cmr_then_list 25
./trisano-httperf-script.sh test.csi.osuosl.org 80 50 create_simple_cmr 25
./trisano-httperf-script.sh test.csi.osuosl.org 80 50 create_complete_cmr 25
