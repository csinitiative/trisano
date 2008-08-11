#!/bin/bash

jruby -S rake -f ../webapp/Rakefile trisano:distro:upgrade_db
jruby -S rake -f ../webapp/Rakefile trisano:distro:set_new_db_permissions
