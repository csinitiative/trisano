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

class Treatment < ActiveRecord::Base
  belongs_to :treatment_type, :class_name => 'Code', :foreign_key => 'treatment_type_id'
  
  validates_presence_of :treatment_name, :treatment_type_id

  class << self

    def all_by_type(type_code)
      raise ArgumentError unless type_code.is_a?(Code)
      self.find(:all, :conditions => ["treatment_type_id = ?", type_code.id], :include => :treatment_type)
    end
    
    def load!(hashes)
      transaction do
        attributes = Treatment.new.attribute_names
        hashes.each do |attrs|
          treatment_type_code = attrs.fetch('treatment_type_code')
          code = Code.find_by_code_name_and_the_code('treatment_type', treatment_type_code)
          raise "Could not find treatment_type code for #{treatment_type_code}" if code.nil?
          unless self.find_by_treatment_type_id_and_treatment_name(code.id, attrs["treatment_name"])
            load_attrs = attrs.reject { |key, value| !attributes.include?(key) }
            load_attrs.merge!(:treatment_type_id => code.id)
            Treatment.create!(load_attrs)
          end
        end
      end
    end
  end

end
