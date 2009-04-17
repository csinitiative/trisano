#!/bin/bash

# sample usage: 
# sh -v ./trisano-httperf-endurance.sh

NUM_CALLS=50
TIMEOUT=15
THINKTIMEOUT=15

echo "starting very actives"
httperf -v --server=test.csi.osuosl.org --port=80 --hog −−session−cookie --wsesslog=10000,0,endurance_very_active_investigator --timeout=$TIMEOUT --think-timeout=$TIMEOUT --rate=0 > va1.output &  
sleep 5
httperf -v --server=test.csi.osuosl.org --port=80 --hog −−session−cookie --wsesslog=10000,0,endurance_very_active_investigator --timeout=$TIMEOUT --think-timeout=$TIMEOUT --rate=0 > va2.output & 
sleep 5
httperf -v --server=test.csi.osuosl.org --port=80 --hog −−session−cookie --wsesslog=10000,0,endurance_very_active_investigator --timeout=$TIMEOUT --think-timeout=$TIMEOUT --rate=0 > va3.output & 
sleep 5
httperf -v --server=test.csi.osuosl.org --port=80 --hog −−session−cookie --wsesslog=10000,0,endurance_very_active_investigator --timeout=$TIMEOUT --think-timeout=$TIMEOUT --rate=0 > va4.output & 
sleep 5
httperf -v --server=test.csi.osuosl.org --port=80 --hog −−session−cookie --wsesslog=10000,0,endurance_very_active_investigator --timeout=$TIMEOUT --think-timeout=$TIMEOUT --rate=0 > va5.output & 
sleep 5
