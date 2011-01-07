#!/bin/bash

# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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


dump_path=$PWD/dump
dump_dir_contents=$(find "$dump_path" -type f)

echo $dump_path
for d in $dump_dir_contents
do
    echo "Obfuscating $d"
    jruby ../webapp/script/obfu.rb  $d ${d}_obfu 
    echo "Obfuscated dump file is named ${d}_obfu"
done

 
 


