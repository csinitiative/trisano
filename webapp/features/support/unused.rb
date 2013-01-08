# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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
# Copyright (c) 2010, Nathaniel Ritmeyer. All rights reserved.
#
# http://www.natontesting.com
#
# Save this in a file called 'unused.rb' in your 'features/support' directory. Then, to list
# all the unused steps in your project, run the following command:
#
#   cucumber -d -f Cucumber::Formatter::Unused
#
# or...
#
#   cucumber -d -f Unused
 
require 'cucumber/formatter/stepdefs'
 
class Unused < Cucumber::Formatter::Stepdefs
  def print_summary(features)
    add_unused_stepdefs
    keys = @stepdef_to_match.keys.sort {|a,b| a.regexp_source <=> b.regexp_source}
    puts "The following steps are unused...\n---------"
    keys.each do |stepdef_key|
      if @stepdef_to_match[stepdef_key].none?
        puts "#{stepdef_key.regexp_source}\n#{stepdef_key.file_colon_line}\n---"
      end
    end
  end
end
