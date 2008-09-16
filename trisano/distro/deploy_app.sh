#!/bin/bash

# install jruby

. setenv.sh

echo "not yet implemented"
jruby -S rake -f ../webapp/Rakefile trisano:deploy:redeploytomcat
