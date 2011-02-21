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

class MakeCoreFieldsANestedSet < ActiveRecord::Migration
  def self.up
    transaction do
      execute "create sequence core_field_tree_id_generator"
      add_column :core_fields, :tree_id, :integer
      add_column :core_fields, :rgt, :integer
      add_column :core_fields, :lft, :integer
      add_column :core_fields, :parent_id, :integer
    end
  end

  def self.down
    transaction do
      execute "drop sequence core_field_tree_id_generator"
      remove_column :core_fields, :tree_id
      remove_column :core_fields, :rgt
      remove_column :core_fields, :lft
      remove_column :core_fields, :parent_id
    end
  end
end
