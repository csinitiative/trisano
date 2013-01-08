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
class AddRepeaterParentKeyToCoreField < ActiveRecord::Migration
  def self.up
    CoreField.transaction do
      add_column :core_fields, :repeater_parent_key, :string
      CoreField.reset_column_information
      core_fields = {
        "morbidity_event[hospitalization_facilities][hospitals_participation][admission_date]" =>
	"morbidity_event[hospitalization_facilities]"
      }
      core_fields.each do |key, repeater_parent_key|
          CoreField.find_by_key(key).update_attribute(:repeater_parent_key, repeater_parent_key) 
      end
    end
  end

  def self.down
    remove_column :core_field, :repeater_parent_key
  end
end
