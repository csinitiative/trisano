#!/bin/bash

. setenv.sh

jruby -S rake -f ../webapp/Rakefile trisano:distro:upgrade_db > upgrade_db_output.txt
jruby -S rake -f ../webapp/Rakefile trisano:distro:set_new_db_permissions > set_new_db_permissions_output.txt
