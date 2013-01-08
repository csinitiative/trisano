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
module CustomMatchers  
  class AcceptNestedAttributes  
    #do any setup required - at the very least, set some instance variables.  
    def initialize(expected)
      @expected = expected  
    end  
  
    def matches?(target)  
      @target = target
      @target.respond_to?("#{@expected}_attributes=")
    end  
  
    def failure_message  
      "expected #{@target.inpsect} to accept nested attributes for #{@expected}"  
    end  
  
    def negative_failure_message  
      "expected #{@target.inpsect} to not accept nested attributes for #{@expected}"  
    end  
  
    #displayed in the spec description if the user doesn't provide one (ie if they just write 'it do' for the spec header)  
    def description  
      "accept nested attributes for #{@expected}"  
    end  
  
    # Returns string representation of the object being tested  
    def to_s(value)  
      "#{@expected.inspect}"  
    end  
  end  
  
  # the matcher method that the user calls in their specs  
  def accept_nested_attributes_for(expected)
    AcceptNestedAttributes.new(expected)
  end  
end  
