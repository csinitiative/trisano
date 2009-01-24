# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

class RemovePublishedFormTables < ActiveRecord::Migration
  def self.up
    drop_table :published_form_elements
    drop_table :published_forms
    drop_table :published_questions
  end

  def self.down
    create_table :published_form_elements do |t|
      t.integer :form_id
      t.string :type
      t.string :name
      t.string :description
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.timestamps
    end

    create_table :published_forms do |t|
      t.string :name
      t.string :description
      t.integer :disease_id
      t.integer :jurisdiction_id
      t.boolean :current
      t.string :version
      t.timestamps
    end

    create_table :published_questions do |t|
      t.integer :question_element_id  # FK to form_elements
      t.string  :question_text, :limit => 255
      t.string  :help_text, :limit => 255
      t.string  :data_type, :limit =>  50 # One of single_line_text, text_area, single_select, multi_select
      t.integer :size
      t.string  :condition, :limit => 255
      t.boolean :is_on_short_form
      t.boolean :is_required
      t.boolean :is_exportable
      t.timestamps
    end
  end

end
