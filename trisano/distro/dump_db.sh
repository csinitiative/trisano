#!/bin/bash

. setenv.sh

jruby -S rake -f ../webapp/Rakefile trisano:distro:dump_db


