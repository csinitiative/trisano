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

class ExportColumn < ActiveRecord::Base
  belongs_to :export_name
  has_many   :export_conversion_values, :order => "sort_order ASC"
  has_and_belongs_to_many   :diseases

  class << self
    def type_data_array
      [["Core Data", "CORE"], ["Formbuilder Data", "FORM"], ["System Generated", "FIXED"]]
    end

    def valid_types
      @valid_types ||= type_data_array.map { |type| type.last }
    end
  end

  validates_presence_of :export_name_id, :type_data, :export_column_name, :start_position, :length_to_output
  validates_numericality_of :start_position, :lenght_to_output
  validates_inclusion_of :type_data, :in => self.valid_types

end

