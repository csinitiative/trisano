#!/bin/bash

# install jruby

. setenv.sh

echo "installing jruby"
cd $JRUBY_DIR
tar xvf jruby-bin-1.1.3.tar.gz
