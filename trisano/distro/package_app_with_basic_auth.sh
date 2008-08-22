#!/bin/bash

jruby -S rake -f ../webapp/Rakefile trisano:distro:package_app_with_basic_auth
