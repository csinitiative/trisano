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
class AddRepeaterToCoreField < ActiveRecord::Migration
  def self.up
    CoreField.transaction do
      add_column :core_fields, :repeater, :boolean, :default => false
      CoreField.reset_column_information
      core_fields = %w(
        morbidity_event[hospitalization_facilities][hospitals_participation][admission_date]
      )
      core_fields.each do |core_field|
          CoreField.find_by_key(core_field).update_attribute(:repeater, true) 
      end
    end
  end

  def self.down
    remove_column :core_field, :repeater
  end
end
