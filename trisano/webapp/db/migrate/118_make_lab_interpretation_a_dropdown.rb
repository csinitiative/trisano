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

require "migration_helpers"

class MakeLabInterpretationADropdown < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    remove_column   :lab_results, :interpretation
    add_column      :lab_results, :interpretation_id, :integer
    add_foreign_key :lab_results, :interpretation_id, :external_codes

    if RAILS_ENV == "production"
      interpretations = YAML::load_file "#{RAILS_ROOT}/db/defaults/lab_interpretations.yml"
      interpretations.each do |interpretation|
        ExternalCode.create(:code_name => interpretation['code_name'], 
                            :the_code => interpretation['the_code'], 
                            :code_description => interpretation['code_description'], 
                            :sort_order => interpretation['sort_order'], 
                            :live => true)
      end
    end
  end

  def self.down
    remove_column :lab_results, :interpretation_id
    add_column    :lab_results, :interpretation, :string
  end
end
