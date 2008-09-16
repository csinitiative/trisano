#!/bin/bash

. setenv.sh

jruby -S rake -f ../webapp/Rakefile trisano:distro:restore_db


