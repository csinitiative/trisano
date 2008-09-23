#!/bin/bash

. setenv.sh

jruby -S rake -f ../webapp/Rakefile trisano:distro:create_db


