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

require "migration_helpers"

class AddAgeAtOnset < ActiveRecord::Migration

  extend MigrationHelpers

  def self.up
    #age at onset
    add_column :events, :age_at_onset, :integer
    #age type
    add_column :events, :age_type_id, :integer
    add_foreign_key( :events, :age_type_id, :external_codes)
    
    if RAILS_ENV == 'production'
      transaction do
        say "Loading age types"
        [{:code_name => "age_type", :the_code => "0", :code_description => "years"},
         {:code_name => "age_type", :the_code => "1", :code_description => "months"},
         {:code_name => "age_type", :the_code => "2", :code_description => "weeks"},
         {:code_name => "age_type", :the_code => "3", :code_description => "days"},
         {:code_name => "age_type", :the_code => "4", :code_description => "census"},
         {:code_name => "age_type", :the_code => "9", :code_description => "unknown"}
        ].each {|hash| ExternalCode.create(hash)}
      end
    end

  end

  def self.down
    remove_foreign_key( :events, :age_type_id)
    remove_column :events, :age_type_id
    remove_column :events, :age_at_onset
  end
end
