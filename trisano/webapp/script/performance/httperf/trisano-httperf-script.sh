#!/bin/bash

# sample usage: ./trisano-httperf-script.sh test.csi.osuosl.org 80 create_simple_cmr 20

NUM_CALLS=50
TIMEOUT=15
THINKTIMEOUT=15

echo "starting sequential 1 request per second"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$3,0,$4 --timeout=$TIMEOUT --think-timeout=$TIMEOUT > $4-rate0.output
echo "completed 1 @ time"
sleep $5
echo "starting 1"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$3,0,$4 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=1 > $4-rate1.output
echo "completed 1"
sleep $5
echo "starting 2 request per second"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$3,0,$4 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=2 > $4-rate2.output
echo "completed 2"
sleep $5
echo "starting 3 request per second"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$3,0,$4 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=3 > $4-rate3.output
echo "completed 3"
sleep $5
echo "starting 4 request per second"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$3,0,$4 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=4 > $4-rate4.output
echo "completed 4"
sleep $5
echo "starting 5 request per second"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$3,0,$4 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=5 > $4-rate5.output
echo "completed 5"
sleep $5
echo "starting 6 request per second"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$3,0,$4 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=6 > $4-rate6.output
echo "completed 6"
sleep $5
echo "starting 7 request per second"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$3,0,$4 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=7 > $4-rate7.output
echo "completed 7"
sleep $5
echo "starting 8 request per second"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$3,0,$4 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=8 > $4-rate8.output
echo "completed 8"
sleep $5
echo "starting 9 request per second"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$3,0,$4 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=9 > $4-rate9.output
echo "completed 9"
sleep $5
echo "starting 10 request per second"
httperf -v --server=$1 --port=$2 --hog −−session−cookie --wsesslog=$3,0,$4 --timeout=$TIMEOUT --think-timeout=$TIMEOUT  --rate=10 > $4-rate10.output
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
