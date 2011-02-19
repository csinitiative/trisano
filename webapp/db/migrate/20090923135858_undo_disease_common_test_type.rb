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
class UndoDiseaseCommonTestType < ActiveRecord::Migration
  def self.up
    remove_index :disease_common_test_types, :disease_id
    remove_index :disease_common_test_types, :common_test_type_id
    drop_table   :disease_common_test_types

    create_table :diseases_loinc_codes do |t|
      t.integer  :disease_id,    :null => false
      t.integer  :loinc_code_id, :null => false

      t.timestamps
    end
    add_index :diseases_loinc_codes, :disease_id
    add_index :diseases_loinc_codes, :loinc_code_id
  end

  def self.down
    create_table :disease_common_test_types do |t|
      t.integer  :disease_id, :null => false
      t.integer  :common_test_type_id, :null => false

      t.timestamps
    end
    add_index    :disease_common_test_types, :disease_id
    add_index    :disease_common_test_types, :common_test_type_id

    remove_index :diseases_loinc_codes, :disease_id
    remove_index :diseases_loinc_codes, :loinc_code_id
    drop_table   :diseases_loinc_codes
  end
end
