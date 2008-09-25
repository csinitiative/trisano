#!/bin/bash

# Copyright (C) 2007, 2008, The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the 
# terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

# Installs application on the same machine that script is run on. Assumes Tomcat is installed.
# You must run ./package_app.sh prior to running this script.
# Set TOMCAT_HOME environment variable to override default of/opt/tomcat/apache-tomcat-6.0.14

. setenv.sh

echo "Warning: Ensure that you run ./package_app.sh prior to running this script"
echo "Warning: Only currently supports local Tomcat instance"
jruby -S rake -f ../webapp/Rakefile trisano:deploy:redeploytomcat_no_smoke
