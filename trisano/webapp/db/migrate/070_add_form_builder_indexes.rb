# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

class AddFormBuilderIndexes < ActiveRecord::Migration
  def self.up
    add_index(:form_elements, :tree_id, :name => "fe_tree_id_index")
    add_index(:form_elements, :parent_id, :name => "fe_parent_id_index")
    add_index(:questions, :form_element_id, :name => "q_form_element_id_index")
  end

  def self.down
    remove_index(:form_elements, :name => "fe_tree_id_index")
    remove_index(:form_elements, :name => "fe_parent_id_index")
    remove_index(:questions, :name => "q_form_element_id_index")
  end
end
