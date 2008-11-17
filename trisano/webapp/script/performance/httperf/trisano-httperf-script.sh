#!/bin/bash

# sample usage: ./trisano-httperf-script.sh test.csi.osuosl.org 80 create_simple_cmr

NUM_CALLS=50
TIMEOUT=15
THINKTIMEOUT=15
SLEEP=40

echo "starting sequential 1 request @ a time"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$NUM_CALLS,0,$3 --timeout=$TIMEOUT --think-timeout=$TIMEOUT > $3-rate0.output
echo "completed 1 @ time"
sleep $SLEEP
echo "starting 1"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$NUM_CALLS,0,$3 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=1 > $3-rate1.output
echo "completed 1"
sleep $SLEEP
echo "starting 2 request @ a time"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$NUM_CALLS,0,$3 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=2 > $3-rate2.output
echo "completed 2"
sleep $SLEEP
echo "starting 3 request @ a time"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$NUM_CALLS,0,$3 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=3 > $3-rate3.output
echo "completed 3"
sleep $SLEEP
echo "starting 4 request @ a time"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$NUM_CALLS,0,$3 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=4 > $3-rate4.output
echo "completed 4"
sleep $SLEEP
echo "starting 5 request @ a time"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$NUM_CALLS,0,$3 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=5 > $3-rate5.output
echo "completed 5"
sleep $SLEEP
echo "starting 6 request @ a time"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$NUM_CALLS,0,$3 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=6 > $3-rate6.output
echo "completed 6"
sleep $SLEEP
echo "starting 7 request @ a time"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$NUM_CALLS,0,$3 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=7 > $3-rate7.output
echo "completed 7"
sleep $SLEEP
echo "starting 8 request @ a time"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$NUM_CALLS,0,$3 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=8 > $3-rate8.output
echo "completed 8"
sleep $SLEEP
echo "starting 9 request @ a time"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$NUM_CALLS,0,$3 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=9 > $3-rate9.output
echo "completed 9"
sleep $SLEEP
echo "starting 10 request @ a time"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$NUM_CALLS,0,$3 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=10 > $3-rate10.output
echo "completed 10"

# Doc details: http://www.hpl.hp.com/research/linux/httperf/httperf-man-0.9.pdf
#
# −−num−calls=N
# This option is meaningful for request−oriented workloads only. It specifies the total number of
# calls to issue on each connection before closing it. If N is greater than 1, the server must support
# persistent connections. The default value for this option is 1. If −−burst−length is set to R B ,
# then the N calls are issued in bursts of B pipelined calls each. Thus, the total number of such
# bursts will be N/B (per connection).
# −−rate=X
# Specifies the fixed rate at which connections or sessions are created. Connections are created by
# default, sessions if option −−wsess or −−wsesslog has been specified. In both cases a rate of 0
# results in connections or sessions being generated sequentially (a new session/connection is initiated
# as soon as the previous one completes). The default value for this option is 0
#
