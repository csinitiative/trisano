#!/bin/bash

#httperf --server=ut-nedss-dev.csinitiative.com --port=5050 --wsesslog=100,0,trisano-perf-script-data --print-reply

httperf --server=test.csi.osuosl.org --port=80 --wsesslog=25,0,trisano-new-cmr-data

#httperf --server=localhost --port=8080 --wsesslog=10,0,trisano-perf-script-data
