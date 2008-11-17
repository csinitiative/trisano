Requires httperf to be installed.

Any linux package manager (e.g., yas, yum, apt-get) will have it.

Sample Usage:
./trisano-httperf-script.sh $HOST_NAME $PORT $NUM_CALLS $TEST_FILE $SLEEP_BETWEEN_RUNS

A specific example:
./trisano-httperf-script.sh test.csi.osuosl.org 80 50 create_simple_cmr 20
