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

class CommonTestTypesDiseases < ActiveRecord::Migration
  def self.up
    create_table :common_test_types_diseases do |t|
      t.integer :disease_id,          :null => false
      t.integer :common_test_type_id, :null => false
      t.timestamps
    end
    add_index :common_test_types_diseases, [:disease_id, :common_test_type_id], :unique => true, :name => 'by_common_test_type_and_disease'
  end

  def self.down
    remove_index :common_test_types_diseases, :name => :by_common_test_type_and_disease
    drop_table :common_test_types_diseases
  end
end
