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

class RemoveCurrentlyUnusedFieldsFromQuestions < ActiveRecord::Migration
  def self.up
    remove_column :questions, :is_on_short_form
    remove_column :questions, :is_exportable
    remove_column :questions, :is_template
    remove_column :questions, :template_id
  end

  def self.down
    add_column :questions, :is_on_short_form, :boolean
    add_column :questions, :is_exportable, :boolean
    add_column :questions, :is_template, :boolean
    add_column :questions, :template_id, :integer
  end
end
