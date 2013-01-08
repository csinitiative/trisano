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

class CreateDiseaseSpecificValidations < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :disease_specific_validations do |t|
      t.string :validation_key, :null => false
      t.integer :disease_id, :null => false
      
      t.timestamps
    end
    add_foreign_key :disease_specific_validations, :disease_id, :diseases
    add_index :disease_specific_validations, :validation_key
    add_index :disease_specific_validations, [:disease_id, :validation_key], :unique => true, :name => 'dsv_disease_key_uniq'
  end

  def self.down
    remove_index :disease_specific_validations, 'dsv_disease_key_uniq'
    remove_index :disease_specific_validations, :validation_key
    remove_foreign_key :disease_specific_validations, :disease_id
    drop_table :disease_specific_validations
  end
end
