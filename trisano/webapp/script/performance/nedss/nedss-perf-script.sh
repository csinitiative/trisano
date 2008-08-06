#!/bin/bash

#httperf --server=ut-nedss-dev.csinitiative.com --port=5050 --wsesslog=100,0,nedss-perf-script-data --print-reply

httperf --server=ut-nedss-dev.csinitiative.com --port=5050 --wsesslog=25,0,nedss-perf-script-data 

#httperf --server=localhost --port=8080 --wsesslog=10,0,nedss-perf-script-data
