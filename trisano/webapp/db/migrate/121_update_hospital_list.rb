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

class UpdateHospitalList < ActiveRecord::Migration

  def self.up
    if RAILS_ENV == "production"
      hospital_type_id = Code.find_by_code_name_and_the_code("placetype", "H").id

      # First we have to delete all existing hospitals.  Might trigger a FK constraint, but a purge of existing events is assumed
      existing_hospitals = Entity.find(:all, 
                                       :include => :places, 
                                       :conditions => ["entities.entity_type = 'place' and places.place_type_id = ?", hospital_type_id])

      existing_hospitals.each do |hospital|
        hospital.place.destroy
        hospital.destroy
      end

      # Now add all hospitals from the updated list
      new_hospitals = YAML::load_file "#{RAILS_ROOT}/db/defaults/hospitals.yml"

      new_hospitals.each do |hospital|
        e = Entity.new
        e.entity_type = 'place'
        e.places.build(:name => hospital, :place_type_id => hospital_type_id)
        e.save
      end
    end
  end

  def self.down
  end
end
