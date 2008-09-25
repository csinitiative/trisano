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

# Upgrades the database via Rails migrations. Use this script if you have an earlier version of 
# TriSano and want to upgrade it. The results of the script are sent to files (see below).

. setenv.sh

jruby -S rake -f ../webapp/Rakefile trisano:distro:upgrade_db > upgrade_db_output.txt
jruby -S rake -f ../webapp/Rakefile trisano:distro:set_new_db_permissions > set_new_db_permissions_output.txt
