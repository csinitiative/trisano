#!/bin/bash

jruby -S rake -f ../webapp/Rakefile trisano:distro:upgrade_db
