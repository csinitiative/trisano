# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

module Blankable
  def values_blank?
    blankable_values.inject(true) do |result, value|
      result && if value.respond_to?(:values_blank?)
        value.values_blank?
      elsif value.respond_to?(:blank?)
        value.blank?
      elsif value.respond_to?(:empty?)
        value.empty?
      else
        value.nil?
      end
    end
  end
end

class Hash
  include Blankable
  def blankable_values
    values
  end
end

class Array
  include Blankable
  def blankable_values
    self
  end
end
