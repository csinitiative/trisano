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

class Array

  # return a comma delimited string
  def to_list
    map { |el| "'#{el}'"}.join(',')
  end

  # collect to_i of all members
  def to_ints
    map(&:to_i)
  end

  def each_as_cursor(&block)
    each_index do |i|
      block[Cursor.new(self, i)]
    end
  end

  class Cursor
    attr_reader :array
    attr_reader :index

    def initialize(array, index)
      @array = array
      @index = index
    end

    def current
      array[index]
    end

    def previous
      previous_position.current
    end

    def next
      next_position.current
    end

    def previous_position
      prev_pos = index - 1
      prev_pos = array.length - 1 if prev_pos < 0
      Cursor.new array, prev_pos
    end

    def next_position
      next_pos = index + 1
      next_pos = 0 if next_pos >= array.size
      Cursor.new array, next_pos
    end
  end
end
