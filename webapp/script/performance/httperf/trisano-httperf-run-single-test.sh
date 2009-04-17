#!/bin/bash

# sample usage: 
#                                                         #  test                rate 
#                                  $1                  $2 $3 $4                  $5                              
# time ./trisano-httperf-script.sh test.csi.osuosl.org 80 50 create_complete_cmr 5

NUM_CALLS=50
TIMEOUT=15
THINKTIMEOUT=15

echo "starting test"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$3,0,$4 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=$5 > $4-rate$5.output

