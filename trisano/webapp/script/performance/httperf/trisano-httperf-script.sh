#!/bin/bash
echo "starting sequential 1 request @ a time"
httperf -v --server=test.csi.osuosl.org --port=80 --hog −−session−cookie --wsesslog=50,0,trisano-sequence-data --timeout=15 --think-timeout=15 > rate0.output
echo "completed 1 @ time"
sleep 40
echo "starting 1"
httperf -v --server=test.csi.osuosl.org --port=80 --hog −−session−cookie --wsesslog=50,0,trisano-sequence-data --timeout=15 --think-timeout=15  --rate=1 > rate1.output
echo "completed 1"
sleep 40
echo "starting 2 request @ a time"
httperf -v --server=test.csi.osuosl.org --port=80 --hog −−session−cookie --wsesslog=50,0,trisano-sequence-data --timeout=15 --think-timeout=15  --rate=2 > rate2.output
echo "completed 2"
sleep 40
echo "starting 3 request @ a time"
httperf -v --server=test.csi.osuosl.org --port=80 --hog −−session−cookie --wsesslog=50,0,trisano-sequence-data --timeout=15 --think-timeout=15  --rate=3 > rate3.output
echo "completed 3"
sleep 40
echo "starting 4 request @ a time"
httperf -v --server=test.csi.osuosl.org --port=80 --hog −−session−cookie --wsesslog=50,0,trisano-sequence-data --timeout=15 --think-timeout=15  --rate=4 > rate4.output
echo "completed 4"
sleep 40
echo "starting 5 request @ a time"
httperf -v --server=test.csi.osuosl.org --port=80 --hog −−session−cookie --wsesslog=50,0,trisano-sequence-data --timeout=15 --think-timeout=15  --rate=5 > rate5.output
echo "completed 5"
sleep 40
echo "starting 6 request @ a time"
httperf -v --server=test.csi.osuosl.org --port=80 --hog −−session−cookie --wsesslog=50,0,trisano-sequence-data --timeout=15 --think-timeout=15  --rate=6 > rate6.output
echo "completed 6"
sleep 40
echo "starting 7 request @ a time"
httperf -v --server=test.csi.osuosl.org --port=80 --hog −−session−cookie --wsesslog=50,0,trisano-sequence-data --timeout=15 --think-timeout=15  --rate=7 > rate7.output
echo "completed 7"
sleep 40
echo "starting 8 request @ a time"
httperf -v --server=test.csi.osuosl.org --port=80 --hog −−session−cookie --wsesslog=50,0,trisano-sequence-data --timeout=15 --think-timeout=15  --rate=8 > rate8.output
echo "completed 8"
sleep 40
echo "starting 9 request @ a time"
httperf -v --server=test.csi.osuosl.org --port=80 --hog −−session−cookie --wsesslog=50,0,trisano-sequence-data --timeout=15 --think-timeout=15  --rate=9 > rate9.output
echo "completed 9"
sleep 40
echo "starting 10 request @ a time"
httperf -v --server=test.csi.osuosl.org --port=80 --hog −−session−cookie --wsesslog=50,0,trisano-sequence-data --timeout=15 --think-timeout=15  --rate=10 > rate10.output
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
# Note that httperf has a “-v” option which is helpful in seeing progress. One can specify a very 
# large number of sessions in –wsesslog and then watch httperf print out its requests/sec 
# measurements every 5 #seconds and after one to two dozen measurements, hit ctrl-C to get the overall stats.
# 
