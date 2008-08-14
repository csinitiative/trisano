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

class SupportForMultipleDiseasesPerForm < ActiveRecord::Migration
  def self.up

    ActiveRecord::Base.transaction do
      # Create join table
      create_table :diseases_forms, :id => false, :primary_key => [:form_id, :disease_id] do |t|
          t.integer  :form_id
          t.integer  :disease_id
          t.timestamps
          # Creak compound PK
      end

      # Create temporary table (will be dropped at end of 'session') to hold existing form to disease mappings
      create_table :existing_disease_form_mappings, :temporary => true do |t|
        t.integer :form_id
        t.integer :disease_id
      end

      # Store current form_id to disease_id mappings
      Form.find(:all).each do |form|
        execute("INSERT INTO existing_disease_form_mappings (form_id, disease_id) VALUES (#{form.id}, #{form.disease_id})") unless form.disease_id.nil?
      end

      # drop disease_id
      remove_column :forms, :disease_id

      # create indexes
      add_index :diseases_forms, [:form_id, :disease_id], :unique => true
      
      # Reapply earlier settings
      # The tuple returned by #each is an array where the zeroth element is the first column asked for etc.  Don't use an asterisk, column placement unpredicatble
      execute("SELECT form_id, disease_id from existing_disease_form_mappings").each do |mapping|
        execute("INSERT INTO diseases_forms (form_id, disease_id) VALUES (#{mapping[0]}, #{mapping[1]})")
      end
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      add_column :forms, :disease_id, :integer

      # The tuple returned by #each is an array where the zeroth element is the first column asked for etc.  Don't use an asterisk, column placement unpredicatble
      execute("SELECT DISTINCT ON (form_id) form_id, disease_id FROM diseases_forms ORDER BY form_id, created_at").each do |mapping|
        execute("UPDATE forms SET disease_id = #{mapping[1]} WHERE id = #{mapping[0]}")
      end

      drop_table :diseases_forms
    end
  end
end
