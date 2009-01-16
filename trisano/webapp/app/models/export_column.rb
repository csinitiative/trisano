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

# TODO a good candidate for STI
class ExportColumn < ActiveRecord::Base
  belongs_to :export_name
  has_many :export_conversion_values, :order => "sort_order ASC", :dependent => :destroy
  has_and_belongs_to_many :diseases
  belongs_to :export_disease_group

  class << self
    def type_data_array
      [["Core Data", "CORE"], ["Formbuilder Data", "FORM"], ["System Generated", "FIXED"]]
    end

    def valid_types
      @valid_types ||= type_data_array.map { |type| type.last }
    end

    def core_export_columns_for(disease_ids) 
      find(:all,
           :select => "distinct (id), name",
           :conditions => ["diseases_export_columns.disease_id IN (?) AND export_columns.type_data = ?", disease_ids, 'CORE'],
           :joins => "LEFT JOIN diseases_export_columns ON diseases_export_columns.export_column_id = export_columns.id",
           :order => "name")
    end
  end

  validates_presence_of :export_name_id, :type_data, :export_column_name, :start_position, :length_to_output
  validates_numericality_of :start_position, :length_to_output
  validates_inclusion_of :type_data, :in => self.valid_types

  def validate
    case self.type_data 
    when "FORM"
      self.errors.add_to_base("Data Type required if Data Source is Formbuilder") if data_type.blank?
      self.errors.add_to_base("Table Name must be blank if Data Source is Formbuilder") unless table_name.blank?
      self.errors.add_to_base("Column Name must be blank if Data Source is Formbuilder") unless column_name.blank?
    when "CORE"
      self.errors.add_to_base("Table Name required if Data Source is Core") if table_name.blank?
      self.errors.add_to_base("Column Name required if Data Source is Core") if column_name.blank?
    when "FIXED"
      self.errors.add_to_base("Data Type must be blank if Data Source is System Generated") unless data_type.blank?
      self.errors.add_to_base("Table Name must be blank if Data Source is System Generated") unless table_name.blank?
      self.errors.add_to_base("Column Name must be blank if Data Source is System Generated") unless column_name.blank?
    end
  end
end

