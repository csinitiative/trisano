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

class AddCodeUniqueConstraint < ActiveRecord::Migration
  def self.up
    execute 'ALTER TABLE codes ALTER COLUMN code_name SET NOT NULL';
    execute 'ALTER TABLE codes ALTER COLUMN the_code SET NOT NULL';
    execute 'ALTER TABLE external_codes ALTER COLUMN code_name SET NOT NULL';
    execute 'ALTER TABLE external_codes ALTER COLUMN the_code SET NOT NULL';

    add_index :codes, [:code_name, :the_code], :unique => true
    add_index :external_codes, [:code_name, :the_code], :unique => true
  end

  def self.down
    remove_index :codes, [:code_name, :the_code]
    remove_index :external_codes, [:code_name, :the_code]

    execute 'ALTER TABLE codes ALTER COLUMN code_name DROP NOT NULL';
    execute 'ALTER TABLE codes ALTER COLUMN the_code DROP NOT NULL';
    execute 'ALTER TABLE external_codes ALTER COLUMN code_name DROP NOT NULL';
    execute 'ALTER TABLE external_codes ALTER COLUMN the_code DROP NOT NULL';
  end
end
