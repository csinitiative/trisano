#!/bin/bash

. setenv.sh

jruby -S rake -f ../webapp/Rakefile trisano:distro:drop_db_and_user

