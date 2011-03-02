# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

class CreateDiseaseSpecificTreatments < ActiveRecord::Migration
  def self.up
    transaction do
      create_table :disease_specific_treatments do |t|
        t.integer :disease_id,   :null => false
        t.integer :treatment_id, :null => false

        t.timestamps
      end
      add_index :disease_specific_treatments, [:disease_id, :treatment_id], :unique => true, :name => :diseases_and_treatments_unique
    end
  end

  def self.down
    transaction do
      remove_index :disease_specific_treatments, :name => :diseases_and_treatments_unique
      drop_table :disease_specific_treatments
    end
  end
end
